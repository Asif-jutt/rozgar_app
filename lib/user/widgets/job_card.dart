import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/providers/job_provider.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final jobProvider = JobProvider.to;

    return Hero(
      tag: 'job-${job.id}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.userJobDetail, arguments: job),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: job.companyLogoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: job.companyLogoUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _initials(),
                            )
                          : _initials(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            job.companyName,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => IconButton(
                          icon: Icon(
                            jobProvider.savedJobIds.contains(job.id)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppColors.primary,
                          ),
                          onPressed: () => jobProvider.toggleSaveJob(job.id),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(job.location, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    Chip(
                      label: Text(job.formattedSalary, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (job.applicationCount < 20)
                      const Chip(
                        label: Text(AppStrings.easyApply, style: TextStyle(fontSize: 12)),
                        backgroundColor: Color(0xFFE8F5E9),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _typeBadge(job.type),
                    const Spacer(),
                    if (job.postedAt != null)
                      Text(
                        timeago(job.postedAt!.toDate()),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _initials() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    return Chip(
      label: Text(type, style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }

  String timeago(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
