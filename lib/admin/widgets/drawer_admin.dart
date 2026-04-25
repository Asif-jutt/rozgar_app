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
              Navigator.pushNamed(context, "/admin" );
            },
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () { 
              Navigator.pushNamed(context, "/home");
            },
          ),

          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Manage Company'),
            onTap: () {
              Navigator.pushNamed(context, "/user-manage");
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users Manage'),
            onTap: () {
              Navigator.pushNamed(context, "/users-manage");
            },
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