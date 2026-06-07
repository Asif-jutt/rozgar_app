import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/models/job_comment.dart';
import 'package:rozgar/services/social_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class JobCommentsSection extends StatefulWidget {
  final String jobId;

  const JobCommentsSection({super.key, required this.jobId});

  @override
  State<JobCommentsSection> createState() => _JobCommentsSectionState();
}

class _JobCommentsSectionState extends State<JobCommentsSection> {
  final _ctrl = TextEditingController();
  final _social = SocialService.instance;
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await _social.addComment(
        jobId: widget.jobId,
        userId: user.uid,
        userName: user.displayName ?? 'User',
        text: _ctrl.text,
      );
      _ctrl.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: AppTextStyles.headline4),
        const SizedBox(height: 12),
        if (uid != null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLarge),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          )
        else
          Text('Login to comment', style: AppTextStyles.bodySmall),
        const SizedBox(height: 16),
        StreamBuilder<List<JobComment>>(
          stream: _social.commentsStream(widget.jobId),
          builder: (context, snap) {
            final comments = snap.data ?? [];
            if (comments.isEmpty) {
              return Text('No comments yet.', style: AppTextStyles.bodySmall);
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = comments[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                    title: Text(c.userName, style: AppTextStyles.labelMedium),
                    subtitle: Text(c.text),
                    trailing: c.userId == uid
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () => _social.deleteComment(c.id),
                          )
                        : Text(
                            _timeAgo(c.createdAt),
                            style: AppTextStyles.labelSmall,
                          ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }
}
