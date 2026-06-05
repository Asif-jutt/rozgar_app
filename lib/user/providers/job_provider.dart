import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:workmanager/workmanager.dart';

class JobProvider extends GetxController {
  static JobProvider get to => Get.find();

  RxList<JobModel> jobs = <JobModel>[].obs;
  RxList<JobModel> filteredJobs = <JobModel>[].obs;
  RxList<JobModel> savedJobs = <JobModel>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString searchQuery = ''.obs;
  RxMap<String, dynamic> filters = <String, dynamic>{}.obs;
  RxSet<String> savedJobIds = <String>{}.obs;

  DocumentSnapshot? _lastDocument;
  static const _pageSize = 10;
  static const _jobsBox = 'jobs';
  static const _cacheKey = 'jobs_list';
  static const _cacheTimeKey = 'jobs_cached_at';

  @override
  void onInit() {
    super.onInit();
    loadJobs();
    loadSavedJobIds();
    scheduleBackgroundSync();
  }

  Future<void> loadJobs() async {
    final trace = FirebasePerformance.instance.newTrace('job_list_load');
    await trace.start();
    isLoading.value = true;
    try {
      final box = Hive.box(_jobsBox);
      final cachedAt = box.get(_cacheTimeKey) as String?;
      if (cachedAt != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedAt));
        if (age.inMinutes < 30) {
          final cached = (box.get(_cacheKey) as List?)
                  ?.map((e) => JobModel.fromHive(Map<String, dynamic>.from(e)))
                  .toList() ??
              [];
          if (cached.isNotEmpty) {
            jobs.assignAll(cached);
            _applyFilters();
            AppLogger.i('Jobs loaded from cache: ${cached.length}');
            return;
          }
        }
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.jobs)
          .where('status', isEqualTo: 'approved')
          .where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true)
          .limit(_pageSize)
          .get();
      FirestoreReadCounter.increment(snapshot.docs.length);

      _lastDocument =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final firestoreJobs =
          snapshot.docs.map(JobModel.fromFirestore).toList();

      List<JobModel> external = [];
      try {
        final dio = DioClient.jSearch().dio;
        final response = await dio.get(
          'https://jsearch.p.rapidapi.com/search',
          queryParameters: {'query': 'jobs in pakistan', 'page': '1'},
          options: Options(headers: {
            'X-RapidAPI-Key': dotenv.env['JSEARCH_API_KEY'] ?? '',
            'X-RapidAPI-Host': 'jsearch.p.rapidapi.com',
          }),
        );
        final data = response.data['data'] as List? ?? [];
        external = data
            .map((e) => JobModel.fromJSearch(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        AppLogger.w('JSearch fetch failed: $e');
      }

      final merged = <JobModel>[...firestoreJobs];
      for (final ext in external) {
        final dup = merged.any(
          (j) =>
              j.title.toLowerCase() == ext.title.toLowerCase() &&
              j.companyName.toLowerCase() == ext.companyName.toLowerCase(),
        );
        if (!dup) merged.add(ext);
      }

      jobs.assignAll(merged);
      box.put(_cacheKey, merged.map((j) => j.toHive()).toList());
      box.put(_cacheTimeKey, DateTime.now().toIso8601String());
      _applyFilters();
      AppLogger.i('Jobs loaded: ${merged.length}');
    } finally {
      isLoading.value = false;
      await trace.stop();
    }
  }

  Future<void> loadMoreJobs() async {
    if (_lastDocument == null || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.jobs)
          .where('status', isEqualTo: 'approved')
          .where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();
      FirestoreReadCounter.increment(snapshot.docs.length);
      if (snapshot.docs.isEmpty) return;
      _lastDocument = snapshot.docs.last;
      jobs.addAll(snapshot.docs.map(JobModel.fromFirestore));
      _applyFilters();
    } finally {
      isLoadingMore.value = false;
    }
  }

  void searchJobs(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void applyFilters(Map<String, dynamic> newFilters) {
    filters.assignAll(newFilters);
    _applyFilters();
  }

  void _applyFilters() {
    var result = jobs.toList();
    final q = searchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (j) =>
                j.title.toLowerCase().contains(q) ||
                j.companyName.toLowerCase().contains(q) ||
                j.location.toLowerCase().contains(q),
          )
          .toList();
    }
    final type = filters['type'] as String?;
    if (type != null && type != 'all') {
      result = result.where((j) => j.type == type).toList();
    }
    filteredJobs.assignAll(result);
  }

  Future<void> toggleSaveJob(String jobId) async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection(FirebaseCollections.savedJobs)
        .doc(uid)
        .collection('items')
        .doc(jobId);
    if (savedJobIds.contains(jobId)) {
      await ref.delete();
      savedJobIds.remove(jobId);
      savedJobs.removeWhere((j) => j.id == jobId);
    } else {
      await ref.set({'savedAt': FieldValue.serverTimestamp()});
      savedJobIds.add(jobId);
      final job = jobs.firstWhereOrNull((j) => j.id == jobId);
      if (job != null) savedJobs.add(job);
    }
  }

  Future<void> loadSavedJobIds() async {
    final uid = AuthProvider.to.currentUser.value?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance
        .collection(FirebaseCollections.savedJobs)
        .doc(uid)
        .collection('items')
        .get();
    FirestoreReadCounter.increment(snap.docs.length);
    savedJobIds.assignAll(snap.docs.map((d) => d.id));
  }

  Future<void> loadSavedJobs() async {
    await loadSavedJobIds();
    savedJobs.assignAll(
      jobs.where((j) => savedJobIds.contains(j.id)).toList(),
    );
  }

  void scheduleBackgroundSync() {
    Workmanager().registerPeriodicTask(
      'sync_jobs_task',
      'syncJobs',
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
