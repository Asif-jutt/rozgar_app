import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF0D47A1); // Deep Blue
  static const Color primaryLight = Color(0xFF1976D2); // Light Blue
  static const Color primaryDark = Color(0xFF0D3B66); // Dark Blue

  // Secondary Colors
  static const Color secondaryColor = Color(0xFFFFC400); // Amber
  static const Color secondaryLight = Color(0xFFFFD54F);

  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF212121); // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color borderColor = Color(0xFFE0E0E0); // Light Border

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFA726); // Orange
  static const Color errorColor = Color(0xFFE53935); // Red
  static const Color infoColor = Color(0xFF29B6F6); // Light Blue

  // Shadows
  static const Color shadowColor = Color(0x1F000000);
}

class AppStrings {
  // Authentication
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String cnic = 'CNIC Number';
  static const String forgotPassword = 'Forgot Password?';

  // Navigation
  static const String home = 'Home';
  static const String myJobs = 'My Jobs';
  static const String messages = 'Messages';
  static const String profile = 'Profile';
  static const String admin = 'Settings';
  static const String company = 'Settings';
  static const String settings = 'Settings';
  static const String logout = 'Logout';
  static const String archived = 'Archived';
  static const String interviews = 'Interviews';

  // Jobs
  static const String findJobs = 'Find Jobs';
  static const String myApplications = 'My Applications';
  static const String buildProfile = 'Build Profile';
  static const String myProfile = 'My Profile';
  static const String applyNow = 'Apply Now';
  static const String viewDetails = 'View Details';
  static const String applied = 'Applied';
  static const String searching = 'Searching...';

  // Profile
  static const String selectSkills = 'Select Skills';
  static const String enterDegrees = 'Enter Degrees';
  static const String address = 'Address';
  static const String uploadCV = 'Upload CV';
  static const String create = 'Create';
  static const String edit = 'Edit';
  static const String save = 'Save';

  // Filters
  static const String location = 'Location';
  static const String salary = 'Salary';
  static const String skills = 'Skills';
  static const String search = 'Search jobs...';

  // Status
  static const String appliedStatus = 'Applied';
  static const String underReview = 'Under Review';
  static const String interview = 'Interview';
  static const String rejected = 'Rejected';
  static const String accepted = 'Accepted';

  // Labels
  static const String jobTitle = 'Job Title';
  static const String companyName = 'Company Name';
  static const String applicationStatus = 'Application Status';
  static const String mySkills = 'My Skills';
  static const String myEducations = 'My Educations';
  static const String otherInfo = 'Other Information';
  static const String welcome = 'Welcome';
}

class AppTextStyles {
  // Headlines
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

class AppDimensions {
  // Padding/Margin
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Height
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
}

class AppSpacing {
  static const double verticalSpaceSmall = 8.0;
  static const double verticalSpaceMedium = 16.0;
  static const double verticalSpaceLarge = 24.0;

  static const double horizontalSpaceSmall = 8.0;
  static const double horizontalSpaceMedium = 16.0;
  static const double horizontalSpaceLarge = 24.0;
}
