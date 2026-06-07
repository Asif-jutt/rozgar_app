import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/user/models/chat_message.dart';
import 'package:rozgar/user/models/conversation.dart';
import 'package:rozgar/services/notification_service.dart';

class MessagingService {
  MessagingService._();
  static final MessagingService instance = MessagingService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String conversationId(String seekerId, String companyId) {
    final ids = [seekerId, companyId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> getOrCreateConversation({
    required String seekerId,
    required String companyId,
    required String seekerName,
    required String companyName,
    String? jobId,
    String? jobTitle,
  }) async {
    final id = conversationId(seekerId, companyId);
    final ref = _db.collection('conversations').doc(id);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'participantIds': [seekerId, companyId],
        'seekerId': seekerId,
        'companyId': companyId,
        'seekerName': seekerName,
        'companyName': companyName,
        if (jobId != null) 'jobId': jobId,
        if (jobTitle != null) 'jobTitle': jobTitle,
        'lastMessage': '',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
    return id;
  }

  Stream<List<Conversation>> conversationsStream(String userId) {
    return _db
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Conversation.fromMap(d.id, d.data()))
            .toList());
  }

  Stream<List<ChatMessage>> messagesStream(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => ChatMessage.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
    required String recipientId,
  }) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final msgRef = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    await msgRef.set({
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text.trim(),
      'createdAt': now.toIso8601String(),
      'read': false,
    });

    await _db.collection('conversations').doc(conversationId).update({
      'lastMessage': text.trim(),
      'updatedAt': now.toIso8601String(),
    });

    await NotificationService().sendNotification(
      userId: recipientId,
      title: 'New message from $senderName',
      body: text.trim(),
      type: 'message',
      relatedId: conversationId,
    );

    AppLogger.info('Message sent in $conversationId');
  }

  Future<void> markMessagesRead(String conversationId, String readerId) async {
    final snap = await _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.data()['senderId'] != readerId) {
        batch.update(doc.reference, {'read': true});
      }
    }
    await batch.commit();
  }
}
