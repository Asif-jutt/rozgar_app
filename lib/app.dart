import 'package:flutter/material.dart';
import 'package:rozgar/user/screens/BuildProfile/BuildProfile.dart';
import 'package:rozgar/user/screens/Login/Login.dart';
import 'package:rozgar/user/screens/MyProfile/Myprofile.dart';
import 'package:rozgar/user/screens/settings/settings.dart';
import 'package:rozgar/user/screens/Signup/Signup.dart';
import 'package:rozgar/user/screens/home/home.dart';
import 'package:rozgar/user/screens/MyApplication/Myapplication.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rozgar/services/auth_service.dart';

import 'company/screens/dashboard.dart';
import 'company/screens/postjob.dart';
import 'company/screens/companyprofile.dart';
import 'company/screens/manageapplicants.dart';

import 'admin/screens/admindashboard.dart';
import 'admin/screens/usermanage.dart';

class Rozgar extends StatelessWidget {
  const Rozgar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rozgar - Job Portal',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            side: const BorderSide(color: AppColors.primaryColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
      home: _buildHome(),
     routes: {
        // User side
        "/home": (context) => const Home(),
        "/Login": (context) => const Login(),
        "/Signup": (context) => const Signup(),
        "/buildprofile": (context) => const BuildprofileUI(),
        "/myprofile": (context) => const Myprofile(),
        "/myapplication": (context) => const Myapplication(),
        "/settings": (context) => const SettingsPage(),
  

        // Company/Admin side
        "/dashboard": (context) => CompanyDashboard(),
        "/post-jobs": (context) => PostJobsPage(),
        "/company-profile": (context) => CompanyProfilePage(),
        "/manage-applicants": (context) => ManageApplicantsPage(),


        // Admin side
        "/admin": (context) => AdminDashboardPage(),
        "/user-manages": (context) => UsersManageScreen(),
      },
    );
  }

  Widget _buildHome() {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const Home();
        }

        return const Login();
      },
    );
  }
}
