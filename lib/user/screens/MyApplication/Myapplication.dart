import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/services/auth_service.dart';
import 'package:rozgar/services/database_service.dart';

class Myapplication extends StatefulWidget {
  const Myapplication({super.key});

  @override
  State<Myapplication> createState() => _MyapplicationState();
}

class _MyapplicationState extends State<Myapplication> {
  int _selectedTabIndex = 0;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return AppColors.infoColor;
      case 'under review':
        return AppColors.warningColor;
      case 'interview':
        return AppColors.secondaryColor;
      case 'rejected':
        return AppColors.errorColor;
      case 'accepted':
        return AppColors.successColor;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Icons.check_circle_outline;
      case 'under review':
        return Icons.hourglass_bottom;
      case 'interview':
        return Icons.calendar_today;
      case 'rejected':
        return Icons.cancel;
      case 'accepted':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: AppStrings.myApplications,
          showBackButton: true,
        ),
        body: const Center(
          child: Text('Please log in to view your applications'),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.myApplications,
        showBackButton: true,
      ),
      drawer: UserDrawer(
        userName: currentUser.email ?? 'User',
        userEmail: currentUser.email ?? '',
        onLogout: () async {
          await _authService.logout();
        },
      ),
      body: StreamBuilder<List<JobApplication>>(
        stream: _databaseService.getUserApplicationsStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final applications = snapshot.data ?? [];

          final filteredApplications = _selectedTabIndex == 0
              ? applications
              : _selectedTabIndex == 1
              ? applications
                  .where((app) => app.status.toLowerCase() == 'applied')
                  .toList()
              : applications
                  .where((app) => app.status.toLowerCase() == 'interview')
                  .toList();

          return Column(
            children: [
              // Tab Selector
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('All')),
                          ButtonSegment(value: 1, label: Text('Pending')),
                          ButtonSegment(value: 2, label: Text('Interview')),
                        ],
                        selected: {_selectedTabIndex},
                        onSelectionChanged: (Set<int> newSelection) {
                          setState(() {
                            _selectedTabIndex = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Applications List
              Expanded(
                child: filteredApplications.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_ind,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No applications found',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: filteredApplications.length,
                  itemBuilder: (context, index) {
                    final app = filteredApplications[index];
                    return Card(
                      elevation: AppDimensions.cardElevation,
                      margin: const EdgeInsets.only(
                        bottom: AppSpacing.verticalSpaceMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimensions.paddingMedium,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Job Title and Status Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        app.jobTitle,
                                        style: AppTextStyles.headline4,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        app.companyName,
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      app.status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSmall,
                                    ),
                                    border: Border.all(
                                      color: _getStatusColor(app.status),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(app.status),
                                        size: 16,
                                        color: _getStatusColor(app.status),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        app.status,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(app.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: AppSpacing.verticalSpaceMedium,
                            ),

                            // Applied Date
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Applied: ${app.appliedDate.day}/${app.appliedDate.month}/${app.appliedDate.year}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),

                            // Feedback if available
                            if (app.feedback != null && app.feedback!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.verticalSpaceSmall,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.message,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Feedback: ${app.feedback}',
                                        style: AppTextStyles.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
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
}

