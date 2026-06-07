import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/models/app_notification.dart';
import 'package:rozgar/services/notification_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = NotificationService();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        actions: uid != null
            ? [
                TextButton(
                  onPressed: () => service.markAllRead(uid),
                  child: const Text('Mark all read',
                      style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
      ),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<AppNotification>>(
              stream: service.userNotifications(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No notifications yet',
                            style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final n = items[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: n.read ? Colors.white : AppColors.primaryColor.withValues(alpha: 0.05),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n.read
                              ? Colors.grey.shade200
                              : AppColors.primaryColor,
                          child: Icon(
                            Icons.notifications,
                            color: n.read ? Colors.grey : Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(n.title, style: AppTextStyles.labelMedium),
                        subtitle: Text(n.body),
                        trailing: Text(
                          _timeAgo(n.createdAt),
                          style: AppTextStyles.labelSmall,
                        ),
                        onTap: () => service.markAsRead(n.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}
