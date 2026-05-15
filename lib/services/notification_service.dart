import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rozgar/models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging? _messaging;

  Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      _messaging = FirebaseMessaging.instance;
      await _messaging!.requestPermission();
      await _messaging!.getToken();
    } catch (e) {
      debugPrint('FCM not available: $e');
    }
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
