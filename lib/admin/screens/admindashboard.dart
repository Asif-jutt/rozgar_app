import 'package:flutter/material.dart';
import '../widgets/admin_body.dart';
import '../widgets/bottomnavigation.dart';
import '../widgets/drawer_admin.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: AdminBody(),
      drawer: AdminDrawer(),
      bottomNavigationBar: const BottomNavigation(),
    );
  }
}