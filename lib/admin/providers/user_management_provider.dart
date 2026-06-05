import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/models/user_model.dart';

class UserManagementProvider extends GetxController {
  static UserManagementProvider get to => Get.find();

  RxList<UserModel> users = <UserModel>[].obs;
  RxString searchQuery = ''.obs;
  RxString roleFilter = 'all'.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    isLoading.value = true;
    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .orderBy('createdAt', descending: true)
          .get();
      FirestoreReadCounter.increment(snap.docs.length);
      users.assignAll(snap.docs.map(UserModel.fromFirestore));
      AppLogger.i('Users loaded: ${users.length}');
    } finally {
      isLoading.value = false;
    }
  }

  List<UserModel> get filteredUsers {
    var list = users.toList();
    if (roleFilter.value != 'all') {
      if (roleFilter.value == 'banned') {
        list = list.where((u) => !u.isActive).toList();
      } else {
        list = list.where((u) => u.role == roleFilter.value).toList();
      }
    }
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((u) =>
              (u.displayName ?? '').toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> banUser(String uid, String reason) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .update({'isActive': false, 'banReason': reason});
    await loadAllUsers();
    AppLogger.w('User banned: $uid');
    Get.snackbar('User Banned', 'User has been banned');
  }

  Future<void> unbanUser(String uid) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .update({'isActive': true, 'banReason': FieldValue.delete()});
    await loadAllUsers();
    AppLogger.i('User unbanned: $uid');
  }
}
