import 'package:flutter/material.dart';
import '../widgets/profilebody.dart';
import '../widgets/bottomnav.dart';
import '../widgets/drawer_company.dart';

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Company Profile"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Posted Jobs",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Expanded(child: JobsGrid()),

            const SizedBox(height: 20),

            const Text(
              "Company Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: 90,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "Tech Company - Top Rated",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Other Info",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Employees", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 5),
                        Text("50+", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Location", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 5),
                        Text("Pakistan", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
            bottomNavigationBar: BottomNavigation(),
            drawer: const CompanyDrawer(),
    );
  }
}
