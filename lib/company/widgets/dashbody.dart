import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/models/job_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/widgets/banner_ad_widget.dart';
import 'package:rozgar/widgets/network_image_widget.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: Text('Please log in'));

    final firestore = FirestoreService();

    return StreamBuilder<List<JobModel>>(
      stream: firestore.companyJobsStream(uid),
      builder: (context, jobSnap) {
        return StreamBuilder(
          stream: firestore.companyApplicationsStream(uid),
          builder: (context, appSnap) {
            final jobs = jobSnap.data ?? [];
            final apps = appSnap.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Dashboard', style: AppTextStyles.headline3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _stat(Icons.work, 'Jobs', '${jobs.length}'),
                      const SizedBox(width: 12),
                      _stat(Icons.people, 'Applicants', '${apps.length}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Your Listings', style: AppTextStyles.headline4),
                  const SizedBox(height: 12),
                  if (jobs.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No jobs posted yet. Tap Post to add one.'),
                      ),
                    )
                  else
                    ...jobs.map((job) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              JobBannerImage(
                                imageUrl: job.imageUrl,
                                category: job.category,
                                height: 100,
                              ),
                              ListTile(
                                title: Text(job.title),
                                subtitle: Text('${job.location} • ${job.salary}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: AppColors.errorColor),
                                  onPressed: () =>
                                      firestore.deleteJob(job.jobId),
                                ),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 16),
                  const Center(child: BannerAdWidget()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryColor),
              const SizedBox(height: 8),
              Text(value, style: AppTextStyles.headline3),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
