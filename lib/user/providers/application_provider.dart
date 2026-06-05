import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/ad_service.dart';
import 'package:rozgar/shared/providers/connectivity_provider.dart';
import 'package:rozgar/shared/providers/notification_service.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class ApplicationProvider extends GetxController {
  static ApplicationProvider get to => Get.find();

  RxList<ApplicationModel> myApplications = <ApplicationModel>[].obs;
  RxBool isSubmitting = false.obs;
  RxInt applicationCount = 0.obs;

  static const _pendingBox = 'pending_applications';

  @override
  void onInit() {
    super.onInit();
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid != null) loadMyApplications();
  }

  Future<void> submitApplication({
    required String jobId,
    required String jobTitle,
    required String companyName,
    required String resumeUrl,
    String coverLetter = '',
    String employerFcmToken = '',
  }) async {
    final trace = FirebasePerformance.instance.newTrace('apply_for_job');
    await trace.start();

    if (ConnectivityProvider.to.isOffline.value) {
      final user = AuthProvider.to.currentUser.value!;
      final app = ApplicationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        seekerId: user.uid,
        seekerName: user.displayName ?? user.email,
        seekerPhotoUrl: user.photoUrl,
        resumeUrl: resumeUrl,
        coverLetter: coverLetter,
      );
      final box = Hive.box(_pendingBox);
      final pending =
          (box.get('queue') as List?)?.cast<Map>() ?? <Map>[];
      pending.add(app.toHive());
      box.put('queue', pending);
      Get.snackbar('Queued', AppStrings.queuedApplication);
      await trace.stop();
      return;
    }

    isSubmitting.value = true;
    try {
      final user = AuthProvider.to.currentUser.value!;
      final ref =
          FirebaseFirestore.instance.collection(FirebaseCollections.applications).doc();
      final app = ApplicationModel(
        id: ref.id,
        jobId: jobId,
        jobTitle: jobTitle,
        companyName: companyName,
        seekerId: user.uid,
        seekerName: user.displayName ?? user.email,
        seekerPhotoUrl: user.photoUrl,
        status: 'pending',
        appliedAt: Timestamp.now(),
        resumeUrl: resumeUrl,
        coverLetter: coverLetter,
      );
      await ref.set(app.toFirestore());
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.jobs)
          .doc(jobId)
          .update({'applicationCount': FieldValue.increment(1)});
      myApplications.insert(0, app);

      if (employerFcmToken.isNotEmpty) {
        await NotificationService.instance.sendNotificationToUser(
          targetFcmToken: employerFcmToken,
          title: 'New Application',
          body: '${user.displayName} applied for $jobTitle',
          type: 'application',
          targetId: ref.id,
        );
      }

      applicationCount.value++;
      if (applicationCount.value % 5 == 0 && !user.isPremium) {
        AdService.instance.showInterstitialAd();
      }
      AppLogger.i('Applied for job: $jobId');
    } catch (e) {
      AppLogger.e(e);
      Get.snackbar('Error', e.toString());
    } finally {
      isSubmitting.value = false;
      await trace.stop();
    }
  }

  Future<void> loadMyApplications() async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.applications)
        .where('seekerId', isEqualTo: uid)
        .orderBy('appliedAt', descending: true)
        .get();
    FirestoreReadCounter.increment(snap.docs.length);
    myApplications.assignAll(snap.docs.map(ApplicationModel.fromFirestore));
  }

  Future<void> syncPendingApplications() async {
    final box = Hive.box(_pendingBox);
    final pending = (box.get('queue') as List?)?.cast<Map>() ?? [];
    if (pending.isEmpty) return;
    for (final map in List<Map>.from(pending)) {
      final app = ApplicationModel.fromHive(Map<String, dynamic>.from(map));
      await submitApplication(
        jobId: app.jobId,
        jobTitle: app.jobTitle,
        companyName: app.companyName,
        resumeUrl: app.resumeUrl ?? '',
        coverLetter: app.coverLetter ?? '',
      );
    }
    box.delete('queue');
  }

  bool hasApplied(String jobId) =>
      myApplications.any((a) => a.jobId == jobId);
}
