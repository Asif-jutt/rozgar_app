import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/constants/company_strings.dart';
import 'package:rozgar/company/models/posted_job_model.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class PostJobProvider extends GetxController {
  static PostJobProvider get to => Get.find();

  RxBool isPosting = false.obs;
  RxList<String> requirements = <String>[].obs;
  RxList<String> countries = <String>[].obs;
  RxMap<String, double> exchangeRates = <String, double>{}.obs;
  RxList<PostedJobModel> myJobs = <PostedJobModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCountries();
    loadExchangeRates();
    loadMyJobs();
  }

  Future<void> loadCountries() async {
    try {
      final dio = DioClient.countries().dio;
      final res = await dio.get('https://restcountries.com/v3.1/region/asia');
      final list = res.data as List;
      countries.assignAll(
        list
            .map((e) => e['name']['common'] as String)
            .cast<String>()
            .toList()
          ..sort(),
      );
    } catch (e) {
      AppLogger.w('Countries load failed: $e');
      countries.assignAll(['Pakistan', 'India', 'Bangladesh', 'UAE']);
    }
  }

  Future<void> loadExchangeRates() async {
    try {
      final dio = DioClient.exchange().dio;
      final res = await dio.get('https://api.exchangerate-api.com/v4/latest/USD');
      final rates = res.data['rates'] as Map<String, dynamic>;
      exchangeRates['USD'] = 1;
      exchangeRates['PKR'] = (rates['PKR'] as num).toDouble();
    } catch (e) {
      exchangeRates['PKR'] = 278;
    }
  }

  Future<void> loadMyJobs() async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.jobs)
        .where('employerId', isEqualTo: uid)
        .orderBy('postedAt', descending: true)
        .get();
    FirestoreReadCounter.increment(snap.docs.length);
    myJobs.assignAll(snap.docs.map(PostedJobModel.fromFirestore));
  }

  Future<void> postJob(Map<String, dynamic> form) async {
    isPosting.value = true;
    try {
      final uid = AuthProvider.to.currentUser.value!.uid;
      final ref = FirebaseFirestore.instance.collection(FirebaseCollections.jobs).doc();
      final job = JobModel(
        id: ref.id,
        title: form['title'] as String,
        companyName: form['companyName'] as String? ??
            AuthProvider.to.currentUser.value!.displayName ??
            'Company',
        location: form['location'] as String,
        country: form['country'] as String? ?? 'Pakistan',
        salaryMin: (form['salaryMin'] as num?)?.toDouble() ?? 0,
        salaryMax: (form['salaryMax'] as num?)?.toDouble() ?? 0,
        currency: form['currency'] as String? ?? 'PKR',
        description: form['description'] as String,
        requirements: requirements.toList(),
        type: form['type'] as String? ?? 'fullTime',
        status: 'pending',
        employerId: uid,
        deadline: form['deadline'] as Timestamp?,
      );
      await ref.set(job.toFirestore());
      await loadMyJobs();
      Get.back();
      Get.snackbar('Submitted', CompanyStrings.jobSubmitted);
      AppLogger.i('Job posted: ${ref.id}');
    } finally {
      isPosting.value = false;
    }
  }

  void addRequirement(String req) {
    if (req.trim().isNotEmpty) requirements.add(req.trim());
  }

  void removeRequirement(int index) => requirements.removeAt(index);

  String convertSalary(double amount, String from, String to) {
    final fromRate = exchangeRates[from] ?? 1;
    final toRate = exchangeRates[to] ?? 1;
    final usd = amount / fromRate;
    return '${(usd * toRate).toStringAsFixed(0)} $to';
  }

  Future<void> deleteJob(String jobId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseCollections.jobs)
        .doc(jobId)
        .delete();
    myJobs.removeWhere((j) => j.id == jobId);
  }
}
