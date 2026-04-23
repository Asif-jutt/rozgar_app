import 'package:flutter/material.dart';
import './pages/company/dashboard.dart';
import './pages/company/postjob.dart';
import './pages/company/companyprofile.dart';
import './pages/company/manageapplicants.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(primarySwatch: Colors.purple),
      darkTheme: ThemeData(brightness: Brightness.dark),
      initialRoute: "/home",
      routes: {
        "/home": (context) => CompanyDashboard(),
        "/post-jobs": (context) => PostJobsPage(),
        "/company-profile": (context) => CompanyProfilePage(),
        "/manage-applicants": (context) => ManageApplicantsPage(),
      },
    );
  }
}
