import 'package:flutter/material.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/core/widgets/network_image_widget.dart';

class AdminBody extends StatelessWidget {
  const AdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return FutureBuilder<Map<String, int>>(
      future: firestore.getPlatformStats(),
      builder: (context, statsSnap) {
        final stats = statsSnap.data ??
            {'seekers': 0, 'companies': 0, 'jobs': 0, 'applications': 0};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Platform Overview', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _tile(Icons.person, 'Seekers', '${stats['seekers']}'),
                  _tile(Icons.business, 'Companies', '${stats['companies']}'),
                  _tile(Icons.work, 'Jobs', '${stats['jobs']}'),
                  _tile(Icons.assignment, 'Apps', '${stats['applications']}'),
                ],
              ),
              const SizedBox(height: 24),
              Text('All Jobs', style: AppTextStyles.headline4),
              const SizedBox(height: 12),
              StreamBuilder<List<JobModel>>(
                stream: firestore.jobsStream(),
                builder: (context, snap) {
                  final jobs = snap.data ?? [];
                  if (jobs.isEmpty) return const Text('No jobs');
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: jobs.length,
                    itemBuilder: (context, i) {
                      final job = jobs[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: SizedBox(
                            width: 56,
                            child: JobBannerImage(
                              imageUrl: job.imageUrl,
                              category: job.category,
                              height: 56,
                            ),
                          ),
                          title: Text(job.title),
                          subtitle: Text(job.companyName ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: AppColors.errorColor),
                            onPressed: () => firestore.deleteJob(job.jobId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const Spacer(),
            Text(value, style: AppTextStyles.headline3),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
