import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/models/notification_model.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('NAV: NotificationsScreen');
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text('Not signed in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              final snap = await FirebaseFirestore.instance
                  .collection(FirebaseCollections.notifications)
                  .doc(uid)
                  .collection('items')
                  .where('isRead', isEqualTo: false)
                  .get();
              final batch = FirebaseFirestore.instance.batch();
              for (final doc in snap.docs) {
                batch.update(doc.reference, {'isRead': true});
              }
              await batch.commit();
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirebaseCollections.notifications)
            .doc(uid)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final n = NotificationModel.fromFirestore(snap.data!.docs[i]);
              return ListTile(
                tileColor: n.isRead
                    ? null
                    : AppColors.primary.withValues(alpha: 0.1),
                leading: Icon(_iconForType(n.type)),
                title: Text(n.title,
                    style: TextStyle(
                        fontWeight:
                            n.isRead ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n.body),
                onTap: () async {
                  await snap.data!.docs[i].reference.update({'isRead': true});
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'job_match':
        return Icons.work;
      case 'status_update':
        return Icons.update;
      default:
        return Icons.notifications;
    }
  }
}
