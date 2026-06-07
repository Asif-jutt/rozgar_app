import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/models/feed_job.dart';
import 'package:rozgar/services/social_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/core/widgets/network_image_widget.dart';

class UnifiedJobCard extends StatelessWidget {
  final FeedJob job;
  final VoidCallback onTap;
  final VoidCallback? onApply;
  final VoidCallback? onCommentTap;

  const UnifiedJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onApply,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final social = SocialService.instance;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                JobBannerImage(
                  imageUrl: job.imageUrl,
                  category: job.category,
                  height: 130,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _SourceBadge(label: job.sourceLabel, isApi: job.isApi),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: AppTextStyles.headline4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.companyName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(job.location, style: AppTextStyles.bodySmall),
                      ),
                      Icon(Icons.payments,
                          size: 16, color: AppColors.successColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          job.salary,
                          style: AppTextStyles.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (uid != null) ...[
                        StreamBuilder<bool>(
                          stream: social.isLikedStream(job.id, uid),
                          builder: (context, snap) {
                            final liked = snap.data ?? false;
                            return StreamBuilder<int>(
                              stream: social.likeCountStream(job.id),
                              builder: (context, countSnap) {
                                return InkWell(
                                  onTap: () => social.toggleLike(job.id, uid),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          liked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 20,
                                          color: liked
                                              ? AppColors.errorColor
                                              : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${countSnap.data ?? 0}',
                                          style: AppTextStyles.labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onCommentTap ?? onTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.comment_outlined, size: 20),
                                const SizedBox(width: 4),
                                StreamBuilder(
                                  stream: social.commentsStream(job.id),
                                  builder: (context, snap) => Text(
                                    '${snap.data?.length ?? 0}',
                                    style: AppTextStyles.labelSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (onApply != null)
                        FilledButton.tonal(
                          onPressed: onApply,
                          child: Text(job.isLocal ? 'Apply' : 'Open'),
                        ),
                    ],
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

class _SourceBadge extends StatelessWidget {
  final String label;
  final bool isApi;

  const _SourceBadge({required this.label, required this.isApi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApi ? AppColors.infoColor : AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isApi ? Icons.public : Icons.business,
            size: 14,
            color: isApi ? Colors.white : AppColors.primaryDark,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isApi ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
