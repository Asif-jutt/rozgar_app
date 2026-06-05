import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:rozgar/user/constants/app_strings.dart';

class PermissionHelper {
  static Future<bool> requestStorage() async {
    if (kIsWeb) return true;

    permission_handler.PermissionStatus status =
        await permission_handler.Permission.storage.request();
    if (!status.isGranted) {
      status = await permission_handler.Permission.photos.request();
    }
    if (!status.isGranted) {
      Get.snackbar(
        'Permission needed',
        AppStrings.storageRationale,
        mainButton: TextButton(
          onPressed: permission_handler.openAppSettings,
          child: const Text('Settings'),
        ),
      );
    }
    return status.isGranted;
  }

  static Future<bool> requestCamera() async {
    if (kIsWeb) return true;

    final status = await permission_handler.Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission needed',
        AppStrings.cameraRationale,
        mainButton: TextButton(
          onPressed: permission_handler.openAppSettings,
          child: const Text('Settings'),
        ),
      );
    }
    return status.isGranted;
  }

  static Future<bool> requestNotification() async {
    if (kIsWeb) return true;

    final status = await permission_handler.Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> requestLocation() async {
    if (kIsWeb) return true;

    final status =
        await permission_handler.Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      Get.snackbar('Permission needed', AppStrings.locationRationale);
    }
    return status.isGranted;
  }
}
