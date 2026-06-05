import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/models/job_model.dart';

class JobModerationProvider extends GetxController {
  static JobModerationProvider get to => Get.find();

  RxList<JobModel> pendingJobs = <JobModel>[].obs;
  RxList<JobModel> approvedJobs = <JobModel>[].obs;
  RxList<JobModel> rejectedJobs = <JobModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllJobs();
  }

  Future<void> loadAllJobs() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _queryByStatus('pending'),
        _queryByStatus('approved'),
        _queryByStatus('rejected'),
      ]);
      pendingJobs.assignAll(results[0]);
      approvedJobs.assignAll(results[1]);
      rejectedJobs.assignAll(results[2]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<JobModel>> _queryByStatus(String status) async {
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.jobs)
        .where('status', isEqualTo: status)
        .get();
    FirestoreReadCounter.increment(snap.docs.length);
    return snap.docs.map(JobModel.fromFirestore).toList();
  }

  Future<void> approveJob(String jobId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.jobs)
        .doc(jobId)
        .update({'status': 'approved', 'approvedAt': FieldValue.serverTimestamp()});
    final job = pendingJobs.firstWhereOrNull((j) => j.id == jobId);
    if (job != null) {
      pendingJobs.remove(job);
      approvedJobs.insert(0, JobModel(
        id: job.id,
        title: job.title,
        companyName: job.companyName,
        location: job.location,
        employerId: job.employerId,
        status: 'approved',
      ));
    }
    AppLogger.i('Job approved: $jobId');
  }

  Future<void> rejectJob(String jobId, String reason) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.jobs)
        .doc(jobId)
        .update({'status': 'rejected', 'rejectionReason': reason});
    pendingJobs.removeWhere((j) => j.id == jobId);
    AppLogger.w('Job rejected: $jobId — $reason');
  }

  Future<void> deleteJob(String jobId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.jobs)
        .doc(jobId)
        .delete();
    pendingJobs.removeWhere((j) => j.id == jobId);
    approvedJobs.removeWhere((j) => j.id == jobId);
    rejectedJobs.removeWhere((j) => j.id == jobId);
    AppLogger.w('Job deleted: $jobId');
  }
}
