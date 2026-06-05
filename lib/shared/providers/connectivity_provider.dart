import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/providers/application_provider.dart';

class ConnectivityProvider extends GetxController {
  static ConnectivityProvider get to => Get.find();

  RxBool isOffline = false.obs;
  StreamSubscription<ConnectivityResult>? _sub;

  @override
  void onInit() {
    super.onInit();
    _check();
    _sub = Connectivity().onConnectivityChanged.listen((_) => _check());
  }

  Future<void> _check() async {
    final result = await Connectivity().checkConnectivity();
    final offline = result == ConnectivityResult.none;
    final wasOffline = isOffline.value;
    isOffline.value = offline;
    AppLogger.i('Connectivity: ${offline ? 'offline' : 'online'}');
    if (wasOffline && !offline && Get.isRegistered<ApplicationProvider>()) {
      ApplicationProvider.to.syncPendingApplications();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
