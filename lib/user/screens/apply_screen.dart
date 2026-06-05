import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/providers/application_provider.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:rozgar/user/providers/profile_provider.dart';
import 'package:rozgar/user/widgets/custom_button.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _cover = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.i('NAV: ApplyScreen');
  }

  @override
  Widget build(BuildContext context) {
    final job = Get.arguments as JobModel;
    final profile = ProfileProvider.to;
    final apps = ApplicationProvider.to;
    final user = AuthProvider.to.currentUser.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text(
                  job.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${job.companyName} • ${job.location}'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold)),
            Obx(() {
              final resume =
                  profile.profile.value?.resumeUrl ?? user?.resumeUrl;
              if (resume != null) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Resume uploaded'),
                      trailing: TextButton(
                        onPressed: () => _viewPdf(resume),
                        child: const Text('View PDF'),
                      ),
                    ),
                    TextButton(
                      onPressed: profile.uploadResume,
                      child: const Text('Change Resume'),
                    ),
                  ],
                );
              }
              return FilledButton.icon(
                onPressed: profile.uploadResume,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Resume'),
              );
            }),
            Obx(() {
              if (!profile.isUploading.value) return const SizedBox.shrink();
              return LinearProgressIndicator(
                value: profile.uploadProgress.value,
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _cover,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Cover Letter (optional)',
                filled: true,
                alignLabelWithHint: true,
              ),
            ),
            const Spacer(),
            Obx(
              () => CustomButton(
                label: 'Submit Application',
                isLoading: apps.isSubmitting.value,
                onPressed: () {
                  final resume =
                      profile.profile.value?.resumeUrl ?? user?.resumeUrl;
                  if (resume == null) {
                    Get.snackbar('Error', 'Please upload a resume first');
                    return;
                  }
                  apps
                      .submitApplication(
                        jobId: job.id,
                        jobTitle: job.title,
                        companyName: job.companyName,
                        resumeUrl: resume,
                        coverLetter: _cover.text,
                      )
                      .then((_) {
                        if (!apps.isSubmitting.value) {
                          Get.back();
                          Get.snackbar(
                            'Applied!',
                            'Application submitted successfully',
                          );
                        }
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPdf(String url) {
    Get.to(
      () => Scaffold(
        appBar: AppBar(title: const Text('Resume')),
        body: _PdfFromUrl(url: url),
      ),
    );
  }
}

class _PdfFromUrl extends StatefulWidget {
  final String url;
  const _PdfFromUrl({required this.url});

  @override
  State<_PdfFromUrl> createState() => _PdfFromUrlState();
}

class _PdfFromUrlState extends State<_PdfFromUrl> {
  late final Future<String> _localPath;

  @override
  void initState() {
    super.initState();
    _localPath = _downloadPdf(widget.url);
  }

  Future<String> _downloadPdf(String url) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await Dio().download(url, file.path);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _localPath,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load PDF'));
        }
        return PDFView(filePath: snapshot.data!);
      },
    );
  }
}
