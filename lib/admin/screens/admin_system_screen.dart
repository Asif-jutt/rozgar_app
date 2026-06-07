import 'package:flutter/material.dart';
import 'package:rozgar/services/profiling_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/core/widgets/banner_ad_widget.dart';

/// Admin view for profiling metrics and system diagnostics.
class AdminSystemScreen extends StatelessWidget {
  const AdminSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timings = ProfilingService.instance.getAverageTimingsMs();

    return Scaffold(
      appBar: AppBar(title: const Text('System & Profiling')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Performance Profiling', style: AppTextStyles.headline4),
          const SizedBox(height: 8),
          Text(
            'Average operation timings (ms) collected during app usage.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          if (timings.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.speed),
                title: Text('No profiling data yet'),
                subtitle: Text('Use the app to collect performance samples.'),
              ),
            )
          else
            ...timings.entries.map(
              (e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.timer, color: AppColors.primaryColor),
                  title: Text(e.key),
                  trailing: Text(
                    '${e.value.toStringAsFixed(1)} ms',
                    style: AppTextStyles.labelLarge,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text('Logging', style: AppTextStyles.headline4),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.bug_report, color: AppColors.infoColor),
              title: Text('Debug logging enabled'),
              subtitle: Text(
                'AppLogger captures errors, warnings, and profile traces in debug mode.',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Security', style: AppTextStyles.headline4),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.lock, color: AppColors.successColor),
              title: Text('AES encryption active'),
              subtitle: Text(
                'CV URLs and resume data are encrypted before Firestore storage.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
