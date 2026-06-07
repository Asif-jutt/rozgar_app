import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/models/job_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/services/notification_service.dart';
import 'package:rozgar/services/rest_api_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/screens/job_details/job_details.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/widgets/drawer.dart';
import 'package:rozgar/user/widgets/job_card.dart';
import 'package:rozgar/widgets/banner_ad_widget.dart';
import 'package:rozgar/widgets/remote_jobs_section.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  int _selectedBottomNavIndex = 0;
  String _searchQuery = '';
  String _selectedLocation = 'All';
  String _selectedCategory = 'All';
  List<String> _locations = RestApiService.defaultLocations;
  static const _categories = [
    'All',
    'IT',
    'Engineering',
    'Marketing',
    'Sales',
    'Finance',
    'Design',
    'Healthcare',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locations = await RestApiService.instance.fetchLocations();
    if (mounted) setState(() => _locations = locations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JobModel> _filter(List<JobModel> jobs) {
    final q = _searchQuery.trim().toLowerCase();
    return jobs.where((job) {
      if (_selectedLocation != 'All' &&
          !job.location.toLowerCase().contains(_selectedLocation.toLowerCase())) {
        return false;
      }
      if (_selectedCategory != 'All' && job.category != _selectedCategory) {
        return false;
      }
      if (q.isEmpty) return true;
      final hay =
          '${job.title} ${job.companyName} ${job.location} ${job.category}'
              .toLowerCase();
      return hay.contains(q);
    }).toList();
  }

  Future<void> _applyToJob(JobModel job) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      if (await _firestore.hasUserApplied(userId: user.uid, jobId: job.jobId)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already applied to this job.')),
        );
        return;
      }

      final profile = await _firestore.getUserProfile(user.uid);
      final userDoc = await _firestore.getUser(user.uid);
      final resumeText = profile?.cvResumeUrl ?? '';

      await _firestore.applyToJob(
        jobId: job.jobId,
        userId: user.uid,
        companyId: job.companyId,
        jobTitle: job.title,
        applicantName: userDoc?.name ?? user.displayName ?? 'Applicant',
        resumeText: resumeText,
      );

      await NotificationService().sendNotification(
        userId: user.uid,
        title: 'Application Sent',
        body: 'You applied to ${job.title}',
        type: 'application',
        relatedId: job.jobId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied to ${job.title}'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      AppLogger.error('Apply to job failed', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.findJobs),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ],
      ),
      drawer: const SeekerDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: AppStrings.search,
              onChanged: (v) => setState(() => _searchQuery = v),
              onFilterPressed: _showFilters,
            ),
          ),
          if (_selectedLocation != 'All' || _selectedCategory != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (_selectedLocation != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_selectedLocation),
                        onDeleted: () =>
                            setState(() => _selectedLocation = 'All'),
                      ),
                    ),
                  if (_selectedCategory != 'All')
                    Chip(
                      label: Text(_selectedCategory),
                      onDeleted: () =>
                          setState(() => _selectedCategory = 'All'),
                    ),
                ],
              ),
            ),
          const RemoteJobsSection(),
          Expanded(
            child: StreamBuilder<List<JobModel>>(
              stream: _firestore.jobsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final all = snapshot.data ?? [];
                final jobs = _filter(all);
                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: AppImages.emptyJobs,
                            width: 200,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('No jobs found', style: AppTextStyles.headline4),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing filters or check back later',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  itemBuilder: (context, i) {
                    final job = jobs[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: JobCard(
                        job: job,
                        onApplyPressed: () => _applyToJob(job),
                        onCardPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsScreen(job: job),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        items: [
          NavigationItem(icon: Icons.home, label: AppStrings.home),
          NavigationItem(
              icon: Icons.assignment, label: AppStrings.myApplications),
          NavigationItem(icon: Icons.person, label: AppStrings.profile),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/myapplication');
              break;
            case 2:
              Navigator.pushNamed(context, '/myprofile');
              break;
          }
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filters', style: AppTextStyles.headline4),
              const SizedBox(height: 16),
              Text('Location', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedLocation),
                initialValue: _locations.contains(_selectedLocation)
                    ? _selectedLocation
                    : 'All',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _locations
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) =>
                    setModalState(() => _selectedLocation = v ?? 'All'),
              ),
              const SizedBox(height: 16),
              Text('Category', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedCategory),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setModalState(() => _selectedCategory = v ?? 'All'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedLocation = 'All';
                          _selectedCategory = 'All';
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
