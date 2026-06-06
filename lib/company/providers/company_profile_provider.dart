import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/models/company_model.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/cloudinary_provider.dart';
import 'package:rozgar/shared/providers/permission_helper.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class CompanyProfileProvider extends GetxController {
  static CompanyProfileProvider get to => Get.find();

  Rx<CompanyModel?> company = Rx<CompanyModel?>(null);
  RxDouble uploadProgress = 0.0.obs;
  RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCompanyProfile();
  }

  Future<void> loadCompanyProfile() async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.companies)
        .doc(uid)
        .get();
    FirestoreReadCounter.increment();
    if (doc.exists) company.value = CompanyModel.fromFirestore(doc);
  }

  Future<void> uploadLogo() async {
    final granted = await PermissionHelper.requestStorage();
    if (!granted) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final bytes = picked.bytes;
    if (bytes == null) return;

    isUploading.value = true;
    uploadProgress.value = 0;
    try {
      final oldId = company.value?.logoPublicId;
      final upload = await CloudinaryService.instance.uploadImageBytes(
        bytes,
        filename: picked.name,
        folder: 'rozgar/logos',
        onProgress: (p) => uploadProgress.value = p,
      );
      final uid = AuthProvider.to.currentUser.value!.uid;
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.companies)
          .doc(uid)
          .update({
        'logoUrl': upload['secureUrl'],
        'logoPublicId': upload['publicId'],
      });
      if (oldId != null) await CloudinaryService.instance.deleteFile(oldId);
      company.value = company.value?.copyWith(
        logoUrl: upload['secureUrl'],
        logoPublicId: upload['publicId'],
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updateCompanyProfile(Map<String, dynamic> updates) async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.companies)
        .doc(uid)
        .update(updates);
    await loadCompanyProfile();
    Get.snackbar('Saved', 'Company profile updated');
  }
}
