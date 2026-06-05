import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends GetxController {
  static ThemeProvider get to => Get.find();

  RxBool isDarkMode = false.obs;
  static const _boxName = 'settings';
  static const _key = 'is_dark_mode';

  @override
  void onInit() {
    super.onInit();
    final box = Hive.box(_boxName);
    isDarkMode.value = box.get(_key, defaultValue: false) as bool;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Hive.box(_boxName).put(_key, isDarkMode.value);
  }
}
