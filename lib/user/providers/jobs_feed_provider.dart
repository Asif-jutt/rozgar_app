import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/user/models/feed_job.dart';
import 'package:rozgar/user/models/job_model.dart';
import 'package:rozgar/user/models/remote_job.dart';
import 'package:rozgar/services/profiling_service.dart';
import 'package:rozgar/services/rest_api_service.dart';

enum JobFeedTab { all, local, api }

/// Heavy filter/sort runs in a background isolate (threading requirement).
List<Map<String, String>> _filterJobKeys(Map<String, dynamic> args) {
  final keys = (args['keys'] as List).cast<Map<String, String>>();
  final query = (args['query'] as String).toLowerCase();
  final location = args['location'] as String;
  final category = args['category'] as String;
  final tab = args['tab'] as String;

  return keys.where((m) {
    if (tab == 'local' && m['source'] != 'local') return false;
    if (tab == 'api' && m['source'] != 'api') return false;
    if (location != 'All' &&
        !m['location']!.toLowerCase().contains(location.toLowerCase())) {
      return false;
    }
    if (category != 'All' && m['category'] != category) return false;
    if (query.isEmpty) return true;
    final hay =
        '${m['title']} ${m['company']} ${m['location']} ${m['category']}'
            .toLowerCase();
    return hay.contains(query);
  }).toList();
}

class JobsFeedProvider extends ChangeNotifier {
  final RestApiService _api = RestApiService.instance;

  List<FeedJob> _jobs = [];
  List<FeedJob> get jobs => _jobs;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  JobFeedTab _tab = JobFeedTab.all;
  JobFeedTab get tab => _tab;

  String _searchQuery = '';
  String _location = 'All';
  String _category = 'All';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _localSub;
  List<JobModel> _localJobs = [];
  List<RemoteJob> _apiJobs = [];
  final Map<String, FeedJob> _feedIndex = {};

  JobsFeedProvider() {
    _init();
  }

  void _init() {
    _localSub = FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .listen(
      (snap) {
        _localJobs =
            snap.docs.map((d) => JobModel.fromMap(d.id, d.data())).toList();
        _rebuild();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
    _fetchApiJobs();
  }

  Future<void> _fetchApiJobs() async {
    try {
      _apiJobs = await _api.fetchRemoteJobs();
    } catch (e) {
      AppLogger.error('API jobs fetch failed', e);
    }
    _rebuild();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    await _fetchApiJobs();
  }

  void setTab(JobFeedTab tab) {
    _tab = tab;
    _rebuild();
  }

  void setSearch(String q) {
    _searchQuery = q;
    _rebuild();
  }

  void setFilters({String? location, String? category}) {
    if (location != null) _location = location;
    if (category != null) _category = category;
    _rebuild();
  }

  FeedJob? findById(String id) => _feedIndex[id];

  Future<void> _rebuild() async {
    _feedIndex.clear();
    for (final j in _localJobs) {
      final f = FeedJob.local(j);
      _feedIndex[f.id] = f;
    }
    for (final j in _apiJobs) {
      final f = FeedJob.api(j);
      _feedIndex[f.id] = f;
    }

    final keys = _feedIndex.values
        .map((f) => {
              'key': f.id,
              'source': f.isLocal ? 'local' : 'api',
              'title': f.title,
              'company': f.companyName,
              'location': f.location,
              'category': f.category,
            })
        .toList();

    final filteredKeys = await ProfilingService.instance
        .trace('feed_filter_isolate', () => compute(_filterJobKeys, {
              'keys': keys,
              'query': _searchQuery,
              'location': _location,
              'category': _category,
              'tab': _tab.name,
            }));

    _jobs = filteredKeys
        .map((m) => _feedIndex[m['key']!])
        .whereType<FeedJob>()
        .toList();

    _loading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _localSub?.cancel();
    super.dispose();
  }
}
