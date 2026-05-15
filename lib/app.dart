import 'package:flutter/material.dart';
import 'package:rozgar/screens/splash_screen.dart';
import 'package:rozgar/screens/auth/login_screen.dart';
import 'package:rozgar/screens/auth/signup_screen.dart';
import 'package:rozgar/user/screens/BuildProfile/BuildProfile.dart';
import 'package:rozgar/user/screens/home/home.dart';
import 'package:rozgar/user/screens/MyApplication/Myapplication.dart';
import 'package:rozgar/user/screens/MyProfile/Myprofile.dart';
import 'package:rozgar/user/screens/notifications/notifications_screen.dart';
import 'package:rozgar/user/constants/app_constants.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.secondaryColor,
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: AppDimensions.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
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
          fillColor: AppColors.surfaceColor,
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
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: AppColors.secondaryColor,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/user_home': (context) => const Home(),
        '/buildprofile': (context) => const BuildprofileUI(),
        '/myprofile': (context) => const Myprofile(),
        '/myapplication': (context) => const Myapplication(),
        '/notifications': (context) => const NotificationsScreen(),
        '/company_dashboard': (context) => const CompanyDashboard(),
        '/post-jobs': (context) => const PostJobsPage(),
        '/company-profile': (context) => const CompanyProfilePage(),
        '/manage-applicants': (context) => const ManageApplicantsPage(),
        '/admin_dashboard': (context) => const AdminDashboardPage(),
        '/user-manages': (context) => const UsersManageScreen(),
      },
    );
  }
}
