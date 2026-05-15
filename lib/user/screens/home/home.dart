import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/models/job_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/screens/job_details/job_details.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/widgets/drawer.dart';
import 'package:rozgar/user/widgets/job_card.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JobModel> _filter(List<JobModel> jobs) {
    final q = _searchQuery.trim().toLowerCase();
    return jobs.where((job) {
      if (_selectedLocation != 'All' && job.location != _selectedLocation) {
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied to ${job.title}'),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
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
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        items: [
          NavigationItem(icon: Icons.home, label: AppStrings.home),
          NavigationItem(icon: Icons.assignment, label: AppStrings.myApplications),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: AppTextStyles.headline4),
            const SizedBox(height: 16),
            const Text('Location'),
            const SizedBox(height: 8),
            Text('Use search bar for quick filter. Location: $_selectedLocation'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
