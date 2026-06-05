import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/models/posted_job_model.dart';
import 'package:rozgar/company/providers/post_job_provider.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/constants/app_routes.dart';

class PostedJobCard extends StatelessWidget {
  final PostedJobModel job;
  const PostedJobCard({super.key, required this.job});

  Color _statusColor() {
    switch (job.status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${job.applicationCount} applications'),
        trailing: Chip(
          label: Text(job.status),
          backgroundColor: _statusColor().withValues(alpha: 0.15),
        ),
        onTap: () => Get.toNamed(AppRoutes.companyApplicants, arguments: job.id),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () =>
                  Get.toNamed(AppRoutes.companyPostJob, arguments: job),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => Get.dialog(
                AlertDialog(
                  title: const Text('Delete job?'),
                  actions: [
                    TextButton(onPressed: Get.back, child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () {
                        PostJobProvider.to.deleteJob(job.id);
                        Get.back();
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
