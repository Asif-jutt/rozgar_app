import 'package:flutter/material.dart';
import '../widgets/userbody.dart';
import '../widgets/drawer_admin.dart';
import '../widgets/bottomnavigation.dart';

class UsersManageScreen extends StatelessWidget {
  const UsersManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      drawer: const AdminDrawer(),
      body: const UserBody(),
      bottomNavigationBar: AdminBottomNav(currentIndex: 1),
    );
  }
}
