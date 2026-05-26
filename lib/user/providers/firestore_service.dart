import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/user/models/app_user.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/models/user_profile_model.dart';

import 'package:rozgar/user/providers/notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USERS ───────────────────────────────────────────────────────────────

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
  }

  Stream<AppUser?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!);
    });
  }

  Future<List<AppUser>> getAllUsers() async {
    final snap = await _db.collection('users').get();
    return snap.docs.map((d) => AppUser.fromMap(d.data())).toList();
  }

  Future<void> updateUserProfileImage(String uid, String url) async {
    await _db.collection('users').doc(uid).update({'profileImageUrl': url});
  }

  Future<void> deleteUserDoc(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // ─── USER PROFILES ─────────────────────────────────────────────────────────

  Future<void> saveUserProfile(UserProfileModel profile) async {
    await _db
        .collection('user_profiles')
        .doc(profile.userId)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserProfileModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('user_profiles').doc(userId).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromMap(userId, doc.data()!);
  }

  Stream<UserProfileModel?> userProfileStream(String userId) {
    return _db.collection('user_profiles').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromMap(userId, doc.data()!);
    });
  }

  // ─── JOBS ──────────────────────────────────────────────────────────────────

  Future<String> createJob(JobModel job) async {
    final ref = await _db.collection('jobs').add(job.toMap());
    return ref.id;
  }

  Future<JobModel?> getJob(String jobId) async {
    final doc = await _db.collection('jobs').doc(jobId).get();
    if (!doc.exists) return null;
    return JobModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    await _db.collection('jobs').doc(jobId).update(data);
  }

  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobs').doc(jobId).delete();
  }

  /// Stream: all jobs (newest first).
  Stream<List<JobModel>> jobsStream() {
    return _db
        .collection('jobs')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => JobModel.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<JobModel>> companyJobsStream(String companyId) {
    return _db
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => JobModel.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<List<JobModel>> getAllJobs() async {
    final snap = await _db
        .collection('jobs')
        .orderBy('postedAt', descending: true)
        .get();
    return snap.docs.map((d) => JobModel.fromMap(d.id, d.data())).toList();
  }

  // ─── APPLICATIONS ─────────────────────────────────────────────────────────

  Future<String> createApplication(ApplicationModel application) async {
    final ref = await _db.collection('applications').add(application.toMap());
    return ref.id;
  }

  Future<bool> hasUserApplied({
    required String userId,
    required String jobId,
  }) async {
    final snap = await _db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .where('jobId', isEqualTo: jobId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> updateApplicationStatus(String appId, String status) async {
    await _db.collection('applications').doc(appId).update({'status': status});
  }

  /// Stream: applications for a specific user (seeker).
  Stream<List<ApplicationModel>> userApplicationsStream(String userId) {
    return _db
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ApplicationModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Stream: applicants for a specific job (company view).
  Stream<List<ApplicationModel>> jobApplicantsStream(String jobId) {
    return _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ApplicationModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<ApplicationModel>> companyApplicationsStream(String companyId) {
    return _db
        .collection('applications')
        .where('companyId', isEqualTo: companyId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ApplicationModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  // applications by job id
  Stream<List<ApplicationModel>> jobApplicationsStream(String jobId) {
    return _db
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snap) {
          final apps = snap.docs
              .map((d) => ApplicationModel.fromMap(d.id, d.data()))
              .toList();
          apps.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
          return apps;
        });
  }

  Future<List<ApplicationModel>> getApplicationsByCompany(
    String companyId,
  ) async {
    final snap = await _db
        .collection('applications')
        .where('companyId', isEqualTo: companyId)
        .orderBy('appliedDate', descending: true)
        .get();
    return snap.docs
        .map((d) => ApplicationModel.fromMap(d.id, d.data()))
        .toList();
  }

  // ─── NOTIFICATIONS (in-app, Firestore only) ────────────────────────────────

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? relatedId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'read': false,
      'relatedId': relatedId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ─── ADMIN STATS ───────────────────────────────────────────────────────────

  Future<Map<String, int>> getPlatformStats() async {
    final users = await _db.collection('users').get();
    final jobs = await _db.collection('jobs').get();
    final apps = await _db.collection('applications').get();

    int seekers = 0, companies = 0, admins = 0;
    for (final doc in users.docs) {
      final role = doc.data()['userRole'] ?? 'seeker';
      if (role == 'company') {
        companies++;
      } else if (role == 'admin') {
        admins++;
      } else {
        seekers++;
      }
    }

    return {
      'seekers': seekers,
      'companies': companies,
      'admins': admins,
      'jobs': jobs.docs.length,
      'applications': apps.docs.length,
    };
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  Future<ApplicationModel> applyToJob({
    required String jobId,
    required String userId,
    required String companyId,
    required String jobTitle,
    required String applicantName,
    required String resumeText,
    String? university,
    String? semester,
    String? email,
    String? phone,
  }) async {
    final app = ApplicationModel(
      appId: '',
      jobId: jobId,
      userId: userId,
      companyId: companyId,
      status: 'Pending',
      appliedDate: DateTime.now(),
      resumeText: resumeText,
      applicantName: applicantName,
      jobTitle: jobTitle,
      university: university,
      semester: semester,
      email: email,
      phone: phone,
    );
    final id = await createApplication(app);

    // Notify the company that a user has applied
    await NotificationService().sendNotification(
      userId: companyId,
      title: 'New Job Application',
      body: '$applicantName has applied to "$jobTitle".',
      type: 'application',
      relatedId: id,
    );

    return ApplicationModel(
      appId: id,
      jobId: jobId,
      userId: userId,
      companyId: companyId,
      status: 'Pending',
      appliedDate: app.appliedDate,
      resumeText: resumeText,
      applicantName: applicantName,
      jobTitle: jobTitle,
      university: university,
      semester: semester,
      email: email,
      phone: phone,
    );
  }

  String defaultJobImage(String category) =>
      AppImages.jobImageForCategory(category);
}
