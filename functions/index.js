const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

/**
 * Triggered when a new alert document is created in Firestore.
 * Sends a push notification to all users in the affected region.
 */
exports.onNewAlert = functions.firestore
  .document("alerts/{alertId}")
  .onCreate(async (snap, context) => {
    const alert = snap.data();
    const { type, severity, message, region } = alert;

    // Fetch all users in the affected region
    const usersSnap = await db
      .collection("users")
      .where("village", "==", region)
      .get();

    if (usersSnap.empty) {
      console.log(`No users found in region: ${region}`);
      return null;
    }

    // Collect FCM tokens
    const tokens = [];
    usersSnap.forEach((doc) => {
      const token = doc.data().fcmToken;
      if (token) tokens.push(token);
    });

    if (tokens.length === 0) {
      console.log("No FCM tokens found.");
      return null;
    }

    const severityEmoji = severity === "high" ? "🚨" : severity === "medium" ? "⚠️" : "ℹ️";
    const typeLabel = type.charAt(0).toUpperCase() + type.slice(1);

    const multicastMessage = {
      tokens,
      notification: {
        title: `${severityEmoji} ${typeLabel} Alert – ${region}`,
        body: message,
      },
      data: {
        type: "alert",
        alertId: context.params.alertId,
        severity,
        region,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "climagrowth_channel",
          sound: "default",
          priority: "high",
          vibrateTimingsMillis: [0, 250, 250, 250],
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    const response = await messaging.sendEachForMulticast(multicastMessage);
    console.log(
      `Alert sent: ${response.successCount} success, ${response.failureCount} failed`
    );
    return null;
  });

/**
 * Scheduled function: send daily irrigation reminder at 6 AM IST.
 * Runs every day at 00:30 UTC (= 06:00 IST).
 */
exports.dailyIrrigationReminder = functions.pubsub
  .schedule("30 0 * * *")
  .timeZone("Asia/Kolkata")
  .onRun(async (_context) => {
    const usersSnap = await db.collection("users").get();
    const tokens = [];

    usersSnap.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken && data.notifIrrigation !== false) {
        tokens.push(data.fcmToken);
      }
    });

    if (tokens.length === 0) return null;

    const chunks = chunkArray(tokens, 500); // FCM limit per multicast
    for (const chunk of chunks) {
      await messaging.sendEachForMulticast({
        tokens: chunk,
        notification: {
          title: "💧 Morning Irrigation Reminder",
          body: "Check your soil moisture before irrigating today's crops.",
        },
        data: { type: "irrigation_reminder" },
      });
    }

    console.log(`Irrigation reminders sent to ${tokens.length} users.`);
    return null;
  });

/**
 * HTTP endpoint: seed mock market prices (call once during setup).
 */
exports.seedMarketPrices = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const prices = [
    { crop: "Cotton", mandi: "Vadodara APMC", price: 6850, region: "Vadodara" },
    { crop: "Cotton", mandi: "Padra Mandi", price: 6500, region: "Padra" },
    { crop: "Wheat", mandi: "Vadodara APMC", price: 2150, region: "Vadodara" },
    { crop: "Tomato", mandi: "Padra Mandi", price: 1200, region: "Padra" },
    { crop: "Groundnut", mandi: "Vadodara APMC", price: 5200, region: "Vadodara" },
  ];

  const batch = db.batch();
  prices.forEach((p) => {
    const ref = db.collection("marketPrices").doc();
    batch.set(ref, { ...p, date: admin.firestore.FieldValue.serverTimestamp() });
  });

  await batch.commit();
  res.status(200).json({ message: `${prices.length} market prices seeded.` });
});

// ── Helpers ───────────────────────────────────────────────────────────────────
function chunkArray(arr, size) {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
}
