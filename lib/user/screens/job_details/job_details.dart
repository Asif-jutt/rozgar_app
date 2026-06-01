import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/screens/chat/chat_screen.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';

import 'package:rozgar/user/widgets/job_comments_section.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirestoreService _firestore = FirestoreService();
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _recordImpression();
  }

  Future<void> _recordImpression() async {
    await _firestore.incrementJobImpression(widget.job.jobId);
  }

  void _showApplyForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (await _firestore.hasUserApplied(
      userId: user.uid,
      jobId: widget.job.jobId,
    )) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Already applied.')));
      return;
    }

    final profile = await _firestore.getUserProfile(user.uid);
    final userDoc = await _firestore.getUser(user.uid);

    final _formKey = GlobalKey<FormState>();
    String name = userDoc?.name ?? '';
    String email = userDoc?.email ?? '';
    String phone = profile?.phone ?? '';
    String university = '';
    String semester = '';
    String resumeLink = profile?.cvResumeUrl ?? '';

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Apply for Job', style: AppTextStyles.headline3),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => name = v ?? '',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => email = v ?? '',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => phone = v ?? '',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'University',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => university = v ?? '',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => semester = v ?? '',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: resumeLink,
                    decoration: const InputDecoration(
                      labelText: 'Resume Link (Drive/Drive)',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (v) => resumeLink = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Navigator.pop(context); // close sheet
                        await _processApply(
                          user.uid,
                          name,
                          email,
                          phone,
                          university,
                          semester,
                          resumeLink,
                        );
                      }
                    },
                    child: const Text('Submit Application'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _processApply(
    String uid,
    String name,
    String email,
    String phone,
    String university,
    String semester,
    String resumeLink,
  ) async {
    setState(() => _isApplying = true);
    try {
      await _firestore.applyToJob(
        jobId: widget.job.jobId,
        userId: uid,
        companyId: widget.job.companyId,
        jobTitle: widget.job.title,
        applicantName: name,
        resumeText: resumeLink,
        email: email,
        phone: phone,
        university: university,
        semester: semester,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Job Details', showBackButton: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobBannerImage(
              imageUrl: job.imageUrl,
              category: job.category,
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title, style: AppTextStyles.headline2),
                  const SizedBox(height: 6),
                  Text(
                    job.companyName ?? 'Company',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _infoChip(Icons.location_on, job.location),
                      const SizedBox(width: 8),
                      _infoChip(Icons.payments, job.salary),
                      const SizedBox(width: 8),
                      _infoChip(Icons.category, job.category),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: AppTextStyles.headline4),
                  const SizedBox(height: 8),
                  Text(job.description, style: AppTextStyles.bodyMedium),
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(job.jobId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          int likesCount = job.likes.length;
                          bool isLiked = false;
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final List currentLikes = data['likes'] ?? [];
                            likesCount = currentLikes.length;
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              isLiked = currentLikes.contains(uid);
                            }
                          }
                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                                onPressed: () {
                                  final uid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (uid == null) {
                                    Navigator.pushNamed(context, '/login');
                                    return;
                                  }
                                  _firestore.toggleJobLike(job.jobId, uid);
                                },
                              ),
                              Text(
                                '$likesCount Likes',
                                style: AppTextStyles.labelMedium,
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('jobs')
                            .doc(job.jobId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          int views = job.impressions;
                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            views = data['impressions'] ?? 0;
                          }
                          return Text(
                            '$views Views',
                            style: AppTextStyles.labelMedium,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.applyNow,
                          isLoading: _isApplying,
                          onPressed:  _showApplyForm,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLarge,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (FirebaseAuth.instance.currentUser == null) {
                              Navigator.pushNamed(context, '/login');
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  currentUserId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  otherUserId: job.companyId,
                                  otherUserName: job.companyName ?? 'Company',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  JobCommentsSection(jobId: job.jobId, isCompany: false),
                  const SizedBox(height: 32),
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
}
