import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:rozgar/shared/constants/firebase_constants.dart';

/// Service for managing device permissions with graceful error handling.
class PermissionService {
  static permission_handler.PermissionStatus _webGranted() =>
      permission_handler.PermissionStatus.granted;

  static Future<permission_handler.PermissionStatus> requestCameraPermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status = await permission_handler.Permission.camera.request();
      _logPermissionStatus('Camera', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting camera permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<permission_handler.PermissionStatus>
      requestMicrophonePermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status = await permission_handler.Permission.microphone.request();
      _logPermissionStatus('Microphone', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting microphone permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<permission_handler.PermissionStatus>
      requestStoragePermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status = await permission_handler.Permission.storage.request();
      _logPermissionStatus('Storage', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting storage permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<permission_handler.PermissionStatus>
      requestLocationPermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status = await permission_handler.Permission.location.request();
      _logPermissionStatus('Location', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting location permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<permission_handler.PermissionStatus>
      requestLocationWhenInUsePermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status =
          await permission_handler.Permission.locationWhenInUse.request();
      _logPermissionStatus('Location (When In Use)', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting location when in use permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<permission_handler.PermissionStatus>
      requestContactsPermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status = await permission_handler.Permission.contacts.request();
      _logPermissionStatus('Contacts', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting contacts permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<permission_handler.PermissionStatus>
      requestCalendarPermission() async {
    if (kIsWeb) return _webGranted();
    try {
      final status = await permission_handler.Permission.calendar.request();
      _logPermissionStatus('Calendar', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting calendar permission', st);
      return permission_handler.PermissionStatus.denied;
    }
  }

  static Future<bool> isCameraPermissionGranted() async {
    if (kIsWeb) return true;
    try {
      final status = await permission_handler.Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isMicrophonePermissionGranted() async {
    if (kIsWeb) return true;
    try {
      final status = await permission_handler.Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isStoragePermissionGranted() async {
    if (kIsWeb) return true;
    try {
      final status = await permission_handler.Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isLocationPermissionGranted() async {
    if (kIsWeb) return true;
    try {
      final status = await permission_handler.Permission.location.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isContactsPermissionGranted() async {
    if (kIsWeb) return true;
    try {
      final status = await permission_handler.Permission.contacts.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<permission_handler.Permission,
      permission_handler.PermissionStatus>> requestMultiplePermissions(
    List<permission_handler.Permission> permissions,
  ) async {
    if (kIsWeb) {
      return {
        for (final p in permissions) p: _webGranted(),
      };
    }
    try {
      final statuses = await permissions.request();
      statuses.forEach((permission, status) {
        _logPermissionStatus(permission.toString().split('.').last, status);
      });
      return statuses;
    } catch (e, st) {
      AppLogger.e('Error requesting multiple permissions', st);
      return {};
    }
  }

  static Future<void> openAppSettings() async {
    if (kIsWeb) return;
    try {
      await permission_handler.openAppSettings();
      AppLogger.i('Opened app settings');
    } catch (e, st) {
      AppLogger.e('Error opening app settings', st);
    }
  }

  static Future<bool> isPermissionPermanentlyDenied(
    permission_handler.Permission permission,
  ) async {
    if (kIsWeb) return false;
    try {
      final status = await permission.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      return false;
    }
  }

  static String getStatusDescription(
    permission_handler.PermissionStatus status,
  ) {
    switch (status) {
      case permission_handler.PermissionStatus.granted:
        return 'Permission granted';
      case permission_handler.PermissionStatus.denied:
        return 'Permission denied';
      case permission_handler.PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied - please enable in settings';
      case permission_handler.PermissionStatus.restricted:
        return 'Permission restricted';
      case permission_handler.PermissionStatus.limited:
        return 'Permission limited';
      case permission_handler.PermissionStatus.provisional:
        return 'Permission provisional';
    }
  }

  static void _logPermissionStatus(
    String name,
    permission_handler.PermissionStatus status,
  ) {
    final statusStr = status.toString().split('.').last;
    AppLogger.i('Permission: $name → $statusStr');
  }
}
