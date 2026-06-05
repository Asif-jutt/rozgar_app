import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rozgar/admin/models/report_model.dart';
import 'package:rozgar/admin/providers/job_moderation_provider.dart';
import 'package:rozgar/admin/providers/user_management_provider.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

class ReportsProvider extends GetxController {
  static ReportsProvider get to => Get.find();

  RxList<ReportModel> reports = <ReportModel>[].obs;
  RxString typeFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.reports)
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .get();
    FirestoreReadCounter.increment(snap.docs.length);
    reports.assignAll(snap.docs.map(ReportModel.fromFirestore));
  }

  List<ReportModel> get filteredReports {
    if (typeFilter.value == 'all') return reports;
    return reports.where((r) => r.targetType == typeFilter.value).toList();
  }

  Future<void> dismissReport(String reportId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.reports)
        .doc(reportId)
        .update({'status': 'dismissed'});
    reports.removeWhere((r) => r.id == reportId);
  }

  Future<void> banFromReport(String reportId, String targetUid) async {
    await UserManagementProvider.to.banUser(targetUid, 'Reported by users');
    await dismissReport(reportId);
  }

  Future<void> removeJobFromReport(String reportId, String jobId) async {
    await JobModerationProvider.to.deleteJob(jobId);
    await dismissReport(reportId);
  }
}
