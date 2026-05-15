import 'package:flutter/material.dart';
import '../widgets/postjob_body.dart';
import '../widgets/company_shell.dart';

class PostJobsPage extends StatelessWidget {
  const PostJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompanyShell(
      title: 'Post a Job',
      navIndex: 1,
      body: PostJobWidget(),
    );
  }
}
