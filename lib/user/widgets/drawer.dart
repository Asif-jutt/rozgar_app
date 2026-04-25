import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.secondaryColor,
                  child: const Text(
                    'JD',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Job Seeker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'user@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primaryColor),
            title: const Text(AppStrings.home),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: AppColors.primaryColor),
            title: const Text(AppStrings.findJobs),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primaryColor),
            title: const Text(AppStrings.myProfile),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/myprofile');
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.assignment,
              color: AppColors.primaryColor,
            ),
            title: const Text(AppStrings.myApplications),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/myapplication');
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: AppColors.primaryColor),
            title: const Text(AppStrings.buildProfile),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/buildprofile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primaryColor),
            title: const Text(AppStrings.settings),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorColor),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.errorColor),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/Login');
            },
          ),
        ],
      ),
    );
  }
}
