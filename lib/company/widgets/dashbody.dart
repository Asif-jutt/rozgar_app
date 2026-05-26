import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';
import 'package:rozgar/company/screens/company_job_details.dart'
    as rozgar_company_job_details;

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  Future<void> _deleteJob(BuildContext context, String jobId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text(
          'Are you sure you want to delete this job posting? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirestoreService().deleteJob(jobId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job deleted successfully.'),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete job: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      }
    }
  }

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
                      _stat(Icons.work, 'Active Jobs', '${jobs.length}'),
                      const SizedBox(width: 12),
                      _stat(Icons.people, 'Total Applicants', '${apps.length}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Active Listings',
                        style: AppTextStyles.headline4,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/inbox'),
                            icon: const Icon(
                              Icons.message,
                              color: AppColors.primaryColor,
                            ),
                            tooltip: 'Messages',
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/post-jobs'),
                            icon: const Icon(Icons.add),
                            label: const Text('Post New'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (jobs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs posted yet.',
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/post-jobs'),
                              child: const Text('Post Your First Job'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...jobs.map(
                      (job) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  rozgar_company_job_details.CompanyJobDetailsPage(
                                    job: job,
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  JobBannerImage(
                                    imageUrl: job.imageUrl,
                                    category: job.category,
                                    height: 120,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                            tooltip: 'Edit Job',
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  '/post-jobs',
                                                  arguments: job,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                            padding: EdgeInsets.zero,
                                            tooltip: 'Delete Job',
                                            onPressed: () =>
                                                _deleteJob(context, job.jobId),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: AppTextStyles.headline4,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: AppColors.primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          job.location,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.attach_money,
                                          size: 16,
                                          color: AppColors.primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          job.salary,
                                          style: AppTextStyles.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      job.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 28),
              ),
              const SizedBox(height: 16),
              Text(value, style: AppTextStyles.headline3),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
