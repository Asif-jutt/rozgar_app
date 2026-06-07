import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rozgar/core/config/external_services_config.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/user/models/remote_job.dart';
import 'package:rozgar/services/profiling_service.dart';

/// External REST API integration (Remotive + REST Countries).
class RestApiService {
  RestApiService._();
  static final RestApiService instance = RestApiService._();

  static const _remotiveUrl = ExternalServicesConfig.remotiveJobsApi;
  static const _countriesUrl = ExternalServicesConfig.restCountriesApi;

  final http.Client _client = http.Client();

  /// Fetch remote jobs from Remotive public API.
  Future<List<RemoteJob>> fetchRemoteJobs({String? category}) async {
    return ProfilingService.instance.trace('rest_fetch_remote_jobs', () async {
      try {
        final uri = category != null && category != 'All'
            ? Uri.parse('$_remotiveUrl?category=$category')
            : Uri.parse(_remotiveUrl);

        final response = await _client.get(uri).timeout(
              const Duration(seconds: 15),
            );

        if (response.statusCode != 200) {
          AppLogger.warning(
            'Remotive API returned ${response.statusCode}',
          );
          return [];
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final jobs = data['jobs'] as List<dynamic>? ?? [];
        return jobs
            .map((j) => RemoteJob.fromJson(j as Map<String, dynamic>))
            .take(20)
            .toList();
      } catch (e, st) {
        AppLogger.error('fetchRemoteJobs failed', e, st);
        return [];
      }
    });
  }

  /// Fetch country/city names for location filters.
  Future<List<String>> fetchLocations() async {
    return ProfilingService.instance.trace('rest_fetch_locations', () async {
      try {
        final response = await _client.get(Uri.parse(_countriesUrl)).timeout(
              const Duration(seconds: 15),
            );

        if (response.statusCode != 200) return defaultLocations;

        final data = jsonDecode(response.body) as List<dynamic>;
        final locations = <String>{'All', 'Remote'};
        for (final item in data) {
          final map = item as Map<String, dynamic>;
          final name = map['name'];
          if (name is Map && name['common'] != null) {
            locations.add(name['common'].toString());
          }
          final capital = map['capital'];
          if (capital is List && capital.isNotEmpty) {
            locations.add(capital.first.toString());
          }
        }
        return locations.take(30).toList();
      } catch (e, st) {
        AppLogger.error('fetchLocations failed', e, st);
        return defaultLocations;
      }
    });
  }

  static const defaultLocations = [
    'All',
    'Remote',
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Multan',
  ];

  void dispose() => _client.close();
}
