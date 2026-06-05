import 'package:flutter/material.dart';
import 'package:rozgar/admin/providers/job_moderation_provider.dart';
import 'package:rozgar/user/models/job_model.dart';

class ModerationCard extends StatelessWidget {
  final JobModel job;
  final bool showActions;

  const ModerationCard({
    super.key,
    required this.job,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${job.companyName} • ${job.status}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              job.description.isNotEmpty
                  ? job.description
                  : 'No description',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showActions)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    JobModerationProvider.to.approveJob(job.id);
                  },
                  child: const Text('Approve', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () async {
                    final reason = await _rejectDialog(context);
                    if (reason != null) {
                      JobModerationProvider.to.rejectJob(job.id, reason);
                    }
                  },
                  child: const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<String?> _rejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejection reason'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
