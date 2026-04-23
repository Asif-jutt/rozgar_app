import 'package:flutter/material.dart';
import '../../widgets/company/bottomnav.dart';
import '../../widgets/company/postjob_body.dart';

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

      bottomNavigationBar: BottomNavigation(),
    );
  }
}
