import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/widgets/job_card.dart';
import 'package:rozgar/services/database_service.dart';
import 'package:rozgar/services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedBottomNavIndex = 0;
  String _selectedLocation = 'All';
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.location),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: ['All', 'Karachi', 'Lahore', 'Islamabad']
                    .map(
                      (location) => ChoiceChip(
                        label: Text(location),
                        selected: _selectedLocation == location,
                        onSelected: (selected) {
                          setState(() => _selectedLocation = location);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.home,
        actions: [
          IconButton(
            icon: const Tooltip(
              message: "Notifications",
              child: Icon(Icons.notifications_none, color: Colors.white),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Tooltip(
              message: "Logout",
              child: Icon(Icons.logout, color: Colors.white),
            ),
            onPressed: () async {
              await _authService.logout();
            },
          ),
        ],
      ),
      drawer: currentUser != null
          ? UserDrawer(
        userName: currentUser.email ?? 'User',
        userEmail: currentUser.email ?? '',
        onLogout: () async {
          await _authService.logout();
        },
      )
          : null,
      body: StreamBuilder<List<Job>>(
        stream: _selectedLocation == 'All'
            ? _databaseService.getAllJobsStream()
            : _databaseService.getAllJobsStream().map(
          (jobs) => jobs
              .where((job) => job.location == _selectedLocation)
              .toList(),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return const Center(
              child: Text('No jobs found'),
            );
          }

          return Column(
            children: [
              CustomSearchBar(
                hintText: AppStrings.search,
                onFilterPressed: _showFilterDialog,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(
                          _selectedLocation == 'All'
                              ? AppStrings.location
                              : _selectedLocation,
                        ),
                        onSelected: (_) => _showFilterDialog(),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Jobs: ${jobs.length}'),
                        onSelected: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.verticalSpaceMedium),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: AppSpacing.horizontalSpaceMedium,
                    mainAxisSpacing: AppSpacing.verticalSpaceMedium,
                  ),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(
                      job: jobs[index],
                      onApplyPressed: () async {
                        await _showApplyDialog(context, jobs[index]);
                      },
                      onCardPressed: () {
                        _showJobDetails(context, jobs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        items: [
          NavigationItem(icon: Icons.home, label: AppStrings.home),
          NavigationItem(icon: Icons.work, label: AppStrings.myJobs),
          NavigationItem(icon: Icons.message, label: AppStrings.messages),
        ],
        onTap: (index) {
          setState(() => _selectedBottomNavIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/myapplication');
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages feature coming soon')),
              );
              break;
          }
        },
      ),
    );
  }

  Future<void> _showApplyDialog(BuildContext context, Job job) async {
    final currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to apply')),
      );
      return;
    }

    // Check if already applied
    final alreadyApplied = await _databaseService.hasUserApplied(
      currentUser.uid,
      job.id,
    );

    if (alreadyApplied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already applied for ${job.jobTitle}')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apply for ${job.jobTitle}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company: ${job.companyName}'),
              const SizedBox(height: 8),
              Text('Location: ${job.location}'),
              const SizedBox(height: 8),
              Text('Salary: ${job.salary}'),
              const SizedBox(height: 8),
              Text('Type: ${job.jobType}'),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to apply for this position?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _submitApplication(context, currentUser.uid, job);
              },
              child: const Text('Apply', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitApplication(
      BuildContext context, String userId, Job job) async {
    final application = JobApplication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jobId: job.id,
      userId: userId,
      jobTitle: job.jobTitle,
      companyName: job.companyName,
      status: 'Applied',
      appliedDate: DateTime.now(),
    );

    try {
      await _databaseService.createApplication(application);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied to ${job.jobTitle} successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying: $e')),
      );
    }
  }

  void _showJobDetails(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                job.jobTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(job.companyName,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(job.description),
              const SizedBox(height: 16),
              const Text(
                'Required Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: job.requiredSkills
                    .map((skill) => Chip(label: Text(skill)))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Salary'),
                      const SizedBox(height: 4),
                      Text(
                        job.salary,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location'),
                      const SizedBox(height: 4),
                      Text(
                        job.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
