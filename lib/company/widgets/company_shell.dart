import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/company/widgets/drawer_company.dart';

class CompanyShell extends StatelessWidget {
  final String title;
  final Widget body;
  final int navIndex;
  final Widget? floatingActionButton;

  const CompanyShell({
    super.key,
    required this.title,
    required this.body,
    this.navIndex = 0,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/company-notifications'),
          ),
        ],
      ),
      drawer: const CompanyDrawer(),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(context, '/company_dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/post-jobs');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/manage-applicants');
              break;
            case 3:
              Navigator.pushNamed(context, '/messages');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/company-profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.post_add), label: 'Post'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Applicants'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.business), label: 'Profile'),
        ],
      ),
    );
  }
}
