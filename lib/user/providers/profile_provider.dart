import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/cloudinary_provider.dart';
import 'package:rozgar/shared/providers/permission_helper.dart';
import 'package:rozgar/user/models/user_model.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class ProfileProvider extends GetxController {
  static ProfileProvider get to => Get.find();

  Rx<UserModel?> profile = Rx<UserModel?>(null);
  RxDouble uploadProgress = 0.0.obs;
  RxBool isUploading = false.obs;
  RxBool isPdfLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .get();
    FirestoreReadCounter.increment();
    if (doc.exists) {
      profile.value = UserModel.fromFirestore(doc);
      AuthProvider.to.currentUser.value = profile.value;
    }
  }

  Future<void> uploadResume() async {
    final granted = await PermissionHelper.requestStorage();
    if (!granted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final trace = FirebasePerformance.instance.newTrace('resume_upload');
    await trace.start();
    isUploading.value = true;
    uploadProgress.value = 0;

    try {
      final oldPublicId = profile.value?.resumePublicId;
      final upload = await CloudinaryService.instance.uploadResumeSync(
        file,
        onProgress: (p) => uploadProgress.value = p,
      );
      final uid = AuthProvider.to.currentUser.value!.uid;
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({
            'resumeUrl': upload['secureUrl'],
            'resumePublicId': upload['publicId'],
          });
      if (oldPublicId != null) {
        await CloudinaryService.instance.deleteFile(oldPublicId);
      }
      profile.value = profile.value?.copyWith(
        resumeUrl: upload['secureUrl'],
        resumePublicId: upload['publicId'],
      );
      AuthProvider.to.currentUser.value = profile.value;
      AppLogger.i('Resume uploaded: ${upload['publicId']}');
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString());
      AppLogger.e(e);
    } finally {
      isUploading.value = false;
      await trace.stop();
    }
  }

  Future<void> uploadProfileImage(ImageSource source) async {
    final granted = source == ImageSource.camera
        ? await PermissionHelper.requestCamera()
        : await PermissionHelper.requestStorage();
    if (!granted) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image == null) return;

    isUploading.value = true;
    uploadProgress.value = 0;
    try {
      final upload = await CloudinaryService.instance.uploadImage(
        File(image.path),
        folder: 'rozgar/avatars',
        onProgress: (p) => uploadProgress.value = p,
      );
      final uid = AuthProvider.to.currentUser.value!.uid;
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .update({'photoUrl': upload['secureUrl']});
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(
        upload['secureUrl'],
      );
      profile.value = profile.value?.copyWith(photoUrl: upload['secureUrl']);
      AuthProvider.to.currentUser.value = profile.value;
    } catch (e) {
      Get.snackbar('Upload Failed', e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final encrypted = Map<String, dynamic>.from(updates);
    if (encrypted.containsKey('phone')) {
      encrypted['phoneEncrypted'] = EncryptionHelper.encryptString(
        encrypted.remove('phone') as String,
      );
    }
    if (encrypted.containsKey('cnic')) {
      encrypted['cnicEncrypted'] = EncryptionHelper.encryptString(
        encrypted.remove('cnic') as String,
      );
    }
    if (encrypted.containsKey('salaryExpectation')) {
      encrypted['salaryExpectationEncrypted'] = EncryptionHelper.encryptString(
        encrypted.remove('salaryExpectation') as String,
      );
    }
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.users)
        .doc(uid)
        .update(encrypted);
    await loadProfile();
    Get.snackbar('Saved', 'Profile updated successfully');
  }

  Future<void> purchasePremium() async {
    const productId = 'rozgar_premium_monthly';
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      Get.snackbar('Error', 'In-app purchases not available');
      return;
    }
    final response = await InAppPurchase.instance.queryProductDetails({
      productId,
    });
    if (response.productDetails.isEmpty) {
      Get.snackbar('Error', 'Premium product not found');
      return;
    }
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: response.productDetails.first,
      ),
    );
    InAppPurchase.instance.purchaseStream.listen((purchases) async {
      for (final p in purchases) {
        if (p.status == PurchaseStatus.purchased) {
          final uid = AuthProvider.to.currentUser.value?.uid;
          if (uid != null) {
            await FirebaseFirestore.instance
                .collection(FirebaseCollections.users)
                .doc(uid)
                .update({'isPremium': true});
            await loadProfile();
          }
        }
      }
    });
  }
}
