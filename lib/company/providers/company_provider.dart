import 'package:flutter/foundation.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/shared/services/firestore_service.dart';
class CompanyProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Stream<List<JobModel>> getCompanyJobs(String companyId) {
    return _firestoreService.companyJobsStream(companyId);
  }

  Stream<List<ApplicationModel>> getCompanyApplications(String companyId) {
    return _firestoreService.companyApplicationsStream(companyId);
  }

  Future<void> postJob(JobModel job) async {
    _setLoading(true);
    _setError(null);
    try {
      await _firestoreService.createJob(job);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteJob(String jobId) async {
     _setLoading(true);
    _setError(null);
    try {
      await _firestoreService.deleteJob(jobId);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
