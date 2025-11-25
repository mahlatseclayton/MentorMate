const { onSchedule } = require('firebase-functions/v2/scheduler');
const { logger } = require('firebase-functions/v2');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.scheduleEventReminders = onSchedule({
  schedule: 'every 5 minutes',
  timeZone: 'Africa/Johannesburg',
}, async (event) => {
  const now = new Date();
  const db = getFirestore();

  try {
    // Calculate reminder times (1 day and 2 hours from NOW, not event time)
    const oneDayFromNow = new Date(now.getTime() + (24 * 60 * 60 * 1000));
    const twoHoursFromNow = new Date(now.getTime() + (2 * 60 * 60 * 1000));

    logger.log(`Checking events at: ${now}`);
    logger.log(`Looking for events around: 1-day: ${oneDayFromNow}, 2-hours: ${twoHoursFromNow}`);

    // Find events in the future
    const eventsSnapshot = await db.collection('Events')
      .where('dateTime', '>=', now.toISOString())
      .get();

    logger.log(`Found ${eventsSnapshot.size} future events`);

    for (const eventDoc of eventsSnapshot.docs) {
      const eventData = eventDoc.data();
      const eventDateTime = new Date(eventData.dateTime);

      // Check if event is within 1 day ± 5 minutes
      const oneDayDiff = Math.abs(eventDateTime.getTime() - oneDayFromNow.getTime());
      const twoHoursDiff = Math.abs(eventDateTime.getTime() - twoHoursFromNow.getTime());

      logger.log(`Event: ${eventData.title} at ${eventDateTime}`);
      logger.log(`1-day diff: ${oneDayDiff}ms, 2-hour diff: ${twoHoursDiff}ms`);

      // Send 1-day reminder if event is within 5 minutes of 1-day mark
      if (oneDayDiff <= (5 * 60 * 1000)) {
        logger.log(`Sending 1-day reminder for: ${eventData.title}`);
        await sendReminder(eventData, eventDoc.id, '1day');
      }

      // Send 2-hour reminder if event is within 5 minutes of 2-hour mark
      if (twoHoursDiff <= (5 * 60 * 1000)) {
        logger.log(`Sending 2-hour reminder for: ${eventData.title}`);
        await sendReminder(eventData, eventDoc.id, '2hours');
      }
    }

    logger.log('Reminder scheduling completed');
  } catch (error) {
    logger.error('Error in scheduleEventReminders:', error);
  }
});

async function sendReminder(event, eventId, reminderType) {
  const db = getFirestore();

  // Check if reminder was already sent
  const reminderSent = await db.collection('sentReminders')
    .where('eventId', '==', eventId)
    .where('reminderType', '==', reminderType)
    .get();

  if (!reminderSent.empty) {
    logger.log(`Reminder ${reminderType} already sent for event: ${eventId}`);
    return;
  }

  // Get all users with the same signkey
  const usersSnapshot = await db.collection('users')
    .where('signkey', '==', event.signkey)
    .where('fcmToken', '!=', null)
    .get();

  const tokens = [];
  usersSnapshot.forEach((doc) => {
    const userData = doc.data();
    if (userData.fcmToken && userData.fcmToken !== '') {
      tokens.push(userData.fcmToken);
    }
  });

  if (tokens.length === 0) {
    logger.log(`No FCM tokens found for signkey: ${event.signkey}`);
    return;
  }

  let message = '';
  if (reminderType === '1day') {
    message = `Reminder: "${event.title}" is tomorrow at ${formatTime(event.dateTime)}`;
  } else {
    message = `Reminder: "${event.title}" is in 2 hours at ${formatTime(event.dateTime)}`;
  }

  const payload = {
    notification: {
      title: 'Calendar Reminder',
      body: message,
    },
    data: {
      type: 'event_reminder',
      eventId: eventId,
      title: event.title,
      dateTime: event.dateTime,
      reminderType: reminderType,
    },
    tokens: tokens,
  };

  try {
    const messaging = getMessaging();
    const response = await messaging.sendEachForMulticast(payload);

    if (response.successCount > 0) {
      await db.collection('sentReminders').add({
        eventId: eventId,
        reminderType: reminderType,
        sentAt: FieldValue.serverTimestamp(),
        recipientsCount: response.successCount,
        failedCount: response.failureCount,
      });
      logger.log(`Successfully sent ${reminderType} reminder to ${response.successCount} users for event: ${event.title}`);
    }

    if (response.failureCount > 0) {
      logger.log(`Failed to send ${reminderType} reminder to ${response.failureCount} users`);
    }
  } catch (error) {
    logger.error('Error sending reminder:', error);
  }
}

function formatTime(dateTimeString) {
  const date = new Date(dateTimeString);
  return date.toLocaleString('en-ZA', {
    hour: '2-digit',
    minute: '2-digit',
    day: 'numeric',
    month: 'short',
  });
}