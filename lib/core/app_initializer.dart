import 'package:flutter/foundation.dart';
import 'package:rozgar/core/encryption/encryption_service.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/services/ad_service.dart';
import 'package:rozgar/services/background_task_service.dart';
import 'package:rozgar/services/notification_service.dart';
import 'package:rozgar/services/permission_service.dart';

/// Bootstraps cross-cutting services in a defined order.
class AppInitializer {
  AppInitializer._();
  static final AppInitializer instance = AppInitializer._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    AppLogger.info('AppInitializer starting...');

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.error('FlutterError', details.exception, details.stack);
    };

    await EncryptionService.instance.initialize();
    await PermissionService.instance.requestEssentialPermissions();

    if (!kIsWeb) {
      try {
        await NotificationService().initialize();
      } catch (e, st) {
        AppLogger.error('Notification init skipped', e, st);
      }
      try {
        await AdService.instance.initialize();
      } catch (e, st) {
        AppLogger.error('Ad init skipped', e, st);
      }
      try {
        await BackgroundTaskService.instance.initialize();
      } catch (e, st) {
        AppLogger.error('Background task init skipped', e, st);
      }
    }

    _initialized = true;
    AppLogger.info('AppInitializer complete');
  }
}
