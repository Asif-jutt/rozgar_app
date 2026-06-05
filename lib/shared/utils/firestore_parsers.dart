import 'package:cloud_firestore/cloud_firestore.dart';

/// Parses Firestore timestamp fields that may be stored as [Timestamp],
/// ISO-8601 strings, epoch millis, or web-style second/nanosecond maps.
Timestamp? parseFirestoreTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value;
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return Timestamp.fromDate(parsed);
  }
  if (value is int) {
    return Timestamp.fromMillisecondsSinceEpoch(value);
  }
  if (value is Map) {
    final seconds = value['_seconds'] ?? value['seconds'];
    final nanoseconds = value['_nanoseconds'] ?? value['nanoseconds'] ?? 0;
    if (seconds is int) {
      return Timestamp(seconds, nanoseconds is int ? nanoseconds : 0);
    }
  }
  return null;
}
