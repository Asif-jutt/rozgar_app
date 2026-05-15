import 'package:flutter/material.dart';
import 'package:rozgar/core/auth_helper.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user-manages');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.errorColor),
            title: const Text('Logout',
                style: TextStyle(color: AppColors.errorColor)),
            onTap: () => AuthHelper.logout(context),
          ),
        ],
      ),
    );
  }
}
