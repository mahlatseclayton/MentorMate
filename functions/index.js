const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const db = admin.firestore();

const EMAIL_PASSWORD = defineSecret("EMAIL_PASSWORD");

exports.sendImmediateEventNotification = onDocumentCreated(
  {
    document: "Events/{eventId}",
    region: "us-central1",
    secrets: [EMAIL_PASSWORD],
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const eventData = snapshot.data();
    const eventId = event.params.eventId;

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "mentormenteeconnect26@gmail.com",
        pass: EMAIL_PASSWORD.value(),
      },
    });

    await sendReminder(eventData, eventId, "immediate", transporter);
  }
);

exports.sendImmediateEventToStudent = onDocumentCreated(
  {
    document: "events/{eventId}",
    region: "us-central1",
    secrets: [EMAIL_PASSWORD],
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const eventData = snapshot.data();
    const eventId = event.params.eventId;

    if (!eventData.studentEmail) return;

    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "mentormenteeconnect26@gmail.com",
        pass: EMAIL_PASSWORD.value(),
      },
    });

    const sent = await db
      .collection("sentReminders")
      .where("eventId", "==", eventId)
      .where("reminderType", "==", "studentEvent")
      .get();

    if (!sent.empty) return;

    const eventTime = parseEventDate(eventData);
    const formattedTime = formatTime(eventTime);

    const subject = `${eventData.title || "New Event"}`;
    const htmlContent = getStudentEventHtmlTemplate(eventData, formattedTime);
    const textContent = `${eventData.title || "New Event"}\nDate: ${formattedTime}\nDescription: ${eventData.description || ''}`;

    await transporter.sendMail({
      from: "Mentor Mentee Connect <mentormenteeconnect26@gmail.com>",
      to: eventData.studentEmail,
      subject,
      html: htmlContent,
      text: textContent,
    });

    await db.collection("sentReminders").add({
      eventId,
      reminderType: "studentEvent",
      sentAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
);

exports.send5HourReminders = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "Africa/Johannesburg",
    region: "us-central1",
    secrets: [EMAIL_PASSWORD],
  },
  async () => {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: "mentormenteeconnect26@gmail.com",
        pass: EMAIL_PASSWORD.value(),
      },
    });

    const now = new Date();
    const target = new Date(now.getTime() + 5 * 60 * 60 * 1000);

    const snapshot = await db.collection("Events").get();

    for (const doc of snapshot.docs) {
      const event = doc.data();
      if (event.type !== "meeting") continue;

      const eventTime = parseEventDate(event);
      const diff = (eventTime - target) / (1000 * 60);

      if (Math.abs(diff) <= 15) {
        await sendReminder(event, doc.id, "5hours", transporter);
      }
    }
  }
);

async function sendReminder(event, eventId, reminderType, transporter) {
  let emails = [];

  if (event.signkey) {
    const users = await db
      .collection("users")
      .where("signkey", "==", event.signkey)
      .get();

    users.forEach((d) => {
      if (d.data().email) emails.push(d.data().email);
    });
  }

  emails = [...new Set(emails)];
  if (!emails.length) return;

  const sent = await db
    .collection("sentReminders")
    .where("eventId", "==", eventId)
    .where("reminderType", "==", reminderType)
    .get();

  if (!sent.empty) return;

  const eventTime = parseEventDate(event);
  const formattedTime = formatTime(eventTime);

  let subject = "";
  let htmlContent = "";
  let textContent = "";

  if (reminderType === "immediate") {
    subject = `${event.title}`;
    htmlContent = getHtmlTemplate(event, formattedTime, reminderType);
    textContent = `${event.title}\nDate: ${formattedTime}\nVenue: ${event.venue || 'To be announced'}\nDescription: ${event.description || ''}`;
  } else {
    subject = `Reminder: ${event.title}`;
    htmlContent = getHtmlTemplate(event, formattedTime, reminderType);
    textContent = `${event.title}\nDate: ${formattedTime}\nVenue: ${event.venue || 'To be announced'}\nDescription: ${event.description || ''}\nThis meeting starts in approximately 5 hours.`;
  }

  for (const email of emails) {
    await transporter.sendMail({
      from: "Mentor Mentee Connect <mentormenteeconnect26@gmail.com>",
      to: email,
      subject,
      html: htmlContent,
      text: textContent,
    });
  }

  await db.collection("sentReminders").add({
    eventId,
    reminderType,
    sentAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

function getHtmlTemplate(event, formattedTime, reminderType) {
  const isMeeting = event.type === 'meeting';
  const eventType = isMeeting ? 'Meeting' : 'Announcement';
  const primaryColor = '#667eea';
  const gradientStart = '#667eea';
  const gradientEnd = '#764ba2';

  return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${event.title}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.4;
            color: #333;
            margin: 0;
            padding: 20px;
            background-color: #f8fafc;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
        }
        .header {
            background: linear-gradient(135deg, ${gradientStart} 0%, ${gradientEnd} 100%);
            color: white;
            padding: 24px 20px;
            text-align: center;
        }
        .event-icon {
            font-size: 36px;
            margin-bottom: 12px;
        }
        .header h1 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            line-height: 1.3;
        }
        .type-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            margin-top: 12px;
            backdrop-filter: blur(10px);
        }
        .content {
            padding: 24px;
        }
        .info-row {
            display: flex;
            align-items: flex-start;
            margin-bottom: 16px;
            padding-bottom: 16px;
            border-bottom: 1px solid rgba(102, 126, 234, 0.1);
        }
        .info-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        .info-icon {
            color: ${primaryColor};
            font-size: 20px;
            min-width: 24px;
            margin-right: 16px;
            margin-top: 2px;
        }
        .info-text {
            flex: 1;
        }
        .info-label {
            font-size: 12px;
            color: #718096;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .info-value {
            font-size: 15px;
            color: #2d3748;
            line-height: 1.5;
        }
        .reminder-banner {
            background: linear-gradient(135deg, #ffeaa7, #fab1a0);
            border-radius: 10px;
            padding: 14px;
            margin: 20px 0 0 0;
            display: flex;
            align-items: center;
        }
        .reminder-icon {
            font-size: 20px;
            margin-right: 12px;
            flex-shrink: 0;
        }
        .reminder-text {
            font-size: 14px;
            color: #2d3748;
            font-weight: 500;
        }
        .footer {
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #f8fafc, #ffffff);
            color: #718096;
            font-size: 13px;
            border-top: 1px solid rgba(102, 126, 234, 0.1);
        }
        .logo {
            color: ${primaryColor};
            font-weight: 700;
            font-size: 16px;
            margin-bottom: 8px;
        }
        .automated-text {
            font-size: 12px;
            color: #a0aec0;
            margin-bottom: 8px;
        }
        .copyright {
            font-size: 12px;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="event-icon">${isMeeting ? '👥' : '📢'}</div>
            <h1>${event.title}</h1>
            <div class="type-badge">${eventType}</div>
        </div>

        <div class="content">
            <div class="info-row">
                <div class="info-icon">📅</div>
                <div class="info-text">
                    <div class="info-label">Date & Time</div>
                    <div class="info-value">${formattedTime}</div>
                </div>
            </div>

            ${event.venue ? `
            <div class="info-row">
                <div class="info-icon">📍</div>
                <div class="info-text">
                    <div class="info-label">Venue</div>
                    <div class="info-value">${event.venue}</div>
                </div>
            </div>
            ` : ''}

            ${event.description ? `
            <div class="info-row">
                <div class="info-icon">📝</div>
                <div class="info-text">
                    <div class="info-label">Description</div>
                    <div class="info-value">${event.description}</div>
                </div>
            </div>
            ` : ''}

            ${reminderType === '5hours' ? `
            <div class="reminder-banner">
                <div class="reminder-icon">⏰</div>
                <div class="reminder-text">This meeting starts in approximately 5 hours</div>
            </div>
            ` : ''}
        </div>

        <div class="footer">
            <div class="logo">MENTOR MENTEE CONNECT</div>
            <div class="automated-text">This is an automated message from Mentor Mentee Connect</div>
            <div class="copyright">© 2026 All rights reserved</div>
        </div>
    </div>
</body>
</html>
  `;
}

function getStudentEventHtmlTemplate(event, formattedTime) {
  const primaryColor = '#667eea';
  const gradientStart = '#667eea';
  const gradientEnd = '#764ba2';

  return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${event.title || "Event Notification"}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.4;
            color: #333;
            margin: 0;
            padding: 20px;
            background-color: #f8fafc;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
        }
        .header {
            background: linear-gradient(135deg, ${gradientStart} 0%, ${gradientEnd} 100%);
            color: white;
            padding: 24px 20px;
            text-align: center;
        }
        .event-icon {
            font-size: 36px;
            margin-bottom: 12px;
        }
        .header h1 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            line-height: 1.3;
        }
        .type-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            margin-top: 12px;
            backdrop-filter: blur(10px);
        }
        .content {
            padding: 24px;
        }
        .info-row {
            display: flex;
            align-items: flex-start;
            margin-bottom: 16px;
            padding-bottom: 16px;
            border-bottom: 1px solid rgba(102, 126, 234, 0.1);
        }
        .info-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        .info-icon {
            color: ${primaryColor};
            font-size: 20px;
            min-width: 24px;
            margin-right: 16px;
            margin-top: 2px;
        }
        .info-text {
            flex: 1;
        }
        .info-label {
            font-size: 12px;
            color: #718096;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 4px;
        }
        .info-value {
            font-size: 15px;
            color: #2d3748;
            line-height: 1.5;
        }
        .student-banner {
            background: linear-gradient(135deg, #a29bfe, #74b9ff);
            border-radius: 10px;
            padding: 14px;
            margin: 20px 0 0 0;
            display: flex;
            align-items: center;
        }
        .student-icon {
            font-size: 20px;
            margin-right: 12px;
            flex-shrink: 0;
        }
        .student-text {
            font-size: 14px;
            color: white;
            font-weight: 500;
        }
        .footer {
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #f8fafc, #ffffff);
            color: #718096;
            font-size: 13px;
            border-top: 1px solid rgba(102, 126, 234, 0.1);
        }
        .logo {
            color: ${primaryColor};
            font-weight: 700;
            font-size: 16px;
            margin-bottom: 8px;
        }
        .automated-text {
            font-size: 12px;
            color: #a0aec0;
            margin-bottom: 8px;
        }
        .copyright {
            font-size: 12px;
            opacity: 0.7;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="event-icon">🎯</div>
            <h1>${event.title || "Personal Event Notification"}</h1>
            <div class="type-badge">Personal Event</div>
        </div>

        <div class="content">
            <div class="info-row">
                <div class="info-icon">📅</div>
                <div class="info-text">
                    <div class="info-label">Date & Time</div>
                    <div class="info-value">${formattedTime}</div>
                </div>
            </div>

            ${event.description ? `
            <div class="info-row">
                <div class="info-icon">📝</div>
                <div class="info-text">
                    <div class="info-label">Description</div>
                    <div class="info-value">${event.description}</div>
                </div>
            </div>
            ` : ''}

            <div class="student-banner">
                <div class="student-icon">👤</div>
                <div class="student-text">This event is specifically assigned to you</div>
            </div>
        </div>

        <div class="footer">
            <div class="logo">MENTOR MENTEE CONNECT</div>
            <div class="automated-text">This is an automated message from Mentor Mentee Connect</div>
            <div class="copyright">© 2026 All rights reserved</div>
        </div>
    </div>
</body>
</html>
  `;
}

function parseEventDate(event) {
  if (event.isoDate) {
    try {
      return new Date(event.isoDate);
    } catch {}
  }

  const dt = event.dateTime;
  if (dt && typeof dt.toDate === "function") return dt.toDate();
  if (event.timestamp && typeof event.timestamp.toDate === "function")
    return event.timestamp.toDate();

  if (typeof dt === "string") return parseStringDate(dt);

  return new Date();
}

function parseStringDate(dateString) {
  const cleaned = dateString.replace("•", "").trim();
  const parts = cleaned.split(" ").filter(Boolean);

  const [day, month, year] = parts[0].split("/").map(Number);
  if (!parts[1] || !parts[2]) return new Date(year, month - 1, day);

  let [hour, minute] = parts[1].split(":").map(Number);
  const ampm = parts[2].toUpperCase();

  if (ampm === "PM" && hour !== 12) hour += 12;
  if (ampm === "AM" && hour === 12) hour = 0;

  return new Date(year, month - 1, day, hour, minute || 0);
}

function formatTime(dateTime) {
  return dateTime.toLocaleString("en-ZA", {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    timeZone: "Africa/Johannesburg",
  });
}