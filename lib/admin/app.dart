import 'package:flutter/material.dart';
import 'screens/admindashboard.dart';
import 'screens/usermanage.dart';

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
      initialRoute: "/admin",
      routes: {
          "/admin": (context) => AdminDashboardPage(),
          "/user-manages": (context) => UsersManageScreen(),
          // "/post-jobs": (context) => PostJobsPage(),
          // "/company-profile": (context) => CompanyProfilePage(),
          // "/manage-applicants": (context) => ManageApplicantsPage(),
      },
    );
  }
}
