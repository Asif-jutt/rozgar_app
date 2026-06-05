import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/providers/connectivity_provider.dart';
import 'package:rozgar/shared/widgets/offline_banner.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/job_provider.dart';
import 'package:rozgar/user/widgets/ad_banner_widget.dart';
import 'package:rozgar/user/widgets/job_card.dart';
import 'package:rozgar/user/widgets/shimmer_loader.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final _scroll = ScrollController();
  final _job = JobProvider.to;
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    AppLogger.i('NAV: JobFeedScreen');
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent * 0.8) {
        _job.loadMoreJobs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(AppRoutes.userNotifications),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
              onChanged: _job.searchJobs,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() => ConnectivityProvider.to.isOffline.value
              ? const OfflineBanner()
              : const SizedBox.shrink()),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ['all', 'fullTime', 'partTime', 'remote', 'contract']
                  .map((t) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(t == 'all' ? 'All' : t),
                          selected: _typeFilter == t,
                          onSelected: (_) {
                            setState(() => _typeFilter = t);
                            _job.applyFilters({'type': t});
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_job.isLoading.value) {
                return ListView.builder(
                  itemCount: 6,
                  itemBuilder: (_, __) => ShimmerLoader.jobCardShimmer(),
                );
              }
              if (_job.filteredJobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(AppStrings.noJobs),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _job.loadJobs,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _job.loadJobs,
                child: ListView.builder(
                  controller: _scroll,
                  itemCount: _job.filteredJobs.length + 1,
                  itemBuilder: (_, i) {
                    if (i == _job.filteredJobs.length) {
                      return const AdBannerWidget();
                    }
                    return JobCard(job: _job.filteredJobs[i]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 1:
              Get.toNamed(AppRoutes.userApplications);
            case 2:
              Get.toNamed(AppRoutes.userSaved);
            case 3:
              Get.toNamed(AppRoutes.userProfile);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work), label: 'Applications'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
