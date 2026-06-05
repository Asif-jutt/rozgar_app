import 'package:get/get.dart';
import 'package:rozgar/admin/constants/admin_strings.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class AdminAuthProvider extends GetxController {
  static AdminAuthProvider get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    ever(AuthProvider.to.currentUser, _checkAdmin);
    _checkAdmin(AuthProvider.to.currentUser.value);
  }

  void _checkAdmin(user) {
    if (user == null) return;
    if (user.role != 'admin') {
      AuthProvider.to.signOut();
      Get.snackbar('Access Denied', AdminStrings.accessDenied);
      Get.offAllNamed(AppRoutes.login);
    } else {
      AppLogger.currentRole = 'admin';
    }
  }
}
