import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rozgar/company/constants/company_strings.dart';
import 'package:rozgar/company/models/applicant_model.dart';
import 'package:rozgar/company/providers/applicants_provider.dart';

class ApplicantDetailScreen extends StatelessWidget {
  const ApplicantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Get.arguments as ApplicantModel;
    final provider = ApplicantsProvider.to;

    return Scaffold(
      appBar: AppBar(title: Text(a.seekerName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: a.seekerPhotoUrl != null
                    ? NetworkImage(a.seekerPhotoUrl!)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text(a.seekerEmail)),
            Wrap(
              spacing: 8,
              children: a.seekerSkills
                  .map((s) => Chip(label: Text(s)))
                  .toList(),
            ),
            if (a.seekerExperience != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Experience',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(a.seekerExperience!),
            ],
            if (a.coverLetter != null && a.coverLetter!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Cover Letter',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(a.coverLetter!),
            ],
            if (a.resumeUrl != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Resume'),
                children: [
                  SizedBox(
                    height: 400,
                    child: _PdfFromUrl(url: a.resumeUrl!),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      provider.updateStatus(a.applicationId, 'accepted');
                      Get.back();
                    },
                    child: const Text(CompanyStrings.accept),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      provider.updateStatus(a.applicationId, 'rejected');
                      Get.back();
                    },
                    child: const Text(CompanyStrings.reject),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                provider.updateStatus(a.applicationId, 'viewed');
                Get.back();
              },
              child: const Text(CompanyStrings.markViewed),
            ),
          ],
        ),
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
    final file = File(
      '${dir.path}/resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
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
