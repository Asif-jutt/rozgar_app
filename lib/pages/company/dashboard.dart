import 'package:flutter/material.dart';
import '../../widgets/company/dashbody.dart';
import '../../widgets/company/bottomnav.dart';
class CompanyDashboard extends StatelessWidget {
  const CompanyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0A1D37),
        title: Row(
          children: const [
            Icon(Icons.business, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Company Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF0A1D37)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
  child: DashboardBody(),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}