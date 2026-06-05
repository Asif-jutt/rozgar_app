const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendQueuedNotification = functions.firestore
  .document('notifications_queue/{id}')
  .onCreate(async (snap) => {
    const data = snap.data();
    if (!data.to) return null;
    await admin.messaging().send({
      token: data.to,
      notification: { title: data.title, body: data.body },
      data: { type: data.type || '', targetId: data.targetId || '' },
    });
    return snap.ref.delete();
  });

exports.verifyPurchase = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') return res.status(405).send('Method not allowed');
  const { uid, productId } = req.body;
  if (productId === 'rozgar_premium_monthly' && uid) {
    await admin.firestore().collection('users').doc(uid).update({ isPremium: true });
    return res.json({ valid: true });
  }
  return res.json({ valid: false });
});
