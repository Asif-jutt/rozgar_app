import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/constants/company_strings.dart';
import 'package:rozgar/company/providers/post_job_provider.dart';
import 'package:rozgar/company/screens/company_profile_screen.dart';
import 'package:rozgar/company/screens/my_jobs_screen.dart';
import 'package:rozgar/company/screens/post_job_screen.dart';
import 'package:rozgar/company/widgets/company_stats_card.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class CompanyHomeScreen extends StatefulWidget {
  const CompanyHomeScreen({super.key});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  int _index = 0;
  final _tabs = const [
    _DashboardTab(),
    PostJobScreen(),
    MyJobsScreen(),
    CompanyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: CompanyStrings.dashboard),
          NavigationDestination(icon: Icon(Icons.add), label: CompanyStrings.postJob),
          NavigationDestination(icon: Icon(Icons.work), label: CompanyStrings.myJobs),
          NavigationDestination(icon: Icon(Icons.business), label: CompanyStrings.profile),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => setState(() => _index = 1),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final jobs = PostJobProvider.to;
    final user = AuthProvider.to.currentUser.value;
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${user?.displayName ?? 'Company'}')),
      body: Obx(() {
        final totalApps = jobs.myJobs.fold<int>(
          0, (s, j) => s + j.applicationCount);
        final pending = jobs.myJobs.where((j) => j.status == 'pending').length;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CompanyStatsCard(
                      icon: Icons.work,
                      value: '${jobs.myJobs.length}',
                      label: CompanyStrings.totalJobs,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CompanyStatsCard(
                      icon: Icons.people,
                      value: '$totalApps',
                      label: CompanyStrings.totalApplications,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CompanyStatsCard(
                icon: Icons.pending,
                value: '$pending',
                label: CompanyStrings.pendingReview,
                color: Colors.orange,
              ),
            ],
          ),
        );
      }),
    );
  }
}
