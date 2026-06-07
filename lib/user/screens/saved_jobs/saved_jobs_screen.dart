import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rozgar/user/providers/jobs_feed_provider.dart';
import 'package:rozgar/services/social_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/screens/job_details/job_details.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/core/widgets/unified_job_card.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final allJobs = context.watch<JobsFeedProvider>().jobs;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Saved Jobs',
        showBackButton: true,
      ),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<String>>(
              stream: SocialService.instance.userLikedJobIdsStream(uid),
              builder: (context, snap) {
                final likedIds = snap.data ?? [];
                final saved =
                    allJobs.where((j) => likedIds.contains(j.id)).toList();

                if (saved.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No saved jobs yet',
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 8),
                        Text('Tap the heart on any job to save it',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: saved.length,
                  itemBuilder: (context, i) {
                    final job = saved[i];
                    return UnifiedJobCard(
                      job: job,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(feedJob: job),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
