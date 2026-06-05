import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/providers/post_job_provider.dart';
import 'package:rozgar/company/widgets/posted_job_card.dart';

class MyJobsScreen extends StatelessWidget {
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = PostJobProvider.to;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Jobs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Pending'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              _list(provider.myJobs),
              _list(provider.myJobs.where((j) => j.status == 'approved')),
              _list(provider.myJobs.where((j) => j.status == 'pending')),
              _list(provider.myJobs.where((j) => j.status == 'rejected')),
            ],
          );
        }),
      ),
    );
  }

  Widget _list(Iterable jobs) {
    final list = jobs.toList();
    if (list.isEmpty) return const Center(child: Text('No jobs'));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) => PostedJobCard(job: list[i]),
    );
  }
}
