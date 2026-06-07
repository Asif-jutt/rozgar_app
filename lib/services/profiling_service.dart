import 'package:rozgar/core/logger/app_logger.dart';

/// Performance profiling wrapper for measuring operation duration.
class ProfilingService {
  ProfilingService._();
  static final ProfilingService instance = ProfilingService._();

  final Map<String, List<Duration>> _samples = {};

  Future<T> trace<T>(String label, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _record(label, stopwatch.elapsed);
      AppLogger.debug('Profile [$label]: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  T traceSync<T>(String label, T Function() operation) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _record(label, stopwatch.elapsed);
      AppLogger.debug('Profile [$label]: ${stopwatch.elapsedMilliseconds}ms');
    }
  }

  void _record(String label, Duration duration) {
    _samples.putIfAbsent(label, () => []).add(duration);
    if (_samples[label]!.length > 50) {
      _samples[label]!.removeAt(0);
    }
  }

  Map<String, double> getAverageTimingsMs() {
    return _samples.map((key, values) {
      if (values.isEmpty) return MapEntry(key, 0.0);
      final avg = values.fold<int>(0, (s, d) => s + d.inMilliseconds) /
          values.length;
      return MapEntry(key, avg);
    });
  }

  void logSummary() {
    final summary = getAverageTimingsMs();
    if (summary.isEmpty) return;
    AppLogger.info('Profiling summary: $summary');
  }
}
