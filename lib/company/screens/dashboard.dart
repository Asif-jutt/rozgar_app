import 'package:flutter/material.dart';
import '../widgets/dashbody.dart';
import '../widgets/company_shell.dart';

class CompanyDashboard extends StatelessWidget {
  const CompanyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const CompanyShell(
      title: 'Company Dashboard',
      navIndex: 0,
      body: DashboardBody(),
    );
  }
}
