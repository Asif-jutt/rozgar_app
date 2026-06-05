import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/admin/constants/admin_strings.dart';
import 'package:rozgar/admin/models/dashboard_stats_model.dart';
import 'package:rozgar/admin/providers/job_moderation_provider.dart';
import 'package:rozgar/admin/providers/reports_provider.dart';
import 'package:rozgar/admin/providers/user_management_provider.dart';
import 'package:rozgar/admin/widgets/moderation_card.dart';
import 'package:rozgar/admin/widgets/stats_card.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = UserManagementProvider.to;
    final jobs = JobModerationProvider.to;
    final reports = ReportsProvider.to;

    final stats = DashboardStatsModel(
      totalUsers: users.users.length,
      totalJobs: jobs.approvedJobs.length,
      pendingJobs: jobs.pendingJobs.length,
      reportsCount: reports.reports.length,
      weeklySignups: const [3, 5, 2, 8, 4, 6, 7],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminStrings.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: AuthProvider.to.signOut,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text(AdminStrings.dashboard)),
            ListTile(
              title: const Text(AdminStrings.users),
              onTap: () => Get.toNamed(AppRoutes.adminUsers),
            ),
            ListTile(
              title: const Text(AdminStrings.jobs),
              onTap: () => Get.toNamed(AppRoutes.adminJobs),
            ),
            ListTile(
              title: const Text(AdminStrings.reports),
              onTap: () => Get.toNamed(AppRoutes.adminReports),
            ),
            ListTile(
              title: const Text(AdminStrings.settings),
              onTap: () => Get.toNamed(AppRoutes.adminSettings),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatsCard(
                  icon: Icons.people,
                  value: '${stats.totalUsers}',
                  label: AdminStrings.totalUsers,
                  color: Colors.teal,
                ),
                StatsCard(
                  icon: Icons.work,
                  value: '${stats.totalJobs}',
                  label: AdminStrings.activeJobs,
                  color: Colors.blue,
                ),
                StatsCard(
                  icon: Icons.pending,
                  value: '${stats.pendingJobs}',
                  label: AdminStrings.pendingReview,
                  color: Colors.amber,
                ),
                StatsCard(
                  icon: Icons.flag,
                  value: '${stats.reportsCount}',
                  label: AdminStrings.openReports,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Pending Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: jobs.pendingJobs.length,
                    itemBuilder: (_, i) => SizedBox(
                      width: 280,
                      child: ModerationCard(
                        job: jobs.pendingJobs[i],
                        showActions: true,
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            const Text('Weekly Signups'),
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _BarChartPainter(stats.weeklySignups),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<int> data;
  _BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.teal;
    final max = data.reduce((a, b) => a > b ? a : b).toDouble();
    final barWidth = size.width / data.length - 8;
    for (var i = 0; i < data.length; i++) {
      final h = (data[i] / max) * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * (barWidth + 8) + 4, size.height - h, barWidth, h),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
