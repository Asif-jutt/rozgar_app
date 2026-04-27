import 'package:flutter/material.dart';
import 'screens/dashboard.dart';
import 'screens/postjob.dart';
import 'screens/companyprofile.dart';
import 'screens/manageapplicants.dart';
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
