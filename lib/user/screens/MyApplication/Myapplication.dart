import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/models/application_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/drawer.dart';

class Myapplication extends StatefulWidget {
  const Myapplication({super.key});

  @override
  State<Myapplication> createState() => _MyapplicationState();
}

class _MyapplicationState extends State<Myapplication> {
  final _firestore = FirestoreService();
  String _statusFilter = 'All';

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.successColor;
      case 'rejected':
        return AppColors.errorColor;
      case 'reviewed':
        return AppColors.warningColor;
      default:
        return AppColors.infoColor;
    }
  }

  List<ApplicationModel> _filter(List<ApplicationModel> apps) {
    if (_statusFilter == 'All') return apps;
    return apps.where((a) => a.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.myApplications,
        showBackButton: true,
      ),
      drawer: const SeekerDrawer(),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: ['All', 'Pending', 'Reviewed', 'Accepted', 'Rejected']
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(s),
                              selected: _statusFilter == s,
                              onSelected: (_) => setState(() => _statusFilter = s),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ApplicationModel>>(
                    stream: _firestore.userApplicationsStream(uid),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final apps = _filter(snap.data ?? []);
                      if (apps.isEmpty) {
                        return const Center(child: Text('No applications yet'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: apps.length,
                        itemBuilder: (context, i) {
                          final app = apps[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                app.jobTitle ?? 'Job',
                                style: AppTextStyles.labelLarge,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Applied ${_formatDate(app.appliedDate)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  if (app.resumeText.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Resume: ${app.resumeText}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelSmall,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(app.status)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  app.status,
                                  style: TextStyle(
                                    color: _statusColor(app.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
