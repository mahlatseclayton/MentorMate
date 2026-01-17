const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions/v2");

const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Initialize Firebase
admin.initializeApp();

const db = admin.firestore();

// Email transport (Gmail) - Direct password for testing
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "mentormenteeconnect26@gmail.com",
    pass: "buzpqkwmzmhfjniz",
  },
});

/**
 * Parse event date from multiple possible formats
 */
function parseEventDate(event) {
  // Priority 1: ISO 8601 format
  if (event.isoDate) {
    try {
      return new Date(event.isoDate);
    } catch (err) {
      logger.warn(`Failed to parse ISO date: ${event.isoDate}`, err);
    }
  }

  // Priority 2: Firestore Timestamp (dateTime field)
  const dt = event.dateTime;
  if (dt && typeof dt.toDate === "function") {
    return dt.toDate();
  }

  // Priority 3: Firestore Timestamp (timestamp field)
  if (event.timestamp && typeof event.timestamp.toDate === "function") {
    return event.timestamp.toDate();
  }

  // Priority 4: String format "25/11/2025 • 7:30 PM"
  if (typeof dt === "string") {
    try {
      return parseStringDate(dt);
    } catch (err) {
      logger.warn(`Failed to parse string date: ${dt}`, err);
    }
  }

  // Fallback to current time
  return new Date();
}

/**
 * Parse string date in format "25/11/2025 • 7:30 PM"
 */
function parseStringDate(dateString) {
  let cleaned = dateString.replace("•", "").trim();
  const parts = cleaned.split(" ").filter(part => part.length > 0);

  if (parts.length < 3) {
    throw new Error(`Invalid string date format: ${dateString}`);
  }

  const datePart = parts[0];
  const [day, month, year] = datePart.split("/").map(Number);

  if (!day || !month || !year) {
    throw new Error(`Invalid date part: ${datePart}`);
  }

  const timePart = parts[1];
  const ampm = parts[2];

  if (!timePart || !ampm) {
    return new Date(year, month - 1, day);
  }

  const [hourStr, minuteStr] = timePart.split(":");
  let hour = Number(hourStr);
  const minute = Number(minuteStr || 0);

  if (isNaN(hour) || isNaN(minute)) {
    throw new Error(`Invalid time part: ${timePart}`);
  }

  // Convert to 24-hour format
  if (ampm.toUpperCase() === "PM" && hour !== 12) {
    hour += 12;
  }
  if (ampm.toUpperCase() === "AM" && hour === 12) {
    hour = 0;
  }

  return new Date(year, month - 1, day, hour, minute);
}

/**
 * Format time nicely for emails
 */
function formatTime(dateTime) {
  return dateTime.toLocaleString("en-ZA", {
    weekday: 'short',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Africa/Johannesburg'
  });
}

// 🔥 IMMEDIATE NOTIFICATION: Trigger when any event is created
exports.sendImmediateEventNotification = onDocumentCreated(
  {
    document: "Events/{eventId}",
    region: "us-central1",
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.error("No data associated with the event");
      return;
    }

    const eventData = snapshot.data();
    const eventId = event.params.eventId;

    logger.log(`🎯 New event created: "${eventData.title}" (ID: ${eventId})`);

    try {
      await sendReminder(eventData, eventId, "immediate");
      logger.log(`✅ Immediate notification sent for: "${eventData.title}"`);
    } catch (error) {
      logger.error(`❌ Failed to send notification for "${eventData.title}":`, error);
    }
  }
);

// 🔥 SCHEDULED 5-HOUR REMINDER: Runs every 15 minutes to check for events happening in 5 hours
exports.send5HourReminders = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "Africa/Johannesburg",
    region: "us-central1",
  },
  async () => {
    const now = new Date();
    const fiveHoursFromNow = new Date(now.getTime() + 5 * 60 * 60 * 1000);

    logger.log(`⏰ Running 5-hour reminder check at: ${now.toISOString()}`);
    logger.log(`🔍 Looking for events around: ${fiveHoursFromNow.toISOString()}`);

    try {
      // Get all events from Events collection
      const eventsSnapshot = await db.collection("Events").get();
      logger.log(`📋 Found ${eventsSnapshot.size} total events to check`);

      let remindersSent = 0;

      for (const eventDoc of eventsSnapshot.docs) {
        const event = eventDoc.data();
        const eventId = eventDoc.id;

        // Skip if it's not a meeting (only send 5-hour reminders for meetings)
        if (event.type !== 'meeting') {
          continue;
        }

        let eventTime;
        try {
          eventTime = parseEventDate(event);
        } catch (err) {
          logger.error(`Failed to parse event date for "${event.title}":`, err);
          continue;
        }

        // Calculate time difference in minutes
        const timeDiffMinutes = (eventTime - fiveHoursFromNow) / (1000 * 60);

        // Send reminder if event is within ±15 minutes of 5 hours from now
        if (Math.abs(timeDiffMinutes) <= 15) {
          logger.log(`⏰ 5-hour reminder triggered for: "${event.title}"`);
          logger.log(`   Event time: ${eventTime.toISOString()}`);
          logger.log(`   Time difference: ${timeDiffMinutes.toFixed(1)} minutes`);

          await sendReminder(event, eventId, "5hours");
          remindersSent++;
        }
      }

      logger.log(`✅ 5-hour reminder scan completed. Sent ${remindersSent} reminders.`);

    } catch (error) {
      logger.error("❌ 5-hour reminder ERROR:", error);
    }
  }
);

/**
 * Send reminder email (works for both immediate and 5-hour reminders)
 */
async function sendReminder(event, eventId, reminderType) {
  let emails = [];

  // Get all users who match event.signkey
  if (event.signkey) {
    const usersSnapshot = await db
      .collection("users")
      .where("signkey", "==", event.signkey)
      .get();

    usersSnapshot.forEach((doc) => {
      const user = doc.data();
      if (user.email) emails.push(user.email);
    });
  }

  // Remove duplicates
  emails = [...new Set(emails)];

  if (emails.length === 0) {
    logger.log(`⚠ No recipients found for event "${event.title}"`);
    return;
  }

  // Parse event time
  const eventTime = parseEventDate(event);
  const formattedTime = formatTime(eventTime);

  // Determine email content based on reminder type and event type
  let subject, message;

  if (reminderType === "immediate") {
    // Immediate notification content (existing logic)
    switch (event.type) {
      case 'meeting':
        subject = `📅 New Meeting: ${event.title}`;
        message = `A new meeting has been scheduled:\n\n` +
                  `📌 ${event.title}\n` +
                  `🕐 ${formattedTime}\n` +
                  `📍 ${event.venue || 'Location to be confirmed'}\n\n` +
                  `Please make sure to attend.`;
        break;

      case 'announcement':
        subject = `📢 New Announcement: ${event.title}`;
        message = `A new announcement has been made:\n\n` +
                  `📌 ${event.title}\n` +
                  `🕐 ${formattedTime}\n` +
                  `📝 ${event.description || 'No additional details provided.'}`;
        break;

      case 'register':
        subject = `📋 Attendance Register: ${event.title}`;
        message = `An attendance register has been created:\n\n` +
                  `📌 ${event.title}\n` +
                  `❓ ${event.question || 'Please mark your attendance'}\n` +
                  `⏰ Please respond within 24 hours`;
        break;

      case 'calendar_event':
        subject = `🗓️ New Event: ${event.title}`;
        message = `A new event has been added to your calendar:\n\n` +
                  `📌 ${event.title}\n` +
                  `🕐 ${formattedTime}\n` +
                  `📝 ${event.description || 'No additional details provided.'}`;
        break;

      default:
        subject = `📅 New Event: ${event.title}`;
        message = `A new event has been scheduled:\n\n` +
                  `📌 ${event.title}\n` +
                  `🕐 ${formattedTime}\n` +
                  `📝 ${event.description || 'No additional details provided.'}`;
    }
  } else if (reminderType === "5hours") {
    // 5-hour reminder content (only for meetings)
    subject = `⏰ Meeting Reminder: ${event.title} in 5 hours`;
    message = `Reminder: You have a meeting coming up in 5 hours:\n\n` +
              `📌 ${event.title}\n` +
              `🕐 ${formattedTime}\n` +
              `📍 ${event.venue || 'Location to be confirmed'}\n\n` +
              `Please prepare to attend.`;
  }

  // Add venue if available and not already included
  if (event.venue && event.type !== 'meeting' && reminderType === "immediate") {
    message += `\n📍 ${event.venue}`;
  }

  // Prevent duplicate sending by checking sentReminders collection
  const alreadySent = await db.collection("sentReminders")
    .where("eventId", "==", eventId)
    .where("reminderType", "==", reminderType)
    .get();

  if (!alreadySent.empty) {
    logger.log(`⏩ SKIP: ${reminderType} reminder already sent for event "${event.title}"`);
    return;
  }

  try {
    // Send emails to all recipients
    for (const email of emails) {
      await transporter.sendMail({
        from: "Mentor Mentee Connect <mentormmentee26@gmail.com>",
        to: email,
        subject: subject,
        text: message,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 10px 10px 0 0;">
              <h2 style="color: white; margin: 0;">${subject}</h2>
            </div>
            <div style="background: #f9f9f9; padding: 20px; border-radius: 0 0 10px 10px;">
              <p style="font-size: 16px; line-height: 1.6; color: #333;">
                ${message.replace(/\n/g, "<br>")}
              </p>
              <div style="margin-top: 20px; padding: 15px; background: white; border-left: 4px solid #667eea; border-radius: 5px;">
                <p style="margin: 0; color: #667eea; font-weight: bold;">📅 Event Details:</p>
                <p style="margin: 5px 0 0 0; color: #666;">
                  <strong>Title:</strong> ${event.title}<br>
                  <strong>When:</strong> ${formattedTime}<br>
                  ${event.description ? `<strong>Details:</strong> ${event.description}<br>` : ''}
                  ${event.venue ? `<strong>Location:</strong> ${event.venue}<br>` : ''}
                  ${event.type ? `<strong>Type:</strong> ${event.type.charAt(0).toUpperCase() + event.type.slice(1)}` : ''}
                </p>
              </div>
              <div style="margin-top: 20px; padding: 10px; background: #e8f4fd; border-radius: 5px;">
                <p style="margin: 0; color: #2c5cc7; font-size: 14px;">
                  This is an automated ${reminderType === 'immediate' ? 'notification' : 'reminder'} from Mentor Mentee Connect.
                </p>
              </div>
            </div>
          </div>
        `,
      });
      logger.log(`📧 ${reminderType} email sent to ${email}`);
    }

    // Log the notification in sentReminders collection to prevent duplicates
    await db.collection("sentReminders").add({
      eventId: eventId,
      eventTitle: event.title,
      eventType: event.type,
      reminderType: reminderType,
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
      recipientsCount: emails.length,
      eventTime: eventTime,
    });

    logger.log(
      `✅ ${reminderType} notification completed for "${event.title}" → ${emails.length} emails sent`
    );

  } catch (err) {
    logger.error(`Email sending error for ${reminderType} reminder:`, err);
    throw err;
  }
}

// Test function to verify email sending
exports.testEmailNotification = onRequest(
  {
    region: "us-central1",
  },
  async (req, res) => {
    try {
      await transporter.sendMail({
        from: "Mentor Mentee Connect <mentormmenteeconnect26@gmail.com>",
        to: "mentormmenteeconnect26@gmail.com",
        subject: "Test Email from Mentor Mentee Connect",
        text: "This is a test email from your Cloud Function.",
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 10px 10px 0 0;">
              <h2 style="color: white; margin: 0;">Test Email from Mentor Mate</h2>
            </div>
            <div style="background: #f9f9f9; padding: 20px; border-radius: 0 0 10px 10px;">
              <p style="font-size: 16px; line-height: 1.6; color: #333;">
                This is a test email from your Cloud Function to verify that email notifications are working correctly.
              </p>
              <div style="margin-top: 20px; padding: 10px; background: #e8f4fd; border-radius: 5px;">
                <p style="margin: 0; color: #2c5cc7; font-size: 14px;">
                  If you received this email, your Cloud Function is working properly! 🎉
                </p>
              </div>
            </div>
          </div>
        `,
      });

      res.status(200).send("Test email sent successfully!");
    } catch (error) {
      logger.error("Test email failed:", error);
      res.status(500).send("Test email failed: " + error.message);
    }
  }
);