import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/models/job_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/widgets/network_image_widget.dart';

class JobDetailsScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirestoreService _firestore = FirestoreService();
  bool _isApplying = false;

  Future<void> _apply() async {
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
        jobId: widget.job.jobId,
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
        jobId: widget.job.jobId,
        userId: user.uid,
        companyId: widget.job.companyId,
        jobTitle: widget.job.title,
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
                  const SizedBox(height: 32),
                  CustomButton(
                    text: AppStrings.applyNow,
                    isLoading: _isApplying,
                    onPressed: _apply,
                  ),
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
