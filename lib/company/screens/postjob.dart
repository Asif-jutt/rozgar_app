import 'package:flutter/material.dart';
import '../widgets/bottomnav.dart';
import '../widgets//postjob_body.dart';
import '../widgets/drawer_company.dart';



class PostJobsPage extends StatelessWidget {
  const PostJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Post a New Job",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        child: PostJobWidget(),
      ),
      drawer: const CompanyDrawer(),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
