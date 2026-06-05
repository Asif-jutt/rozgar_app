import 'package:permission_handler/permission_handler.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

/// Service for managing device permissions with graceful error handling
/// Handles runtime permissions for camera, microphone, storage, location, etc.
class PermissionService {
  /// Requests camera permission
  /// Returns the permission status
  static Future<PermissionStatus> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      _logPermissionStatus('Camera', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting camera permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Requests microphone permission
  /// Returns the permission status
  static Future<PermissionStatus> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      _logPermissionStatus('Microphone', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting microphone permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Requests storage permission
  /// Returns the permission status
  static Future<PermissionStatus> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      _logPermissionStatus('Storage', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting storage permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Requests location permission
  /// Returns the permission status
  static Future<PermissionStatus> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      _logPermissionStatus('Location', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting location permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Requests location permission (always/when in use)
  /// Returns the permission status
  static Future<PermissionStatus> requestLocationWhenInUsePermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      _logPermissionStatus('Location (When In Use)', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting location when in use permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Requests contacts permission
  /// Returns the permission status
  static Future<PermissionStatus> requestContactsPermission() async {
    try {
      final status = await Permission.contacts.request();
      _logPermissionStatus('Contacts', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting contacts permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Requests calendar permission
  /// Returns the permission status
  static Future<PermissionStatus> requestCalendarPermission() async {
    try {
      final status = await Permission.calendar.request();
      _logPermissionStatus('Calendar', status);
      return status;
    } catch (e, st) {
      AppLogger.e('Error requesting calendar permission', st);
      return PermissionStatus.denied;
    }
  }

  /// Checks if camera permission is granted
  static Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Checks if microphone permission is granted
  static Future<bool> isMicrophonePermissionGranted() async {
    try {
      final status = await Permission.microphone.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Checks if storage permission is granted
  static Future<bool> isStoragePermissionGranted() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Checks if location permission is granted
  static Future<bool> isLocationPermissionGranted() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Checks if contacts permission is granted
  static Future<bool> isContactsPermissionGranted() async {
    try {
      final status = await Permission.contacts.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Requests multiple permissions at once
  /// [permissions]: List of permissions to request
  /// Returns a map of permission to its status
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
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

  /// Opens app settings to allow user to grant denied permissions
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      AppLogger.i('Opened app settings');
    } catch (e, st) {
      AppLogger.e('Error opening app settings', st);
    }
  }

  /// Checks if permission is permanently denied
  /// User must go to settings to enable
  static Future<bool> isPermissionPermanentlyDenied(
    Permission permission,
  ) async {
    try {
      final status = await permission.status;
      return status.isDenied;
    } catch (e) {
      return false;
    }
  }

  /// Gets human-readable status description
  static String getStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied - please enable in settings';
      case PermissionStatus.restricted:
        return 'Permission restricted';
      case PermissionStatus.limited:
        return 'Permission limited';
    }
  }

  /// Logs permission request result
  static void _logPermissionStatus(String name, PermissionStatus status) {
    final statusStr = status.toString().split('.').last;
    AppLogger.i('Permission: $name → $statusStr');
  }
}
