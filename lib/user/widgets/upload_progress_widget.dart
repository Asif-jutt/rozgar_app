import 'package:flutter/material.dart';

class UploadProgressWidget extends StatelessWidget {
  final String filename;
  final double progress;
  final VoidCallback? onCancel;

  const UploadProgressWidget({
    super.key,
    required this.filename,
    required this.progress,
    this.onCancel,
  });

  static void show(BuildContext context, {
    required String filename,
    required Stream<double> progressStream,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (ctx) {
        return StreamBuilder<double>(
          stream: progressStream,
          builder: (_, snap) {
            final p = snap.data ?? 0;
            if (p >= 1.0) {
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (ctx.mounted) Navigator.pop(ctx);
              });
            }
            return UploadProgressWidget(
              filename: filename,
              progress: p,
              onCancel: () => Navigator.pop(ctx),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            progress >= 1.0 ? Icons.check_circle : Icons.upload_file,
            color: progress >= 1.0 ? Colors.green : null,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(filename, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}%'),
          if (progress < 1.0 && onCancel != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ],
      ),
    );
  }
}
