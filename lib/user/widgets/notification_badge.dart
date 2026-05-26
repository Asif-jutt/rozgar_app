import 'package:flutter/material.dart';
import 'package:rozgar/user/providers/notification_service.dart';
import 'package:rozgar/user/models/app_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const NotificationBadgeIcon({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: onPressed ?? () {},
      );
    }

    return StreamBuilder<List<AppNotification>>(
      stream: NotificationService().userNotifications(user.uid),
      builder: (context, snapshot) {
        int unreadCount = 0;
        if (snapshot.hasData && snapshot.data != null) {
          unreadCount = snapshot.data!.where((n) => !n.read).length;
        }

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: onPressed ?? () {},
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
