import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/models/application_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/services/notification_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/company/widgets/company_shell.dart';
import 'package:rozgar/widgets/network_image_widget.dart';

class ManageApplicantsPage extends StatefulWidget {
  const ManageApplicantsPage({super.key});

  @override
  State<ManageApplicantsPage> createState() => _ManageApplicantsPageState();
}

class _ManageApplicantsPageState extends State<ManageApplicantsPage> {
  final _firestore = FirestoreService();
  final _notifications = NotificationService();
  String _filter = 'All';

  Future<void> _updateStatus(ApplicationModel app, String status) async {
    await _firestore.updateApplicationStatus(app.appId, status);
    await _notifications.sendNotification(
      userId: app.userId,
      title: 'Application Update',
      body: 'Your application for "${app.jobTitle}" is now $status',
      relatedId: app.appId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return CompanyShell(
      title: 'Manage Applicants',
      navIndex: 2,
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<ApplicationModel>>(
              stream: _firestore.companyApplicationsStream(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var apps = snap.data ?? [];
                if (_filter != 'All') {
                  apps = apps.where((a) => a.status == _filter).toList();
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        children: ['All', 'Pending', 'Reviewed', 'Accepted', 'Rejected']
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(s),
                                    selected: _filter == s,
                                    onSelected: (_) => setState(() => _filter = s),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: apps.isEmpty
                          ? const Center(child: Text('No applicants yet'))
                          : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: apps.length,
                  itemBuilder: (context, i) {
                    final app = apps[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ProfileAvatar(
                                  fallbackText: app.applicantName ?? 'A',
                                  radius: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.applicantName ?? 'Applicant',
                                        style: AppTextStyles.labelLarge,
                                      ),
                                      Text(
                                        app.jobTitle ?? 'Job',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                _chip(app.status),
                              ],
                            ),
                            if (app.resumeText.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Resume: ${app.resumeText}',
                                style: AppTextStyles.labelSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _updateStatus(app, 'Rejected'),
                                    child: const Text('Reject'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _updateStatus(app, 'Accepted'),
                                    child: const Text('Accept'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _chip(String status) {
    Color c = AppColors.warningColor;
    if (status == 'Accepted') c = AppColors.successColor;
    if (status == 'Rejected') c = AppColors.errorColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: c, fontSize: 12)),
    );
  }
}
