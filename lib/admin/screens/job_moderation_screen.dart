import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/admin/constants/admin_strings.dart';
import 'package:rozgar/admin/providers/job_moderation_provider.dart';
import 'package:rozgar/admin/widgets/moderation_card.dart';

class JobModerationScreen extends StatelessWidget {
  const JobModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = JobModerationProvider.to;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AdminStrings.jobs),
          bottom: const TabBar(
            tabs: [Tab(text: 'Pending'), Tab(text: 'Approved'), Tab(text: 'Rejected')],
          ),
        ),
        body: Obx(() => TabBarView(
              children: [
                _list(provider.pendingJobs, showActions: true),
                _list(provider.approvedJobs),
                _list(provider.rejectedJobs),
              ],
            )),
      ),
    );
  }

  Widget _list(List jobs, {bool showActions = false}) {
    if (jobs.isEmpty) return const Center(child: Text('No jobs'));
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (_, i) => ModerationCard(
        job: jobs[i],
        showActions: showActions,
      ),
    );
  }
}
