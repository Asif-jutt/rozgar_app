import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/models/conversation.dart';
import 'package:rozgar/screens/messaging/chat_screen.dart';
import 'package:rozgar/services/messaging_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final service = MessagingService.instance;

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.messages,
        showBackButton: true,
      ),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<Conversation>>(
              stream: service.conversationsStream(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data ?? [];
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No conversations yet',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Message a company from a job listing',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primaryColor.withValues(alpha: 0.15),
                          child: Text(
                            c.displayNameFor(uid)[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(c.displayNameFor(uid),
                            style: AppTextStyles.labelLarge),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.jobTitle != null)
                              Text(c.jobTitle!,
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primaryColor)),
                            Text(
                              c.lastMessage.isEmpty
                                  ? 'Start chatting'
                                  : c.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Text(
                          _timeAgo(c.updatedAt),
                          style: AppTextStyles.labelSmall,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(conversation: c),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }
}
