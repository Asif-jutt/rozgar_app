/// Global application constants and configuration
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Application metadata
  static const String appName = 'Rozgar';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // API configuration
  static const String baseApiUrl = 'https://api.rozgar.app';
  static const int apiTimeoutSeconds = 30;
  static const int apiRetryCount = 3;

  // Firebase collections
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String companiesCollection = 'companies';
  static const String adminsCollection = 'admins';
  static const String notificationsCollection = 'notifications';

  // User roles
  static const String roleUser = 'user';
  static const String roleEmployer = 'employer';
  static const String roleAdmin = 'admin';
  static const String roleModeratorAdmin = 'moderator';
  static const String roleSuperAdmin = 'super_admin';

  // Job types
  static const String jobTypeFullTime = 'full-time';
  static const String jobTypePartTime = 'part-time';
  static const String jobTypeContract = 'contract';
  static const String jobTypeInternship = 'internship';
  static const String jobTypeRemote = 'remote';

  // Application status
  static const String statusPending = 'pending';
  static const String statusReviewed = 'reviewed';
  static const String statusShortlisted = 'shortlisted';
  static const String statusRejected = 'rejected';
  static const String statusAccepted = 'accepted';

  // Notification types
  static const String notificationTypeApplication = 'application';
  static const String notificationTypeStatusUpdate = 'status_update';
  static const String notificationTypeJobMatch = 'job_match';
  static const String notificationTypeJobApproved = 'job_approved';
  static const String notificationTypeJobRejected = 'job_rejected';
  static const String notificationTypeMessage = 'message';

  // Local storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyThemeMode = 'theme_mode';
  static const String keyDevMode = 'dev_mode';
  static const String keyLastSyncTime = 'last_sync_time';

  // Encryption
  static const String encryptionPrefix = 'ENC:';

  // Validation patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10,15}$';
  static const String urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';

  // Password requirements
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int bioMaxLength = 500;

  // Timeouts (in seconds)
  static const int connectionTimeout = 15;
  static const int receiveTimeout = 30;

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPageNumber = 1;

  // Cache duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration apiCacheDuration = Duration(hours: 6);

  // Background task intervals
  static const Duration syncJobsInterval = Duration(hours: 6);
  static const Duration syncApplicationsInterval = Duration(hours: 12);
  static const Duration cleanupInterval = Duration(days: 7);

  // Analytics events
  static const String eventAppOpen = 'app_open';
  static const String eventAppClose = 'app_close';
  static const String eventUserLogin = 'user_login';
  static const String eventUserSignup = 'user_signup';
  static const String eventJobView = 'job_view';
  static const String eventJobApplication = 'job_application';
  static const String eventProfileComplete = 'profile_complete';
  static const String eventSearch = 'search_executed';
  static const String eventError = 'app_error';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Colors (hex codes)
  static const int primaryColor = 0xFF00897B;
  static const int primaryDarkColor = 0xFF00695C;
  static const int accentColor = 0xFFFF6F00;
  static const int errorColor = 0xFFE53935;
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFFC107;

  // Asset paths
  static const String assetsPath = 'assets';
  static const String imagesPath = '$assetsPath/images';
  static const String lottiePath = '$assetsPath/lottie';

  // Environment URLs
  static const String privacyPolicyUrl = 'https://rozgar.app/privacy';
  static const String termsOfServiceUrl = 'https://rozgar.app/terms';
  static const String supportUrl = 'https://support.rozgar.app';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundSync = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enableAdMob = true;
  static const bool enableNotifications = true;

  // Admin features
  static const bool adminCanManageUsers = true;
  static const bool adminCanModerateJobs = true;
  static const bool adminCanViewReports = true;
  static const bool adminCanManageAdmins = true;

  // Permission scopes
  static const List<String> requiredPermissions = [
    'INTERNET',
    'ACCESS_NETWORK_STATE',
  ];

  // Supported languages
  static const List<String> supportedLanguages = ['en', 'ur'];

  // Error messages
  static const String errorServerConnection =
      'Server connection failed. Please check your internet and try again.';
  static const String errorInvalidCredentials = 'Invalid email or password.';
  static const String errorUnauthorized =
      'You are not authorized to perform this action.';
  static const String errorNotFound = 'The requested resource was not found.';
  static const String errorServerError =
      'Server error occurred. Please try again later.';
  static const String errorUnknown = 'An unexpected error occurred.';

  // Success messages
  static const String successLoginComplete =
      'You have been logged in successfully.';
  static const String successSignupComplete =
      'Account created successfully. Please verify your email.';
  static const String successProfileUpdated = 'Your profile has been updated.';
  static const String successJobPosted = 'Job has been posted successfully.';
  static const String successApplicationSent =
      'Your application has been sent.';
}

/// Device breakpoints for responsive design
class DeviceBreakpoints {
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// API endpoints
class ApiEndpoints {
  static const String baseUrl = 'https://api.rozgar.app/v1';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/profile';
  static const String userProfileImage = '/users/profile/image';

  // Job endpoints
  static const String jobs = '/jobs';
  static const String jobDetail = '/jobs/{jobId}';
  static const String jobSearch = '/jobs/search';

  // Application endpoints
  static const String applications = '/applications';
  static const String applicationDetail = '/applications/{applicationId}';
  static const String userApplications = '/users/applications';

  // Company endpoints
  static const String companies = '/companies';
  static const String companyProfile = '/companies/profile';
  static const String companyJobs = '/companies/{companyId}/jobs';

  // Admin endpoints
  static const String adminUsers = '/admin/users';
  static const String adminJobs = '/admin/jobs';
  static const String adminReports = '/admin/reports';

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String resetPassword = '/auth/reset-password';
}

/// Firebase Realtime Database paths
class FirebasePaths {
  static const String usersOnline = 'users_online';
  static const String jobUpdates = 'job_updates';
  static const String applicationUpdates = 'application_updates';
  static const String systemNotifications = 'system_notifications';
}

/// Shared preferences keys
class SharedPrefKeys {
  static const String isFirstLaunch = 'is_first_launch';
  static const String isLoggedIn = 'is_logged_in';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String isDarkMode = 'is_dark_mode';
  static const String deviceLanguage = 'device_language';
  static const String lastOpenedScreen = 'last_opened_screen';
  static const String appVersion = 'app_version';
  static const String lastUpdateCheck = 'last_update_check';
}

/// Hive box names
class HiveBoxes {
  static const String settings = 'settings';
  static const String jobs = 'jobs';
  static const String applications = 'pending_applications';
  static const String notifications = 'notifications_cache';
  static const String userCache = 'user_cache';
  static const String companyCache = 'company_cache';
  static const String adminCache = 'admin_cache';
}
