import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_routes.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: _onTap,
    );

    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen(_handleForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleTap(initial);
  }

  Future<String?> getToken() => _fcm.getToken();

  void _handleForeground(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final channel = message.data['type'] == 'job_match' ? 'jobs' : 'applications';
    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel == 'jobs' ? 'Job Alerts' : 'Application Updates',
          importance: channel == 'applications'
              ? Importance.max
              : Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['type'],
    );
    _saveToFirestore(message);
  }

  void _handleTap(RemoteMessage message) {
    final type = message.data['type'] as String? ?? '';
    switch (type) {
      case 'application':
      case 'status_update':
        Get.toNamed(AppRoutes.userApplications);
      case 'job_match':
        Get.toNamed(AppRoutes.userFeed);
      case 'job_approved':
      case 'job_rejected':
        Get.toNamed(AppRoutes.companyMyJobs);
      default:
        Get.toNamed(AppRoutes.userNotifications);
    }
  }

  void _onTap(NotificationResponse response) {
    final type = response.payload ?? '';
    _handleTap(RemoteMessage(data: {'type': type}));
  }

  Future<void> _saveToFirestore(RemoteMessage message) async {
    final uid = message.data['uid'];
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.notifications)
        .doc(uid)
        .collection('items')
        .add({
      'title': message.notification?.title ?? '',
      'body': message.notification?.body ?? '',
      'type': message.data['type'] ?? 'application',
      'targetId': message.data['targetId'] ?? '',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendNotificationToUser({
    required String targetFcmToken,
    required String title,
    required String body,
    required String type,
    required String targetId,
  }) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.notificationsQueue)
        .add({
      'to': targetFcmToken,
      'title': title,
      'body': body,
      'type': type,
      'targetId': targetId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
