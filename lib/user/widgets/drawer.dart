import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/auth_helper.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class SeekerDrawer extends StatelessWidget {
  const SeekerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryColor),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.secondaryColor,
              child: Text(
                AuthHelper.initials(user?.displayName ?? 'User'),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(user?.displayName ?? 'Job Seeker'),
            accountEmail: Text(user?.email ?? ''),
          ),
          _tile(context, Icons.home, AppStrings.home, '/user_home'),
          _tile(context, Icons.person, AppStrings.myProfile, '/myprofile'),
          _tile(context, Icons.assignment, AppStrings.myApplications, '/myapplication'),
          _tile(context, Icons.favorite, 'Saved Jobs', '/saved-jobs'),
          _tile(context, Icons.chat, AppStrings.messages, '/messages'),
          _tile(context, Icons.edit, AppStrings.buildProfile, '/buildprofile'),
          _tile(context, Icons.notifications, 'Notifications', '/notifications'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorColor),
            title: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.errorColor),
            ),
            onTap: () => AuthHelper.logout(context),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}
