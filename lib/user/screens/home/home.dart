import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/user/models/feed_job.dart';
import 'package:rozgar/user/providers/jobs_feed_provider.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/services/notification_service.dart';
import 'package:rozgar/services/rest_api_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/screens/job_details/job_details.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/widgets/drawer.dart';
import 'package:rozgar/core/widgets/banner_ad_widget.dart';
import 'package:rozgar/core/widgets/unified_job_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  int _selectedBottomNavIndex = 0;
  List<String> _locations = RestApiService.defaultLocations;
  static const _categories = [
    'All', 'IT', 'Engineering', 'Marketing', 'Sales', 'Finance', 'Design',
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

  Future<void> _applyToJob(FeedJob job) async {
    if (job.isApi) {
      final uri = Uri.tryParse(job.externalUrl ?? '');
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      if (await _firestore.hasUserApplied(userId: user.uid, jobId: job.id)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already applied to this job.')),
        );
        return;
      }

      final profile = await _firestore.getUserProfile(user.uid);
      final userDoc = await _firestore.getUser(user.uid);

      await _firestore.applyToJob(
        jobId: job.id,
        userId: user.uid,
        companyId: job.companyId!,
        jobTitle: job.title,
        applicantName: userDoc?.name ?? user.displayName ?? 'Applicant',
        resumeText: profile?.cvResumeUrl ?? '',
      );

      await NotificationService().sendNotification(
        userId: user.uid,
        title: 'Application Sent',
        body: 'You applied to ${job.title}',
        type: 'application',
        relatedId: job.id,
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
    final feed = context.watch<JobsFeedProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.findJobs),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.pushNamed(context, '/saved-jobs'),
          ),
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
              onChanged: feed.setSearch,
              onFilterPressed: () => _showFilters(feed),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SegmentedButton<JobFeedTab>(
              segments: const [
                ButtonSegment(
                  value: JobFeedTab.all,
                  label: Text('All'),
                  icon: Icon(Icons.grid_view, size: 18),
                ),
                ButtonSegment(
                  value: JobFeedTab.local,
                  label: Text('Rozgar'),
                  icon: Icon(Icons.business, size: 18),
                ),
                ButtonSegment(
                  value: JobFeedTab.api,
                  label: Text('API'),
                  icon: Icon(Icons.public, size: 18),
                ),
              ],
              selected: {feed.tab},
              onSelectionChanged: (s) => feed.setTab(s.first),
            ),
          ),
          Expanded(
            child: feed.loading
                ? const Center(child: CircularProgressIndicator())
                : feed.error != null
                    ? Center(child: Text('Error: ${feed.error}'))
                    : feed.jobs.isEmpty
                        ? _emptyState()
                        : RefreshIndicator(
                            onRefresh: feed.refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: feed.jobs.length,
                              itemBuilder: (context, i) {
                                final job = feed.jobs[i];
                                return UnifiedJobCard(
                                  job: job,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JobDetailsScreen(feedJob: job),
                                    ),
                                  ),
                                  onApply: () => _applyToJob(job),
                                  onCommentTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          JobDetailsScreen(feedJob: job),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        items: [
          NavigationItem(icon: Icons.home, label: AppStrings.home),
          NavigationItem(icon: Icons.chat, label: AppStrings.messages),
          NavigationItem(
              icon: Icons.assignment, label: AppStrings.myApplications),
          NavigationItem(icon: Icons.person, label: AppStrings.profile),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/messages');
              break;
            case 2:
              Navigator.pushNamed(context, '/myapplication');
              break;
            case 3:
              Navigator.pushNamed(context, '/myprofile');
              break;
          }
        },
      ),
    );
  }

  Widget _emptyState() {
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
          Text('Try changing filters or check back later',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _showFilters(JobsFeedProvider feed) {
    var loc = 'All';
    var cat = 'All';
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
                key: ValueKey(loc),
                initialValue: _locations.contains(loc) ? loc : 'All',
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _locations
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setModalState(() => loc = v ?? 'All'),
              ),
              const SizedBox(height: 16),
              Text('Category', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(cat),
                initialValue: cat,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setModalState(() => cat = v ?? 'All'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setModalState(() {
                        loc = 'All';
                        cat = 'All';
                      }),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        feed.setFilters(location: loc, category: cat);
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
