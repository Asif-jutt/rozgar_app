import 'package:flutter/material.dart';

class CompanyDrawer extends StatelessWidget {
  const CompanyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        children: [

          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF1E1E1E),
            ),
            child: Text(
              "Company Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white),
            title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, "/home");
            },
          ),

          ListTile(
            leading: const Icon(Icons.post_add, color: Colors.white),
            title: const Text("Post a Job", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, "/post-jobs");
            },
          ),

          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text("Company Profile", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, "/company-profile");
            },
          ),

          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text("Manage Applicants", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, "/manage-applicants");
            },
          ),

          ListTile(
            leading: const Icon(Icons.message, color: Colors.white),
            title: const Text("Messages", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, "/messages");
            },
          ),

          const Divider(color: Colors.grey),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}