import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rozgar/admin/providers/admin_auth_provider.dart';
import 'package:rozgar/admin/providers/job_moderation_provider.dart';
import 'package:rozgar/admin/providers/reports_provider.dart';
import 'package:rozgar/admin/providers/user_management_provider.dart';
import 'package:rozgar/app.dart';
import 'package:rozgar/company/providers/applicants_provider.dart';
import 'package:rozgar/company/providers/company_auth_provider.dart';
import 'package:rozgar/company/providers/company_profile_provider.dart';
import 'package:rozgar/company/providers/post_job_provider.dart';
import 'package:rozgar/firebase_options.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/ad_service.dart';
import 'package:rozgar/shared/providers/connectivity_provider.dart';
import 'package:rozgar/shared/providers/notification_service.dart';
import 'package:rozgar/shared/providers/theme_provider.dart';
import 'package:rozgar/user/providers/application_provider.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:rozgar/user/providers/job_provider.dart';
import 'package:rozgar/user/providers/profile_provider.dart';
import 'package:workmanager/workmanager.dart';

/// Firebase Cloud Messaging background handler
/// Processes incoming FCM messages when app is in background or terminated
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Hive.initFlutter();
    AppLogger.i('FCM background message: ${message.notification?.title}');

    final notificationsBox = Hive.box('notifications_cache');
    final notifications =
        (notificationsBox.get('items') as List?)?.cast<Map>() ?? [];

    notifications.insert(0, {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await notificationsBox.put('items', notifications);
    AppLogger.i('Notification cached: ${message.data['type']}');
  } catch (e, st) {
    AppLogger.e('FCM background handler error', st);
  }
}

/// WorkManager background task dispatcher
/// Executes scheduled background tasks for data synchronization and cleanup
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await Hive.initFlutter();

      switch (task) {
        case 'sync_jobs_task':
          AppLogger.i('WorkManager: Syncing job data');
          final jobsBox = Hive.box('jobs');
          // Placeholder for actual job sync logic
          AppLogger.i('Job sync completed');
          return true;

        case 'sync_applications_task':
          AppLogger.i('WorkManager: Syncing application data');
          final appsBox = Hive.box('pending_applications');
          // Placeholder for actual application sync logic
          AppLogger.i('Application sync completed');
          return true;

        case 'cleanup_cache_task':
          AppLogger.i('WorkManager: Cleaning up local cache');
          final jobsBox = Hive.box('jobs');
          final appsBox = Hive.box('pending_applications');
          await jobsBox.clear();
          await appsBox.clear();
          AppLogger.i('Cache cleanup completed');
          return true;

        default:
          AppLogger.w('Unknown WorkManager task: $task');
          return false;
      }
    } catch (e, st) {
      AppLogger.e('WorkManager error in $task', st);
      return false;
    }
  });
}

/// Initializes all notification services
/// Sets up FCM, local notifications, and background message handlers
Future<void> _initNotifications() async {
  try {
    await NotificationService.instance.initialize();
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    AppLogger.i('Notification services initialized');
  } catch (e, st) {
    AppLogger.e('Failed to initialize notifications', st);
  }
}

/// Initializes Hive local storage boxes
/// Creates persistent storage for app cache and offline data
Future<void> _initHiveBoxes() async {
  try {
    await Hive.initFlutter();

    const boxes = [
      'settings',
      'jobs',
      'pending_applications',
      'notifications_cache',
      'user_cache',
      'company_cache',
      'admin_cache',
    ];

    for (final boxName in boxes) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
    }

    AppLogger.i('Hive boxes initialized: ${boxes.join(", ")}');
  } catch (e, st) {
    AppLogger.e('Failed to initialize Hive boxes', st);
    rethrow;
  }
}

/// Initializes encryption service for sensitive data protection
Future<void> _initEncryption() async {
  try {
    await EncryptionHelper.generateAndStoreKey();
    AppLogger.i('Encryption service initialized');
  } catch (e, st) {
    AppLogger.e('Failed to initialize encryption', st);
    if (!kIsWeb) rethrow;
  }
}

/// Initializes Firebase services
/// Configures Firebase core, authentication, Firestore, and performance monitoring
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Crashlytics is mobile-only; web uses console logging via AppLogger
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    AppLogger.i('Firebase initialized successfully');
  } catch (e, st) {
    AppLogger.e('Failed to initialize Firebase', st);
    rethrow;
  }
}

/// Initializes background task scheduler (WorkManager)
/// Sets up periodic background tasks for data sync and cleanup
Future<void> _initBackgroundTasks() async {
  try {
    if (kIsWeb) {
      AppLogger.i('Skipping WorkManager on web platform');
      return;
    }

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    // Register periodic tasks
    await Workmanager().registerPeriodicTask(
      'sync_jobs_periodic',
      'sync_jobs_task',
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
      backoffPolicy: BackoffPolicy.exponential,
    );

    await Workmanager().registerPeriodicTask(
      'sync_apps_periodic',
      'sync_applications_task',
      frequency: const Duration(hours: 12),
      constraints: Constraints(networkType: NetworkType.connected),
    );

    await Workmanager().registerPeriodicTask(
      'cleanup_periodic',
      'cleanup_cache_task',
      frequency: const Duration(days: 7),
      constraints: Constraints(networkType: NetworkType.connected),
    );

    AppLogger.i('Background tasks initialized');
  } catch (e, st) {
    AppLogger.e('Failed to initialize background tasks', st);
    // Don't rethrow - background tasks are non-critical
  }
}

/// Initializes GetX dependency injection and state management
/// Lazily loads all providers to ensure they're available when needed
void _initGetXProviders() {
  try {
    // Global providers
    Get.lazyPut(() => AuthProvider(), fenix: true);
    Get.lazyPut(() => ThemeProvider(), fenix: true);
    Get.lazyPut(() => ConnectivityProvider(), fenix: true);
    Get.lazyPut(() => NotificationService.instance, fenix: true);

    // User role providers
    Get.lazyPut(() => JobProvider(), fenix: true);
    Get.lazyPut(() => ApplicationProvider(), fenix: true);
    Get.lazyPut(() => ProfileProvider(), fenix: true);

    // Company role providers
    Get.lazyPut(() => CompanyAuthProvider(), fenix: true);
    Get.lazyPut(() => PostJobProvider(), fenix: true);
    Get.lazyPut(() => ApplicantsProvider(), fenix: true);
    Get.lazyPut(() => CompanyProfileProvider(), fenix: true);

    // Admin role providers
    Get.lazyPut(() => AdminAuthProvider(), fenix: true);
    Get.lazyPut(() => UserManagementProvider(), fenix: true);
    Get.lazyPut(() => JobModerationProvider(), fenix: true);
    Get.lazyPut(() => ReportsProvider(), fenix: true);

    // Monetization provider
    Get.lazyPut(() => AdService.instance, fenix: true);

    AppLogger.i('GetX providers initialized');
  } catch (e, st) {
    AppLogger.e('Failed to initialize GetX providers', st);
    rethrow;
  }
}

/// Initializes advertisement service for monetization
Future<void> _initAdService() async {
  if (!AdService.instance.isSupported) {
    AppLogger.i('Skipping ad service on unsupported platform');
    return;
  }
  try {
    await AdService.instance.init();
    AppLogger.i('Ad service initialized');
  } catch (e, st) {
    AppLogger.e('Failed to initialize ad service', st);
    // Non-critical - don't rethrow
  }
}

/// Application entry point
/// Initializes all services with proper error handling using runZonedGuarded
Future<void> main() async {
  await runZonedGuarded(
    () async {
      // Ensure all bindings are initialized
      WidgetsFlutterBinding.ensureInitialized();

      // Load environment variables
      try {
        await dotenv.load(fileName: '.env');
        AppLogger.i('Environment variables loaded');
      } catch (e) {
        AppLogger.w('.env file not found, using defaults');
      }

      // Initialize core services in sequence
      await _initFirebase();
      await _initHiveBoxes();
      await _initEncryption();
      await _initNotifications();
      await _initBackgroundTasks();
      await _initAdService();

      // Initialize state management
      _initGetXProviders();

      AppLogger.i('Application initialization complete');

      // Launch the app
      runApp(const RozgarApp());
    },
    (error, stack) {
      AppLogger.e('Uncaught exception in main', stack);
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
  );
}
