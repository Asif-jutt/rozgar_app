import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/auth_helper.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class CompanyDrawer extends StatelessWidget {
  const CompanyDrawer({super.key});

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
                AuthHelper.initials(user?.displayName ?? 'C'),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(user?.displayName ?? 'Company'),
            accountEmail: Text(user?.email ?? ''),
          ),
          _item(context, Icons.dashboard, 'Dashboard', '/company_dashboard'),
          _item(context, Icons.post_add, 'Post a Job', '/post-jobs'),
          _item(context, Icons.people, 'Manage Applicants', '/manage-applicants'),
          _item(context, Icons.business, 'Company Profile', '/company-profile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorColor),
            title: const Text('Logout', style: TextStyle(color: AppColors.errorColor)),
            onTap: () => AuthHelper.logout(context),
          ),
        ],
      ),
    );
  }

  Widget _item(
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
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
