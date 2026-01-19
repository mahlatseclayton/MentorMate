const {onDocumentCreated, onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {defineSecret} = require("firebase-functions/params");
const {onCall,HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const functions = require('firebase-functions');
admin.initializeApp();
const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');
const PATH_URL = defineSecret('PATH_URL');
function createDefaultTopic(number){
  return {
    "topic": `Academic Success Strategy ${number}`,
    "description": "This comprehensive topic helps students develop effective strategies for academic achievement in university. We explore various study techniques, time management approaches, and resource utilization methods that can significantly improve academic performance. Students will learn how to create personalized study plans, manage their coursework effectively, and leverage campus resources to enhance their learning experience. The discussion focuses on practical, actionable strategies that can be implemented immediately to improve grades and reduce academic stress.",
    "keyDiscussionPoints": [
      "Effective study habits and learning techniques",
      "Time management and prioritization strategies",
      "Utilizing academic support services effectively",
      "Balancing academic workload with personal life",
      "Exam preparation and stress management techniques"
    ],
    "iceBreakers": [
      "What study methods have worked best for you so far?",
      "How do you currently organize your study schedule?",
      "What academic achievement are you most proud of?"
    ],
    "questionsForMentees": [
      "What specific academic goals do you have for this semester?",
      "How do you currently prepare for exams and assignments?",
      "What times of day are you most productive for studying?",
      "How do you handle difficult or challenging course material?",
      "What academic support resources have you used before?",
      "How do you balance your academic work with other responsibilities?"
    ],
    "takeawaysForMentees": [
      "A personalized study plan for current courses",
      "Practical time management strategies for academic success",
      "Knowledge of available campus academic support resources",
      "Tools for tracking and improving academic performance"
    ],
    "campusResources": [
      "Centre for Student Development (CSD)",
      "CCDU (Counselling and Careers Development Unit)"
    ],
    "externalResources": ["Khan Academy for supplementary learning", "Pomodoro Technique timer apps"]
  };
}
//topic suggestion engine
function parseGeminiResponse(textResponse) {
  try {
    let cleanResponse = textResponse
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .replace(/JSON/g, '')
      .trim();

    let jsonStart = cleanResponse.indexOf('{');
    let jsonEnd = cleanResponse.lastIndexOf('}');

    if (jsonStart === -1 || jsonEnd === -1) {
      try {
        const parsed = JSON.parse(cleanResponse);
        return formatResponse(parsed);
      } catch {
        throw new Error('No valid JSON found in response');
      }
    }

    let jsonString = cleanResponse.substring(jsonStart, jsonEnd + 1);
    let parsed = JSON.parse(jsonString);

    return formatResponse(parsed);

  } catch (e) {
    return {
      suggestions: [createDefaultTopic(1)]
    };
  }
}

function formatResponse(parsed) {
  let suggestions = [];

  if (parsed.suggestions && Array.isArray(parsed.suggestions)) {
    suggestions = parsed.suggestions;
  } else if (Array.isArray(parsed)) {
    suggestions = parsed;
  } else if (parsed.topic || parsed.description) {
    suggestions = [parsed];
  } else {
    suggestions = [createDefaultTopic(1)];
  }

  const formattedSuggestions = suggestions.map((suggestion, index) => {
    if (typeof suggestion !== 'object' || suggestion === null) {
      return createDefaultTopic(index + 1);
    }

    return {
      topic: suggestion.topic || `Topic ${index + 1}`,
      description: suggestion.description || 'A comprehensive discussion topic for mentorship sessions.',
      keyDiscussionPoints: suggestion.keyDiscussionPoints || ['Main discussion areas', 'Key concepts'],
      iceBreakers: suggestion.iceBreakers || ['What interests you about this topic?'],
      questionsForMentees: suggestion.questionsForMentees || ['What aspects interest you?'],
      takeawaysForMentees: suggestion.takeawaysForMentees || ['Better understanding'],
      campusResources: suggestion.campusResources || ['CCDU', 'Centre for Student Development'],
      externalResources: suggestion.externalResources || ['Online resources']
    };
  });

  return { suggestions: formattedSuggestions };
}

exports.generateTopicSuggestions = onCall(
  {
    secrets: ["GEMINI_API_KEY", "PATH_URL"],
    timeoutSeconds: 120,
    memory: "1GB"
  },
  async (request) => {
    const apiKey = GEMINI_API_KEY.value();
    const pathUrl = PATH_URL.value();

    if (!apiKey || apiKey.trim() === '') {
      throw new HttpsError(
        'internal',
        'GEMINI_API_KEY is not configured in Firebase Secrets'
      );
    }

    if (!pathUrl || pathUrl.trim() === '') {
      throw new HttpsError(
        'internal',
        'PATH_URL is not configured in Firebase Secrets'
      );
    }

    const prompt = request.data.prompt;
    const campusResources = request.data.campusResources;
    const apiUrl = `${pathUrl}?key=${apiKey}`;

    try {
      const requestBody = {
        contents: [{
          parts: [{ text: prompt }]
        }],
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 4096,
        }
      };

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody)
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new HttpsError(
          'internal',
          `Gemini API error: ${response.status} - ${errorText}`
        );
      }

      const result = await response.json();

      if (!result.candidates || !result.candidates[0] || !result.candidates[0].content) {
        throw new HttpsError(
          'internal',
          'Invalid response format from Gemini API'
        );
      }

      const textResponse = result.candidates[0].content.parts[0].text;
      const parsedResponse = parseGeminiResponse(textResponse);

      const suggestions = parsedResponse.suggestions && parsedResponse.suggestions.length > 0
        ? parsedResponse.suggestions
        : [createDefaultTopic(1)];

      return {
        success: true,
        suggestions: suggestions,
        rawResponse: textResponse
      };

    } catch (error) {
      const fallbackTopic = [createDefaultTopic(1)];

      return {
        success: false,
        suggestions: fallbackTopic,
        error: error.message,
        isFallback: true
      };
    }
  }
);
//meeting scheduler
exports.generateMeetingSuggestions = onCall(
  {
    secrets: ["GEMINI_API_KEY", "PATH_URL"],
    timeoutSeconds: 120,
    memory: "1GB"
  },
  async (request) => {
    const apiKey = GEMINI_API_KEY.value();
    const pathUrl = PATH_URL.value();

    if (!apiKey || apiKey.trim() === '' || !pathUrl || pathUrl.trim() === '') {
      throw new HttpsError('internal', 'API credentials not configured');
    }

    const { allEvents, frequency, userSignkey, meetingTitle, timePreferences, numberOfSuggestions, now } = request.data;

    try {
      const prompt = buildMeetingSuggestionPrompt({
        allEvents,
        frequency,
        userSignkey,
        meetingTitle,
        timePreferences,
        numberOfSuggestions,
        now: new Date(now)
      });

      const apiUrl = `${pathUrl}?key=${apiKey}`;
      const requestBody = {
        contents: [{
          parts: [{ text: prompt }]
        }],
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 4096,
        }
      };

      const response = await fetch(apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody)
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new HttpsError('internal', `Gemini API error: ${response.status}`);
      }

      const result = await response.json();

      if (!result.candidates || !result.candidates[0] || !result.candidates[0].content) {
        throw new HttpsError('internal', 'Invalid response format from Gemini API');
      }

      const textResponse = result.candidates[0].content.parts[0].text;
      const parsedResponse = parseMeetingSuggestionResponse(textResponse, numberOfSuggestions);

      return {
        success: true,
        suggestions: parsedResponse.suggestions || [],
        rawResponse: textResponse
      };

    } catch (error) {
      const fallbackSuggestions = generateUniqueFallbackSuggestions(numberOfSuggestions);

      return {
        success: false,
        suggestions: fallbackSuggestions,
        error: error.message,
        isFallback: true
      };
    }
  }
);
function buildMeetingSuggestionPrompt(data) {
  const { allEvents, frequency, meetingTitle, timePreferences, numberOfSuggestions, now } = data;

  const formattedEvents = allEvents.map(event => {
    return `- ${event.date}: ${event.startTime}-${event.endTime} "${event.title}"`;
  }).join('\n');

  const timeRange = timePreferences.hasTimeRange
    ? `Preferred time range: ${timePreferences.preferredStartTime} to ${timePreferences.preferredEndTime}`
    : 'Any time between 08:00 and 20:00';

  const meetingDuration = timePreferences.meetingDuration || 60;

  return `You are an AI meeting scheduler. Analyze the schedule and suggest ${numberOfSuggestions} optimal meeting times.

Return ONLY valid JSON. Do not include any explanations, markdown, or text outside the JSON.

MEETING DETAILS:
- Title: ${meetingTitle}
- Duration: ${meetingDuration} minutes
- Frequency: ${frequency.title} (schedule at least ${frequency.minDaysAhead} days ahead)
- ${timeRange}

SCHEDULE EVENTS:
${formattedEvents}

IMPORTANT:
1. Generate EXACTLY ${numberOfSuggestions} UNIQUE meeting time suggestions
2. Each suggestion must have a DIFFERENT time (not all at the same hour)
3. All dates must be in YYYY-MM-DD format
4. All times must be in 24-hour HH:MM format
5. Avoid Sundays
6. Avoid conflicts with existing events
7. Prefer times within the preferred time range if specified
8. All suggestions must be at least ${frequency.minDaysAhead} days in the future

OUTPUT FORMAT:
{
  "suggestions": [
    {
      "date": "YYYY-MM-DD",
      "time": "HH:MM",
      "score": 85,
      "conflicts": 0,
      "reasoning": "Brief explanation",
      "matchesPreferences": true,
      "foundInGap": true,
      "daysAhead": 7,
      "timetableConflict": false
    }
  ]
}

Current date: ${new Date(now).toISOString().split('T')[0]}
Return ONLY the JSON object above, nothing else.`;
}
function parseMeetingSuggestionResponse(textResponse, expectedCount) {
  try {
    let cleanResponse = textResponse
      .replace(/```json/g, '')
      .replace(/```/g, '')
      .replace(/JSON/g, '')
      .trim();

    let jsonStart = cleanResponse.indexOf('{');
    let jsonEnd = cleanResponse.lastIndexOf('}');

    if (jsonStart === -1 || jsonEnd === -1) {
      jsonStart = cleanResponse.indexOf('[');
      jsonEnd = cleanResponse.lastIndexOf(']');

      if (jsonStart === -1 || jsonEnd === -1) {
        throw new Error('No valid JSON found in response');
      }
    }

    const jsonString = cleanResponse.substring(jsonStart, jsonEnd + 1);
    let parsed = JSON.parse(jsonString);

    let suggestions = [];

    if (Array.isArray(parsed)) {
      suggestions = parsed;
    } else if (parsed.suggestions && Array.isArray(parsed.suggestions)) {
      suggestions = parsed.suggestions;
    } else if (parsed.dates && Array.isArray(parsed.dates)) {
      suggestions = parsed.dates;
    } else if (parsed.meetings && Array.isArray(parsed.meetings)) {
      suggestions = parsed.meetings;
    } else {
      suggestions = [];
    }

    const formattedSuggestions = suggestions.slice(0, expectedCount).map((suggestion, index) => {
      try {
        let dateStr = suggestion.date || suggestion.Date || suggestion.startDate ||
                     suggestion.datetime || suggestion.dateTime;

        if (dateStr && typeof dateStr.toDate === 'function') {
          dateStr = dateStr.toDate().toISOString().split('T')[0];
        }

        if (dateStr && dateStr.includes('T')) {
          dateStr = dateStr.split('T')[0];
        }

        let timeStr = suggestion.time || suggestion.Time || suggestion.startTime ||
                     suggestion.timeSlot || suggestion.slot;

        if (!timeStr && suggestion.datetime) {
          const datetimeParts = suggestion.datetime.split('T');
          if (datetimeParts[1]) {
            timeStr = datetimeParts[1].substring(0, 5);
          }
        }

        if (!dateStr || !timeStr) {
          throw new Error('Missing date or time');
        }

        const dateParts = dateStr.split('-');
        if (dateParts.length !== 3) {
          throw new Error(`Invalid date format: ${dateStr}`);
        }

        const year = parseInt(dateParts[0]);
        const month = parseInt(dateParts[1]) - 1;
        const day = parseInt(dateParts[2]);

        const date = new Date(year, month, day);
        if (isNaN(date.getTime())) {
          throw new Error(`Invalid date: ${dateStr}`);
        }

        const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
        if (!timeRegex.test(timeStr)) {
          timeStr = timeStr.replace(/[^\d:]/g, '');
          if (!timeRegex.test(timeStr)) {
            throw new Error(`Invalid time format: ${timeStr}`);
          }
        }

        const now = new Date();
        const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        const suggestionDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        const daysAhead = Math.floor((suggestionDate - today) / (1000 * 60 * 60 * 24));

        if (daysAhead < 0) {
          throw new Error('Date is in the past');
        }

        return {
          date: dateStr,
          time: timeStr,
          score: suggestion.score || suggestion.rating || suggestion.priority ||
                suggestion.confidence || (80 - (index * 10)),
          conflicts: suggestion.conflicts || suggestion.conflictCount || 0,
          reasoning: suggestion.reasoning || suggestion.explanation ||
                    suggestion.reason || `Optimal time suggestion ${index + 1}`,
          matchesPreferences: suggestion.matchesPreferences || suggestion.prefMatch ||
                            suggestion.preferred || false,
          preferenceMatches: Array.isArray(suggestion.preferenceMatches) ?
                           suggestion.preferenceMatches :
                           (suggestion.preferenceMatches ? [suggestion.preferenceMatches] : []),
          foundInGap: suggestion.foundInGap || suggestion.gap || false,
          daysAhead: daysAhead,
          timetableConflict: suggestion.timetableConflict || false
        };

      } catch (error) {
        const fallbackDate = new Date(Date.now() + (index + 1) * 24 * 60 * 60 * 1000);
        return {
          date: fallbackDate.toISOString().split('T')[0],
          time: `${(9 + (index % 4)).toString().padStart(2, '0')}:${(index * 15) % 60}`,
          score: 50,
          conflicts: 0,
          reasoning: `Fallback suggestion ${index + 1}`,
          matchesPreferences: false,
          preferenceMatches: [],
          foundInGap: false,
          daysAhead: index + 1,
          timetableConflict: false
        };
      }
    });

    while (formattedSuggestions.length < expectedCount) {
      const index = formattedSuggestions.length;
      const fallbackDate = new Date(Date.now() + (index + 1) * 24 * 60 * 60 * 1000);

      formattedSuggestions.push({
        date: fallbackDate.toISOString().split('T')[0],
        time: `${(10 + (index % 4)).toString().padStart(2, '0')}:${(index * 20) % 60}`,
        score: 40,
        conflicts: 0,
        reasoning: `Additional fallback suggestion ${index + 1}`,
        matchesPreferences: false,
        preferenceMatches: [],
        foundInGap: false,
        daysAhead: index + 1,
        timetableConflict: false
      });
    }

    const uniqueSuggestions = ensureUniqueTimes(formattedSuggestions.slice(0, expectedCount));
    return { suggestions: uniqueSuggestions };

  } catch (e) {
    const uniqueFallbackSuggestions = generateUniqueFallbackSuggestions(expectedCount);
    return { suggestions: uniqueFallbackSuggestions };
  }
}
function ensureUniqueTimes(suggestions) {
  const timeMap = new Map();
  const uniqueSuggestions = [];

  for (const suggestion of suggestions) {
    const timeKey = `${suggestion.date}-${suggestion.time}`;
    if (!timeMap.has(timeKey)) {
      timeMap.set(timeKey, true);
      uniqueSuggestions.push(suggestion);
    } else {
      const newTime = generateAlternateTime(suggestion.time, uniqueSuggestions.length);
      uniqueSuggestions.push({
        ...suggestion,
        time: newTime,
        reasoning: `${suggestion.reasoning} (time adjusted for uniqueness)`
      });
    }
  }

  return uniqueSuggestions;
}
function generateAlternateTime(originalTime, index) {
  const [hour, minute] = originalTime.split(':').map(Number);
  const newHour = (hour + Math.floor(index / 2)) % 24;
  const newMinute = (minute + (index * 15)) % 60;
  return `${newHour.toString().padStart(2, '0')}:${newMinute.toString().padStart(2, '0')}`;
}
function generateUniqueFallbackSuggestions(count) {
  const suggestions = [];
  const usedTimes = new Set();

  for (let i = 0; i < count; i++) {
    let timeStr;
    let attempts = 0;

    do {
      const hour = 9 + Math.floor(i / 2) + (attempts % 3);
      const minute = (i * 15 + attempts * 5) % 60;
      timeStr = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
      attempts++;
    } while (usedTimes.has(timeStr) && attempts < 10);

    usedTimes.add(timeStr);

    const date = new Date(Date.now() + (i + 1) * 24 * 60 * 60 * 1000);
    const dayName = date.toLocaleDateString('en-US', { weekday: 'short' });

    suggestions.push({
      date: date.toISOString().split('T')[0],
      time: timeStr,
      score: 70 - (i * 5),
      conflicts: 0,
      reasoning: `${dayName} at ${timeStr}, ${i + 1} days ahead`,
      matchesPreferences: false,
      preferenceMatches: [],
      foundInGap: false,
      daysAhead: i + 1,
      timetableConflict: false
    });
  }

  return suggestions;
}
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
//    timeZone: "Africa/Johannesburg",
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
  try {
    const utcDate = new Date(
      dateTime.getTime() + dateTime.getTimezoneOffset() * 60000
    );

    return utcDate.toLocaleString("en-ZA", {
      weekday: "short",
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  } catch (e) {
    return dateTime
      .toISOString()
      .replace("T", " ")
      .substring(0, 16);
  }
}