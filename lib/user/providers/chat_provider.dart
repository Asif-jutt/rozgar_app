import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import 'package:rozgar/core/encryption_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time message stream
  Stream<List<Message>> getChatMessages(
    String currentUserId,
    String otherUserId,
  ) {
    String roomId = _getChatRoomId(currentUserId, otherUserId);

    return _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            var msgMap = doc.data();
            // Decrypt message content
            if (msgMap['content'] != null) {
              msgMap['content'] = EncryptionService.decryptMessage(
                msgMap['content'] as String,
              );
            }
            return Message.fromMap(msgMap, doc.id);
          }).toList(),
        );
  }

  // Send a message
  Future<void> sendMessage(
    String currentUserId,
    String otherUserId,
    String content,
  ) async {
    String roomId = _getChatRoomId(currentUserId, otherUserId);

    // Encrypt message content before saving
    String encryptedContent = EncryptionService.encryptMessage(content);

    final message = Message(
      id: '',
      senderId: currentUserId,
      receiverId: otherUserId,
      content: encryptedContent,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('chatRooms').doc(roomId).set({
      'userIds': [currentUserId, otherUserId],
      'lastMessage': encryptedContent,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
  }

  String _getChatRoomId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }
}
