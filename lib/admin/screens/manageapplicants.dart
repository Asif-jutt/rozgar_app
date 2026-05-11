import 'package:flutter/material.dart';
import 'package:rozgar/admin/widgets/drawer_admin.dart';

class Manageapplicants extends StatelessWidget {
  const Manageapplicants({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      body: Center(
        child: Column(
          children: [
            Text("Manage Applicants"),
          ],
        ),
      ),
    );
  }
}