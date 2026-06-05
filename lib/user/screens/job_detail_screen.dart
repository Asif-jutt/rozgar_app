import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/providers/application_provider.dart';
import 'package:rozgar/user/providers/job_provider.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('NAV: JobDetailScreen');
    final job = Get.arguments as JobModel;
    final apps = ApplicationProvider.to;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text(job.title)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'job-${job.id}',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundImage: job.companyLogoUrl != null
                          ? CachedNetworkImageProvider(job.companyLogoUrl!)
                          : null,
                      child: job.companyLogoUrl == null
                          ? Text(job.companyName[0])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.companyName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Chip(label: Text(job.location)),
                        Text(job.formattedSalary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const TabBar(tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Requirements'),
              Tab(text: 'Company'),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(job.description.isNotEmpty
                        ? job.description
                        : 'No description available.'),
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: job.requirements
                        .map((r) => ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(r),
                            ))
                        .toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Posted by ${job.companyName}'),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Obx(() => IconButton(
                      icon: Icon(
                        JobProvider.to.savedJobIds.contains(job.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: AppColors.primary,
                      ),
                      onPressed: () => JobProvider.to.toggleSaveJob(job.id),
                    )),
                Expanded(
                  child: Obx(() {
                    final applied = apps.hasApplied(job.id);
                    return FilledButton(
                      onPressed: applied
                          ? null
                          : () => Get.toNamed(AppRoutes.userApply, arguments: job),
                      child: Text(applied ? AppStrings.applied : AppStrings.applyNow),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
