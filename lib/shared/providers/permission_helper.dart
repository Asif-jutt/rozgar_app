import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rozgar/user/constants/app_strings.dart';

class PermissionHelper {
  static Future<bool> requestStorage() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    if (!status.isGranted) {
      Get.snackbar(
        'Permission needed',
        AppStrings.storageRationale,
        mainButton: TextButton(
          onPressed: openAppSettings,
          child: const Text('Settings'),
        ),
      );
    }
    return status.isGranted;
  }

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Get.snackbar(
        'Permission needed',
        AppStrings.cameraRationale,
        mainButton: TextButton(
          onPressed: openAppSettings,
          child: const Text('Settings'),
        ),
      );
    }
    return status.isGranted;
  }

  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      Get.snackbar('Permission needed', AppStrings.locationRationale);
    }
    return status.isGranted;
  }
}
