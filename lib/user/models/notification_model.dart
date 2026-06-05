import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String targetId;
  final bool isRead;
  final Timestamp? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetId = '',
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      type: d['type'] as String? ?? 'application',
      targetId: d['targetId'] as String? ?? '',
      isRead: d['isRead'] as bool? ?? false,
      createdAt: d['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'body': body,
        'type': type,
        'targetId': targetId,
        'isRead': isRead,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
