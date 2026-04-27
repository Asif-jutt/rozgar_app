import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/widgets/job_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedBottomNavIndex = 0;
  List<Job> jobs = [];
  String _selectedLocation = 'All';

  @override
  void initState() {
    super.initState();
    _generateSampleJobs();
  }

  void _generateSampleJobs() {
    jobs = [
      Job(
        id: '1',
        jobTitle: 'Flutter Developer',
        companyName: 'Tech Solutions Inc',
        location: 'Karachi',
        salary: '100k - 150k',
        requiredSkills: ['Flutter', 'Dart', 'Firebase', 'REST API'],
        description: 'We are looking for an experienced Flutter developer...',
        postedDate: DateTime.now().subtract(const Duration(days: 2)),
        jobType: 'Full-time',
        image: 'assets/Images/flutter_developer.png',
      ),
      Job(
        id: '2',
        jobTitle: 'Mobile App Developer',
        companyName: 'Digital Agency',
        location: 'Lahore',
        salary: '80k - 120k',
        requiredSkills: ['React Native', 'JavaScript', 'Redux'],
        description: 'Join our dynamic team of mobile developers...',
        postedDate: DateTime.now().subtract(const Duration(days: 5)),
        jobType: 'Full-time',
        image: 'assets/Images/mad_developer.jpeg',
      ),
      Job(
        id: '3',
        jobTitle: 'UI/UX Designer',
        companyName: 'Creative Studio',
        location: 'Islamabad',
        salary: '60k - 90k',
        requiredSkills: ['Figma', 'UI Design', 'Prototyping'],
        description: 'Design beautiful user interfaces for our apps...',
        postedDate: DateTime.now().subtract(const Duration(days: 1)),
        jobType: 'Part-time',
        image: 'assets/Images/ui_ux_designer.jpeg',
      ),
      Job(
        id: '4',
        jobTitle: 'Backend Developer',
        companyName: 'Cloud Systems',
        location: 'Karachi',
        salary: '120k - 180k',
        requiredSkills: ['Node.js', 'MongoDB', 'AWS', 'Docker'],
        description: 'Build scalable backend solutions...',
        postedDate: DateTime.now().subtract(const Duration(days: 3)),
        jobType: 'Full-time',
        image: 'assets/Images/backend_developer.png',
      ),
      Job(
        id: '5',
        jobTitle: 'QA Tester',
        companyName: 'Quality Assurance Ltd',
        location: 'Lahore',
        salary: '50k - 70k',
        requiredSkills: ['Manual Testing', 'Automation', 'Selenium'],
        description: 'Ensure quality of our software products...',
        postedDate: DateTime.now(),
        jobType: 'Full-time',
        image: 'assets/Images/qa_engineer.jpeg',
      ),
      Job(
        id: '6',
        jobTitle: 'Data Analyst',
        companyName: 'Analytics Pro',
        location: 'Karachi',
        salary: '90k - 140k',
        requiredSkills: ['Python', 'SQL', 'Tableau', 'Excel'],
        description: 'Analyze data and generate insights...',
        postedDate: DateTime.now().subtract(const Duration(days: 7)),
        jobType: 'Full-time',
        image: 'assets/Images/data_analyst.png',
      ),
    ];
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
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.home,
        actions: [
          IconButton(
            icon: Tooltip(
              message: "Notifications",
              child: const Icon(Icons.notifications_none, color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/Notifications');
            },
          ),
          IconButton(
            icon: Tooltip(
              message: "Login",
              child: const Icon(Icons.login, color: Colors.white),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/Login');
            },
          ),
        ],
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
                    label: Text(AppStrings.location),
                    onSelected: (_) => _showFilterDialog(),
                  ),

                  const SizedBox(width: 8),

                  FilterChip(
                    label: const Text('Salary: All'),
                    onSelected: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Salary filter coming soon"),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 8),

                  FilterChip(
                    label: const Text('Job Type: All'),
                    onSelected: (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Job type filter coming soon"),
                        ),
                      );
                    },
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
                childAspectRatio:
                    1.1, // handles card size (white spacing b/w the cards)
                crossAxisSpacing: AppSpacing.horizontalSpaceMedium,
                mainAxisSpacing: AppSpacing.verticalSpaceMedium,
              ),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return JobCard(
                  job: jobs[index],
                  onApplyPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied to ${jobs[index].jobTitle}'),
                      ),
                    );
                  },
                  onCardPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing ${jobs[index].jobTitle}'),
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
}
