const { onSchedule } = require("firebase-functions/v2/scheduler");
const functions = require("firebase-functions");
const logger = functions.logger;

const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const nodemailer = require("nodemailer");

// Initialize Firebase
initializeApp();

// Email transport (Gmail)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "mahlatseclayton1@gmail.com",
    pass: "hjjqerfrkmlfipsr", // App password
  },
});

/**
 * Parse event date from either:
 * 1. Firestore Timestamp
 * 2. String format: "25/11/2025 • 7:30 PM"
 */
function parseEventDate(event) {
  const dt = event.dateTime;

  // Case 1: Firestore Timestamp
  if (dt && typeof dt.toDate === "function") {
    return dt.toDate();
  }

  // Case 2: String format
  if (typeof dt === "string") {
    let cleaned = dt.replace("•", "").trim(); // remove bullet
    const parts = cleaned.split(" ");

    if (parts.length < 3) {
      throw new Error("Invalid string date format");
    }

    const [day, month, year] = parts[0].split("/").map(Number);
    const [hourStr, minuteStr] = parts[1].split(":");
    let hour = Number(hourStr);
    const minute = Number(minuteStr);
    const ampm = parts[2];

    if (ampm === "PM" && hour !== 12) hour += 12;
    if (ampm === "AM" && hour === 12) hour = 0;

    return new Date(year, month - 1, day, hour, minute);
  }

  throw new Error("Invalid event date format");
}

/**
 * Format time nicely for emails
 */
function formatTime(dateTime) {
  return dateTime.toLocaleString("en-ZA", {
    hour: "2-digit",
    minute: "2-digit",
    day: "numeric",
    month: "short",
  });
}

// CRON schedule: every 5 minutes
exports.scheduleEventReminders = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Africa/Johannesburg",
  },
  async () => {
    const now = new Date();
    const db = getFirestore();

    logger.log("Running reminder check at:", now);

    try {
      const oneDayFromNow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const twoHoursFromNow = new Date(now.getTime() + 2 * 60 * 60 * 1000);

      // Fetch all events (handle string dates manually)
      const eventsSnapshot = await db.collection("Events").get();
      logger.log(`Fetched ${eventsSnapshot.size} total events`);

      for (const eventDoc of eventsSnapshot.docs) {
        const event = eventDoc.data();
        let eventTime;

        try {
          eventTime = parseEventDate(event);
        } catch (err) {
          logger.error(`Failed to parse event date for ${event.title}:`, err);
          continue;
        }

        if (eventTime < now) continue; // skip past events

        const eventId = eventDoc.id;
        const diff1Day = Math.abs(eventTime - oneDayFromNow);
        const diff2Hours = Math.abs(eventTime - twoHoursFromNow);

        if (diff1Day <= 5 * 60 * 1000) {
          await sendReminder(event, eventId, "1day");
        }

        if (diff2Hours <= 5 * 60 * 1000) {
          await sendReminder(event, eventId, "2hours");
        }
      }

      logger.log("Reminder scan completed.");
    } catch (error) {
      logger.error("scheduleEventReminders ERROR:", error);
    }
  }
);

/**
 * Sends reminder emails
 */
async function sendReminder(event, eventId, reminderType) {
  const db = getFirestore();

  // Prevent duplicate sending
  const sent = await db
    .collection("sentReminders")
    .where("eventId", "==", eventId)
    .where("reminderType", "==", reminderType)
    .get();

  if (!sent.empty) {
    logger.log(`SKIP: ${reminderType} reminder already sent for event ${eventId}`);
    return;
  }

  // Get users who match event.signkey
  const usersSnapshot = await db
    .collection("users")
    .where("signkey", "==", event.signkey)
    .get();

  const emails = [];
  usersSnapshot.forEach((doc) => {
    const user = doc.data();
    if (user.email) emails.push(user.email);
  });

  if (emails.length === 0) {
    logger.log(`No users found with signkey ${event.signkey}`);
    return;
  }

  const eventTime = parseEventDate(event);
  const message =
    reminderType === "1day"
      ? `Reminder: "${event.title}" is tomorrow at ${formatTime(eventTime)}`
      : `Reminder: "${event.title}" is in 2 hours at ${formatTime(eventTime)}`;

  try {
    for (const email of emails) {
      await transporter.sendMail({
        from: "Mentor Mate <mahlatseclayton1@gmail.com>",
        to: email,
        subject: "📅 Event Reminder",
        text: message,
      });
    }

    await db.collection("sentReminders").add({
      eventId,
      reminderType,
      sentAt: FieldValue.serverTimestamp(),
      recipientsCount: emails.length,
    });

    logger.log(
      `SENT: ${reminderType} reminder to ${emails.length} users for event "${event.title}"`
    );
  } catch (err) {
    logger.error("Email sending error:", err);
  }
}
