import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/admin/screens/admin_dashboard_screen.dart';
import 'package:rozgar/admin/screens/admin_settings_screen.dart';
import 'package:rozgar/admin/screens/job_moderation_screen.dart';
import 'package:rozgar/admin/screens/reports_screen.dart';
import 'package:rozgar/admin/screens/user_management_screen.dart';
import 'package:rozgar/company/screens/applicant_detail_screen.dart';
import 'package:rozgar/company/screens/applicants_screen.dart';
import 'package:rozgar/company/screens/company_home_screen.dart';
import 'package:rozgar/company/screens/company_profile_screen.dart';
import 'package:rozgar/company/screens/my_jobs_screen.dart';
import 'package:rozgar/company/screens/post_job_screen.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/connectivity_provider.dart';
import 'package:rozgar/shared/providers/theme_provider.dart';
import 'package:rozgar/shared/widgets/dev_mode_overlay.dart';
import 'package:rozgar/shared/widgets/offline_banner.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/screens/apply_screen.dart';
import 'package:rozgar/user/screens/job_detail_screen.dart';
import 'package:rozgar/user/screens/job_feed_screen.dart';
import 'package:rozgar/user/screens/login_screen.dart';
import 'package:rozgar/user/screens/my_applications_screen.dart';
import 'package:rozgar/user/screens/notifications_screen.dart';
import 'package:rozgar/user/screens/onboarding_screen.dart';
import 'package:rozgar/user/screens/register_screen.dart';
import 'package:rozgar/user/screens/role_selection_screen.dart';
import 'package:rozgar/user/screens/saved_jobs_screen.dart';
import 'package:rozgar/user/screens/seeker_profile_screen.dart';
import 'package:rozgar/user/screens/splash_screen.dart';

/// Main application widget
/// Configures the Material app with routing, theming, and offline connectivity banner
class RozgarApp extends StatelessWidget {
  const RozgarApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('Building RozgarApp');

    return Obx(() {
      final themeProvider = ThemeProvider.to;

      return GetMaterialApp(
        /// App configuration
        title: 'Rozgar - Job Portal',
        debugShowCheckedModeBanner: kDebugMode,

        /// Theme configuration with Material 3
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: themeProvider.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,

        /// Routing configuration
        initialRoute: AppRoutes.splash,
        getPages: _buildRoutes(),

        /// Global overlay builder with offline banner
        builder: (context, child) {
          return DevModeOverlay(
            child: Column(
              children: [
                /// Offline connectivity banner
                Obx(() {
                  final isOffline = ConnectivityProvider.to.isOffline.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isOffline
                        ? const OfflineBanner()
                        : const SizedBox.shrink(),
                  );
                }),

                /// Main app content
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          );
        },

        /// Localization and internationalization
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],

        /// Global behaviors
        popGesture: true,
        smartManagement: SmartManagement.full,
        defaultTransition: Transition.cupertino,
      );
    });
  }

  /// Builds light theme with Material 3
  static ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF00897B); // Teal
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      /// Typography
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: const Color(0xFF212121),
        displayColor: const Color(0xFF212121),
      ),

      /// Card styling
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      /// App bar styling
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      /// Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      /// FAB styling
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      /// Scaffold background
      scaffoldBackgroundColor: Colors.white,
    );
  }

  /// Builds dark theme with Material 3
  static ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF00897B); // Teal
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      /// Typography
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: const Color(0xFFE0E0E0),
        displayColor: const Color(0xFFE0E0E0),
      ),

      /// Card styling
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      /// App bar styling
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      /// Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3C3C3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4C4C4C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4C4C4C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      /// FAB styling
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      /// Scaffold background
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  /// Builds all application routes
  static List<GetPage> _buildRoutes() {
    return [
      /// Splash and onboarding
      GetPage(
        name: AppRoutes.splash,
        page: () => const SplashScreen(),
        transition: Transition.fade,
      ),
      GetPage(
        name: AppRoutes.onboarding,
        page: () => const OnboardingScreen(),
        transition: Transition.fadeIn,
      ),

      /// Authentication
      GetPage(
        name: AppRoutes.roleSelect,
        page: () => const RoleSelectionScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.login,
        page: () => const LoginScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.register,
        page: () => const RegisterScreen(),
        transition: Transition.cupertino,
      ),

      /// User role routes
      GetPage(
        name: AppRoutes.userFeed,
        page: () => const JobFeedScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.userJobDetail,
        page: () => const JobDetailScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.userApply,
        page: () => const ApplyScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.userApplications,
        page: () => const MyApplicationsScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.userProfile,
        page: () => const SeekerProfileScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.userSaved,
        page: () => const SavedJobsScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.userNotifications,
        page: () => const NotificationsScreen(),
        transition: Transition.cupertino,
      ),

      /// Company role routes
      GetPage(
        name: AppRoutes.companyHome,
        page: () => const CompanyHomeScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.companyPostJob,
        page: () => const PostJobScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.companyMyJobs,
        page: () => const MyJobsScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.companyApplicants,
        page: () => const ApplicantsScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.companyApplicantDetail,
        page: () => const ApplicantDetailScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.companyProfile,
        page: () => const CompanyProfileScreen(),
        transition: Transition.cupertino,
      ),

      /// Admin role routes
      GetPage(
        name: AppRoutes.adminDashboard,
        page: () => const AdminDashboardScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.adminUsers,
        page: () => const UserManagementScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.adminJobs,
        page: () => const JobModerationScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.adminReports,
        page: () => const ReportsScreen(),
        transition: Transition.cupertino,
      ),
      GetPage(
        name: AppRoutes.adminSettings,
        page: () => const AdminSettingsScreen(),
        transition: Transition.cupertino,
      ),
    ];
  }
}
