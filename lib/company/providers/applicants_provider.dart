import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/models/applicant_model.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/notification_service.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/models/user_model.dart';

class ApplicantsProvider extends GetxController {
  static ApplicantsProvider get to => Get.find();

  RxList<ApplicantModel> applicants = <ApplicantModel>[].obs;
  RxString selectedJobId = ''.obs;
  RxString statusFilter = 'all'.obs;

  Future<void> loadApplicants(String jobId) async {
    selectedJobId.value = jobId;
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.applications)
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedAt', descending: true)
        .get();
    FirestoreReadCounter.increment(snap.docs.length);

    final list = <ApplicantModel>[];
    for (final doc in snap.docs) {
      final app = ApplicationModel.fromFirestore(doc);
      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(app.seekerId)
          .get();
      FirestoreReadCounter.increment();
      final user =
          userDoc.exists ? UserModel.fromFirestore(userDoc) : null;
      list.add(ApplicantModel.fromDocs(app, user));
    }
    applicants.assignAll(list);
  }

  Future<void> updateStatus(String applicationId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.applications)
        .doc(applicationId)
        .update({'status': newStatus});

    final idx = applicants.indexWhere((a) => a.applicationId == applicationId);
    if (idx >= 0) {
      final a = applicants[idx];
      applicants[idx] = ApplicantModel(
        applicationId: a.applicationId,
        status: newStatus,
        appliedAt: a.appliedAt,
        resumeUrl: a.resumeUrl,
        coverLetter: a.coverLetter,
        seekerUid: a.seekerUid,
        seekerName: a.seekerName,
        seekerEmail: a.seekerEmail,
        seekerPhotoUrl: a.seekerPhotoUrl,
        seekerSkills: a.seekerSkills,
        seekerExperience: a.seekerExperience,
      );

      final userDoc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(a.seekerUid)
          .get();
      final fcm = userDoc.data()?['fcmToken'] as String? ?? '';
      if (fcm.isNotEmpty) {
        String body;
        switch (newStatus) {
          case 'accepted':
            body = 'Congratulations! Your application was accepted';
          case 'rejected':
            body = 'Application update from employer';
          default:
            body = 'Your application was viewed';
        }
        await NotificationService.instance.sendNotificationToUser(
          targetFcmToken: fcm,
          title: 'Application Update',
          body: body,
          type: 'status_update',
          targetId: applicationId,
        );
      }
    }
    AppLogger.i('Status updated: $applicationId → $newStatus');
  }

  List<ApplicantModel> get filteredApplicants {
    if (statusFilter.value == 'all') return applicants;
    return applicants.where((a) => a.status == statusFilter.value).toList();
  }
}
