import 'package:flutter/material.dart';
import '../widgets/postjob_body.dart';
import '../widgets/company_shell.dart';
import 'package:rozgar/company/models/job_model.dart';

class PostJobsPage extends StatelessWidget {
  const PostJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jobToEdit = ModalRoute.of(context)?.settings.arguments as JobModel?;

    return CompanyShell(
      title: jobToEdit != null ? 'Edit Job' : 'Post a Job',
      navIndex: 1,
      body: PostJobWidget(jobToEdit: jobToEdit),
    );
  }
}
