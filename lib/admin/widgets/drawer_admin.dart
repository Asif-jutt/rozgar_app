import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          const UserAccountsDrawerHeader(
            accountName: Text('Admin'),
            accountEmail: Text('admin@rozgar.com'),
            currentAccountPicture: CircleAvatar(
              child: Icon(Icons.admin_panel_settings),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.work),
            title: const Text('View All Jobs'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Manage Company'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users Manage'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Manage Applicants'),
            onTap: () {},
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}