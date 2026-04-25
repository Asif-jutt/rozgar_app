import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/models/job_model.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onApplyPressed;
  final VoidCallback onCardPressed;

  const JobCard({
    Key? key,
    required this.job,
    required this.onApplyPressed,
    required this.onCardPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: InkWell(
        onTap: onCardPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(
                job.jobTitle,
                style: AppTextStyles.headline4,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.verticalSpaceSmall),

              // Company Name
              Text(
                job.companyName,
                style: AppTextStyles.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.verticalSpaceMedium),

              // Location and Salary Row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: AppDimensions.iconSmall,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            style: AppTextStyles.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          size: AppDimensions.iconSmall,
                          color: AppColors.successColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.salary,
                            style: AppTextStyles.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.verticalSpaceSmall),

              // Job Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                  border: Border.all(color: AppColors.primaryColor, width: 0.5),
                ),
                child: Text(
                  job.jobType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.verticalSpaceMedium),

              // Skills
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: job.requiredSkills
                    .take(3)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        backgroundColor: AppColors.secondaryColor.withOpacity(
                          0.2,
                        ),
                        labelStyle: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 11,
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (job.requiredSkills.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${job.requiredSkills.length - 3} more',
                    style: AppTextStyles.labelSmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.verticalSpaceMedium),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onApplyPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                  child: const Text(
                    AppStrings.applyNow,
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
