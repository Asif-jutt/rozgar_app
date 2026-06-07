import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/models/conversation.dart';
import 'package:rozgar/user/models/feed_job.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/screens/messaging/chat_screen.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/services/messaging_service.dart';
import 'package:rozgar/services/social_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/core/widgets/job_comments_section.dart';
import 'package:rozgar/core/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel? job;
  final FeedJob? feedJob;

  const JobDetailsScreen({super.key, this.job, this.feedJob})
      : assert(job != null || feedJob != null);

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final SocialService _social = SocialService.instance;
  final MessagingService _messaging = MessagingService.instance;
  bool _isApplying = false;
  bool _isMessaging = false;

  FeedJob get _feed =>
      widget.feedJob ?? FeedJob.local(widget.job!);

  JobModel get _jobModel => _feed.toJobModel();

  Future<void> _apply() async {
    if (_feed.isApi) {
      final uri = Uri.tryParse(_feed.externalUrl ?? '');
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _isApplying = true);
    try {
      if (await _firestore.hasUserApplied(
        userId: user.uid,
        jobId: _feed.id,
      )) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already applied.')),
        );
        return;
      }

      final profile = await _firestore.getUserProfile(user.uid);
      final userDoc = await _firestore.getUser(user.uid);

      await _firestore.applyToJob(
        jobId: _feed.id,
        userId: user.uid,
        companyId: _feed.companyId!,
        jobTitle: _feed.title,
        applicantName: userDoc?.name ?? 'Applicant',
        resumeText: profile?.cvResumeUrl ?? '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted!'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _messageCompany() async {
    final user = FirebaseAuth.instance.currentUser;
    final companyId = _feed.companyId;
    if (user == null || companyId == null || companyId.isEmpty) return;

    setState(() => _isMessaging = true);
    try {
      final userDoc = await _firestore.getUser(user.uid);
      final companyDoc = await _firestore.getUser(companyId);

      final convId = await _messaging.getOrCreateConversation(
        seekerId: user.uid,
        companyId: companyId,
        seekerName: userDoc?.name ?? user.displayName ?? 'Seeker',
        companyName: companyDoc?.name ?? _feed.companyName,
        jobId: _feed.id,
        jobTitle: _feed.title,
      );

      if (!mounted) return;
      final conv = Conversation(
        id: convId,
        participantIds: [user.uid, companyId],
        seekerId: user.uid,
        companyId: companyId,
        seekerName: userDoc?.name ?? 'Seeker',
        companyName: companyDoc?.name ?? _feed.companyName,
        jobId: _feed.id,
        jobTitle: _feed.title,
        lastMessage: '',
        updatedAt: DateTime.now(),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
      );
    } finally {
      if (mounted) setState(() => _isMessaging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _jobModel;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Job Details',
        showBackButton: true,
        actions: uid != null
            ? [
                StreamBuilder<bool>(
                  stream: _social.isLikedStream(_feed.id, uid),
                  builder: (context, snap) {
                    final liked = snap.data ?? false;
                    return IconButton(
                      icon: Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? AppColors.errorColor : Colors.white,
                      ),
                      onPressed: () => _social.toggleLike(_feed.id, uid),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                JobBannerImage(
                  imageUrl: job.imageUrl,
                  category: job.category,
                  height: 200,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _feed.isApi
                          ? AppColors.infoColor
                          : AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _feed.sourceLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _feed.isApi
                            ? Colors.white
                            : AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: AppTextStyles.headline2),
                  const SizedBox(height: 6),
                  Text(job.companyName ?? 'Company',
                      style: AppTextStyles.labelLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip(Icons.location_on, job.location),
                      _infoChip(Icons.payments, job.salary),
                      _infoChip(Icons.category, job.category),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      StreamBuilder<int>(
                        stream: _social.likeCountStream(_feed.id),
                        builder: (context, snap) => _statChip(
                          Icons.favorite,
                          '${snap.data ?? 0} likes',
                        ),
                      ),
                      const SizedBox(width: 8),
                      StreamBuilder(
                        stream: _social.commentsStream(_feed.id),
                        builder: (context, snap) => _statChip(
                          Icons.comment,
                          '${snap.data?.length ?? 0} comments',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: AppTextStyles.headline4),
                  const SizedBox(height: 8),
                  Text(
                    job.description.isEmpty
                        ? 'No description provided.'
                        : job.description,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Text('Requirements', style: AppTextStyles.headline4),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.requirementList
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _feed.isApi ? 'View on Remotive' : AppStrings.applyNow,
                    isLoading: _isApplying,
                    onPressed: _apply,
                  ),
                  if (_feed.isLocal &&
                      _feed.companyId != null &&
                      _feed.companyId!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isMessaging ? null : _messageCompany,
                      icon: _isMessaging
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chat),
                      label: const Text('Message Company'),
                    ),
                  ],
                  const SizedBox(height: 32),
                  JobCommentsSection(jobId: _feed.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
