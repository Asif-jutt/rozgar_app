import 'package:flutter/material.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';

import 'package:intl/intl.dart';

class JobCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: InkWell(
        onTap: onCardPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobBannerImage(
              imageUrl: job.imageUrl,
              category: job.category,
              height: 120,
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withValues(alpha: 0.25),
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
                          DateFormat('MMM dd, hh:mm a').format(job.postedAt!.toLocal()),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(job.location, style: AppTextStyles.bodySmall),
                      ),
                      const Icon(Icons.payments,
                          size: 16, color: AppColors.successColor),
                      const SizedBox(width: 4),
                      Text(job.salary, style: AppTextStyles.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.requirementList
                        .take(3)
                        .map(
                          (s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppColors.primaryLight.withValues(alpha: 0.1),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Add Like Interaction Logic
                          },
                          icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                          label: Text(
                            'Like',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Add Comment Interaction Logic
                          },
                          icon: const Icon(Icons.comment_outlined, size: 18),
                          label: Text(
                            'Comment',
                            style: TextStyle(color: AppColors.primaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onApplyPressed,
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
  }
}


