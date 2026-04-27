import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';

class Myapplication extends StatefulWidget {
  const Myapplication({super.key});

  @override
  State<Myapplication> createState() => _MyapplicationState();
}

class _MyapplicationState extends State<Myapplication> {
  int _selectedBottomNavIndex = 0;
  int _selectedTabIndex = 0;

  // Sample Applications Data
  late List<JobApplication> applications;

  @override
  void initState() {
    super.initState();
    _generateSampleApplications();
  }

  void _generateSampleApplications() {
    applications = [
      JobApplication(
        id: '1',
        jobId: 'j1',
        userId: 'u1',
        jobTitle: 'Flutter Developer',
        companyName: 'Tech Solutions Inc',
        status: 'Applied',
        appliedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      JobApplication(
        id: '2',
        jobId: 'j2',
        userId: 'u1',
        jobTitle: 'Mobile App Developer',
        companyName: 'Digital Agency',
        status: 'Under Review',
        appliedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      JobApplication(
        id: '3',
        jobId: 'j3',
        userId: 'u1',
        jobTitle: 'Backend Developer',
        companyName: 'Cloud Systems',
        status: 'Interview',
        appliedDate: DateTime.now().subtract(const Duration(days: 10)),
        interviewDate: DateTime.now()
            .add(const Duration(days: 3))
            .toIso8601String(),
      ),
      JobApplication(
        id: '4',
        jobId: 'j4',
        userId: 'u1',
        jobTitle: 'UI/UX Designer',
        companyName: 'Creative Studio',
        status: 'Rejected',
        appliedDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      JobApplication(
        id: '5',
        jobId: 'j5',
        userId: 'u1',
        jobTitle: 'QA Tester',
        companyName: 'Quality Assurance Ltd',
        status: 'Accepted',
        appliedDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];
  }

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
        return Icons.schedule;
      case 'interview':
        return Icons.videocam;
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
    final filteredApplications = _selectedTabIndex == 0
        ? applications
        : _selectedTabIndex == 1
        ? applications
              .where((app) => app.status.toLowerCase() == 'applied')
              .toList()
        : applications
              .where((app) => app.status.toLowerCase() == 'interview')
              .toList();

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.myApplications,
        showBackButton: true,
      ),
      drawer: UserDrawer(
        userName: 'John Doe',
        userEmail: 'john@example.com',
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/Login');
        },
      ),
      body: Column(
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
                      ButtonSegment(value: 1, label: Text(AppStrings.archived)),
                      ButtonSegment(
                        value: 2,
                        label: Text(AppStrings.interviews),
                      ),
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

                              // Interview Date if available
                              if (app.interviewDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.verticalSpaceSmall,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.videocam,
                                        size: 16,
                                        color: AppColors.successColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Interview: ${app.interviewDate}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),

                              // Feedback if available
                              if (app.feedback != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.verticalSpaceMedium,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppDimensions.paddingSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.backgroundColor,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusMedium,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Feedback',
                                          style: AppTextStyles.labelSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          app.feedback!,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: AppSpacing.verticalSpaceMedium,
                              ),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'View details feature',
                                            ),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusMedium,
                                          ),
                                        ),
                                      ),
                                      child: const Text(AppStrings.viewDetails),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Update status'),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusMedium,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Action'),
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
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        items: [
          NavigationItem(icon: Icons.home, label: AppStrings.home),
          NavigationItem(icon: Icons.archive, label: AppStrings.archived),
          NavigationItem(icon: Icons.videocam, label: AppStrings.interviews),
        ],
        onTap: (index) {
          setState(() => _selectedBottomNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              setState(() => _selectedTabIndex = 1);
              break;
            case 2:
              setState(() => _selectedTabIndex = 2);
              break;
          }
        },
      ),
    );
  }
}
