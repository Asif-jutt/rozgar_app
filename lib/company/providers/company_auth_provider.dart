import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:get/get.dart';
import 'package:rozgar/company/models/company_model.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class CompanyAuthProvider extends GetxController {
  static CompanyAuthProvider get to => Get.find();

  Rx<CompanyModel?> company = Rx<CompanyModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCompany();
  }

  Future<void> loadCompany() async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.companies)
        .doc(uid)
        .get();
    FirestoreReadCounter.increment();
    if (doc.exists) company.value = CompanyModel.fromFirestore(doc);
  }

  Future<void> createCompanyOnSignup(String name) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final c = CompanyModel(id: uid, name: name, employerId: uid);
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.companies)
        .doc(uid)
        .set(c.toFirestore());
    company.value = c;
    AppLogger.currentRole = 'employer';
    AppLogger.i('Company created: $uid');
  }

  void ensureEmployerRole() {
    final user = AuthProvider.to.currentUser.value;
    if (user?.role != 'employer') {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
