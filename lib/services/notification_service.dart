import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/firebase_options.dart';
import 'package:rozgar/models/app_notification.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.info('FCM background: ${message.notification?.title}');
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      _messaging = FirebaseMessaging.instance;
      await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (_) {},
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      await _messaging!.getToken();
      AppLogger.info('NotificationService initialized');
    } catch (e, st) {
      AppLogger.error('NotificationService init failed', e, st);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _showLocalNotification(
      title: notification.title ?? 'Rozgar',
      body: notification.body ?? '',
    );
  }

  void _onMessageOpened(RemoteMessage message) {
    AppLogger.info('Notification opened: ${message.data}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rozgar_channel',
        'Rozgar Notifications',
        channelDescription: 'Job portal alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> saveFcmToken(String userId) async {
    if (kIsWeb || _messaging == null) return;
    try {
      final token = await _messaging!.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'fcmUpdatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      AppLogger.info('FCM token saved for $userId');
    } catch (e, st) {
      AppLogger.error('saveFcmToken failed', e, st);
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'application',
    String? relatedId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'relatedId': relatedId,
      'createdAt': DateTime.now().toIso8601String(),
    });

    if (!kIsWeb) {
      await _showLocalNotification(title: title, body: body);
    }
  }

  Stream<List<AppNotification>> userNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotification.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
