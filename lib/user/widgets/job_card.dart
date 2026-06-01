import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/company/models/comment_model.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';
import 'package:intl/intl.dart';

class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback onApplyPressed;
  final VoidCallback onCardPressed;

  const JobCard({
    super.key,
    required this.job,
    required this.onApplyPressed,
    required this.onCardPressed,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final FirestoreService _firestore = FirestoreService();
  bool _likeLoading = false;

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _toggleLike() async {
    if (_currentUid.isEmpty) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    setState(() => _likeLoading = true);
    try {
      await _firestore.toggleLike(widget.job.jobId, _currentUid);
    } finally {
      if (mounted) setState(() => _likeLoading = false);
    }
  }

  void _openComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StandaloneCommentsPage(
          job: widget.job,
          firestore: _firestore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobModel>>(
      stream: _firestore.companyJobsStream(widget.job.companyId),
      builder: (context, snap) {
        JobModel job = widget.job;
        if (snap.hasData) {
          final found = snap.data!
              .where((j) => j.jobId == widget.job.jobId);
          if (found.isNotEmpty) job = found.first;
        }

        final isLiked = job.likes.contains(_currentUid);

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusLarge),
          ),
          child: InkWell(
            onTap: widget.onCardPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                JobBannerImage(
                  imageUrl: job.imageUrl,
                  category: job.category,
                  height: 120,
                ),
                Padding(
                  padding:
                      const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + category badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.title,
                              style: AppTextStyles.headline4,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              job.category,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Company name + posted date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            job.companyName ?? 'Company',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (job.postedAt != null)
                            Text(
                              DateFormat('MMM dd, hh:mm a')
                                  .format(job.postedAt!.toLocal()),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Location + salary
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppColors.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(job.location,
                                style: AppTextStyles.bodySmall),
                          ),
                          const Icon(Icons.payments,
                              size: 16, color: AppColors.successColor),
                          const SizedBox(width: 4),
                          Text(job.salary,
                              style: AppTextStyles.labelSmall),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Skills chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: job.requirementList
                            .take(3)
                            .map(
                              (s) => Chip(
                                label: Text(s,
                                    style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor:
                                    AppColors.primaryLight.withValues(alpha: 0.1),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      // Like + comment row
                      Row(
                        children: [
                          _likeLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : InkWell(
                                  onTap: _toggleLike,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isLiked
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_alt_outlined,
                                          size: 18,
                                          color: isLiked
                                              ? AppColors.primaryColor
                                              : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${job.likes.length} Like${job.likes.length == 1 ? '' : 's'}',
                                          style:
                                              AppTextStyles.labelSmall.copyWith(
                                            color: isLiked
                                                ? AppColors.primaryColor
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: _openComments,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.comment_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${job.commentsCount} Comment${job.commentsCount == 1 ? '' : 's'}',
                                    style: AppTextStyles.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onApplyPressed,
                          child: const Text(AppStrings.applyNow),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── STANDALONE COMMENTS PAGE (from job card) ────────────────────────────────

class _StandaloneCommentsPage extends StatefulWidget {
  final JobModel job;
  final FirestoreService firestore;

  const _StandaloneCommentsPage(
      {required this.job, required this.firestore});

  @override
  State<_StandaloneCommentsPage> createState() =>
      _StandaloneCommentsPageState();
}

class _StandaloneCommentsPageState
    extends State<_StandaloneCommentsPage> {
  final TextEditingController _ctrl = TextEditingController();
  bool _submitting = false;

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    final userDoc = await widget.firestore.getUser(user.uid);
    final userName =
        userDoc?.name ?? user.displayName ?? 'User';
    setState(() => _submitting = true);
    try {
      await widget.firestore.addComment(
        widget.job.jobId,
        CommentModel(
          id: '',
          userId: user.uid,
          userName: userName,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
      _ctrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Comments – ${widget.job.title}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CommentModel>>(
              stream: widget.firestore.commentsStream(widget.job.jobId),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('No comments yet. Be the first!'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    final c = comments[i];
                    final isOwn = c.userId == _currentUid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primaryColor
                                .withValues(alpha: 0.15),
                            child: Text(
                              c.userName.isNotEmpty
                                  ? c.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(c.userName,
                                        style:
                                            AppTextStyles.labelMedium),
                                    const Spacer(),
                                    Text(
                                      DateFormat('MMM dd, hh:mm a')
                                          .format(c.timestamp),
                                      style:
                                          AppTextStyles.labelSmall,
                                    ),
                                    if (isOwn)
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            size: 16,
                                            color:
                                                AppColors.errorColor),
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints(),
                                        onPressed: () async {
                                          await widget.firestore
                                              .deleteComment(
                                                  widget.job.jobId,
                                                  c.id);
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(c.content,
                                      style: AppTextStyles.bodySmall),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 8),
                _submitting
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                    : CircleAvatar(
                        backgroundColor: AppColors.primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.send,
                              color: Colors.white, size: 18),
                          onPressed: _submit,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}