import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/job_provider.dart';
import 'package:rozgar/user/widgets/job_card.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('NAV: SavedJobsScreen');
    final job = JobProvider.to;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: Obx(() {
        final saved = job.jobs
            .where((j) => job.savedJobIds.contains(j.id))
            .toList();
        if (saved.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(AppStrings.noSavedJobs),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: saved.length,
          itemBuilder: (_, i) => Dismissible(
            key: Key(saved[i].id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => job.toggleSaveJob(saved[i].id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: JobCard(job: saved[i]),
          ),
        );
      }),
    );
  }
}
