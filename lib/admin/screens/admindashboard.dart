import 'package:flutter/material.dart';
import '../widgets/admin_body.dart';
import '../widgets/drawer_admin.dart';
import '../widgets/bottomnavigation.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      drawer: const AdminDrawer(),
      body: const AdminBody(),
      bottomNavigationBar: AdminBottomNav(currentIndex: 0),
    );
  }
}
