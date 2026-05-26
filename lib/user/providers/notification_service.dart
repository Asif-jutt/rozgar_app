import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rozgar/user/models/app_notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  List<RemoteMessage> localNotifications = [];

  // Pass a callback or a Navigator key to handle navigation in real scale.
  // For now, we remove BuildContext to allow initialization in main.dart
  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      // 1. Request Permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted permission');
      }

      // 2. Configure Local Notifications
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosInit =
          DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle tapping on local notification
          _handleNotificationTap(details.payload);
        },
      );

      // 3. Background handler Registration
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 4. Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Received foreground message: ${message.notification?.title}');
        localNotifications.add(message);
        _showLocalNotification(message);
      });

      // 5. Tapped from Background/Terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message.data['route']);
      });
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'job_portal_channel',
          'Job Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['route'], // payload data for routing
    );
  }

  void _handleNotificationTap(String? route) {
    if (route != null) {
      log('Notification tapped, route: $route');
      // To properly navigate from main.dart, use a global navigator key
      // or handle the route when the app is ready.
    }
  }

  Future<void> saveFcmToken(String userId) async {
    if (kIsWeb) return;
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'fcmUpdatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveFcmToken: $e');
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
  }

  Stream<List<AppNotification>> userNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => AppNotification.fromFirestore(d.id, d.data()))
              .toList(),
        );
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
