import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/user/models/user_model.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/models/application_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER OPERATIONS ====================

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Stream of user profile updates
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
            ...profile.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // Update specific user fields
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...fields,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ==================== JOB OPERATIONS ====================

  // Get all jobs
  Future<List<Job>> getAllJobs() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('jobs').orderBy('postedDate', descending: true).get();
      return snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Stream of all jobs
  Stream<List<Job>> getAllJobsStream() {
    return _firestore
        .collection('jobs')
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get jobs by location
  Future<List<Job>> getJobsByLocation(String location) async {
    try {
      if (location == 'All') {
        return getAllJobs();
      }
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('location', isEqualTo: location)
          .orderBy('postedDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get job by ID
  Future<Job?> getJobById(String jobId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return Job.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create job (Company)
  Future<String> createJob(Job job) async {
    try {
      DocumentReference docRef = await _firestore.collection('jobs').add({
        ...job.toJson(),
        'id': '', // Will be set by Firestore
      });
      
      // Update the document with its own ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update job (Company)
  Future<void> updateJob(String jobId, Job job) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update(job.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Delete job (Company)
  Future<void> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get company jobs
  Future<List<Job>> getCompanyJobs(String companyId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .orderBy('postedDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== APPLICATION OPERATIONS ====================

  // Create application
  Future<String> createApplication(JobApplication application) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('applications').add({
            ...application.toJson(),
            'id': '', // Will be set by Firestore
          });
      
      // Update the document with its own ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get user applications
  Future<List<JobApplication>> getUserApplications(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .orderBy('appliedDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              JobApplication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Stream of user applications
  Stream<List<JobApplication>> getUserApplicationsStream(String userId) {
    return _firestore
        .collection('applications')
        .where('userId', isEqualTo: userId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              JobApplication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get job applications (Company)
  Future<List<JobApplication>> getJobApplications(String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .orderBy('appliedDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) =>
              JobApplication.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update application status
  Future<void> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Check if user already applied for job
  Future<bool> hasUserApplied(String userId, String jobId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('applications')
          .where('userId', isEqualTo: userId)
          .where('jobId', isEqualTo: jobId)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== COMPANY OPERATIONS ====================

  // Get company profile
  Future<Map<String, dynamic>?> getCompanyProfile(String companyId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(companyId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Update company profile
  Future<void> updateCompanyProfile(
      String companyId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(companyId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ==================== SEARCH & FILTER ====================

  // Search jobs by skill
  Future<List<Job>> searchJobsBySkill(String skill) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('jobs')
          .where('requiredSkills', arrayContains: skill)
          .orderBy('postedDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Job.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ANALYTICS ====================

  // Get dashboard stats
  Future<Map<String, int>> getDashboardStats(String companyId) async {
    try {
      final jobsSnap = await _firestore
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .get();
      final applicationsSnap = await _firestore
          .collection('applications')
          .where('companyId', isEqualTo: companyId)
          .get();

      return {
        'jobs': jobsSnap.size,
        'applications': applicationsSnap.size,
      };
    } catch (e) {
      rethrow;
    }
  }
}
