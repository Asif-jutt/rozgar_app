import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rozgar/core/logger/app_logger.dart';

/// Runtime permission handling for notifications, storage, and camera.
class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.notification.request();
      AppLogger.info('Notification permission: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.warning('Notification permission request failed', e);
      return false;
    }
  }

  Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final photos = await Permission.photos.request();
        if (photos.isGranted) return true;
        final storage = await Permission.storage.request();
        AppLogger.info('Storage permission: $storage');
        return storage.isGranted || photos.isGranted;
      }
      return true;
    } catch (e) {
      AppLogger.warning('Storage permission request failed', e);
      return false;
    }
  }

  Future<bool> requestCameraPermission() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.camera.request();
      AppLogger.info('Camera permission: $status');
      return status.isGranted;
    } catch (e) {
      AppLogger.warning('Camera permission request failed', e);
      return false;
    }
  }

  Future<Map<Permission, PermissionStatus>> requestEssentialPermissions() async {
    if (kIsWeb) return {};
    try {
      return await [
        Permission.notification,
        Permission.storage,
        Permission.photos,
      ].request();
    } catch (e) {
      AppLogger.warning('Essential permissions request failed', e);
      return {};
    }
  }
}
