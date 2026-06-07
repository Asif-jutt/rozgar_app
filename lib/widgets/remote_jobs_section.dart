import 'package:flutter/material.dart';
import 'package:rozgar/models/remote_job.dart';
import 'package:rozgar/services/rest_api_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays remote jobs fetched from external REST API (Remotive).
class RemoteJobsSection extends StatefulWidget {
  const RemoteJobsSection({super.key});

  @override
  State<RemoteJobsSection> createState() => _RemoteJobsSectionState();
}

class _RemoteJobsSectionState extends State<RemoteJobsSection> {
  late Future<List<RemoteJob>> _future;

  @override
  void initState() {
    super.initState();
    _future = RestApiService.instance.fetchRemoteJobs();
  }

  Future<void> _openJob(RemoteJob job) async {
    if (job.url.isEmpty) return;
    final uri = Uri.tryParse(job.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RemoteJob>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final jobs = snap.data ?? [];
        if (jobs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.public, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Text('Remote Jobs (REST API)', style: AppTextStyles.headline4),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: jobs.length,
                itemBuilder: (context, i) {
                  final job = jobs[i];
                  return SizedBox(
                    width: 260,
                    child: Card(
                      margin: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => _openJob(job),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                job.company,
                                style: AppTextStyles.bodySmall,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      job.location,
                                      style: AppTextStyles.labelSmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.open_in_new, size: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
