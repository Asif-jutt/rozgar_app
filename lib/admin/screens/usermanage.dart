import 'package:flutter/material.dart';
import '../widgets/bottomnavigation.dart';
import '../widgets/userbody.dart';
import '../widgets/drawer_admin.dart';

class UsersManageScreen extends StatelessWidget {
  const UsersManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Manage'),
      ),

      body: UserBody(),
      drawer: AdminDrawer(),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}