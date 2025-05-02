const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// دالة إرسال الإشعارات
async function sendNotification(token, title, body, data = {}) {
  const message = {
    notification: {
      title,
      body,
    },
    data,
    token,
  };

  try {
    await admin.messaging().send(message);
    console.log('Notification sent successfully');
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

// الحصول على توكن FCM للمطعم
async function getRestaurantToken(restaurantId) {
  try {
    const restaurantDoc = await admin
      .firestore()
      .collection('restaurants')
      .doc(restaurantId)
      .get();

    return restaurantDoc.data()?.fcmToken;
  } catch (error) {
    console.error('Error getting restaurant token:', error);
    return null;
  }
}

// مراقبة إضافة طلبات جديدة
exports.onNewOrder = functions.firestore
  .document('restaurants/{restaurantId}/orders/{orderId}')
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    const restaurantId = context.params.restaurantId;

    // الحصول على توكن FCM للمطعم
    const token = await getRestaurantToken(restaurantId);
    if (!token) return;

    // إعداد بيانات الإشعار
    const title = 'طلب جديد';
    const body = `طلب جديد من ${orderData.customerName || 'عميل'} - ${orderData.totalAmount} ريال`;
    const data = {
      type: 'order',
      orderId: snap.id,
      status: orderData.status,
    };

    // إرسال الإشعار
    await sendNotification(token, title, body, data);
  });

// مراقبة إضافة حجوزات جديدة
exports.onNewReservation = functions.firestore
  .document('restaurants/{restaurantId}/reservations/{reservationId}')
  .onCreate(async (snap, context) => {
    const reservationData = snap.data();
    const restaurantId = context.params.restaurantId;

    // الحصول على توكن FCM للمطعم
    const token = await getRestaurantToken(restaurantId);
    if (!token) return;

    // إعداد بيانات الإشعار
    const title = 'حجز جديد';
    const body = `حجز جديد من ${reservationData.customerName} - ${reservationData.numberOfGuests} ضيوف`;
    const data = {
      type: 'reservation',
      reservationId: snap.id,
      status: reservationData.status,
    };

    // إرسال الإشعار
    await sendNotification(token, title, body, data);
  }); 