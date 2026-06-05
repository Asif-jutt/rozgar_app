import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reportedBy;
  final String reportedByName;
  final String targetType;
  final String targetId;
  final String reason;
  final String status;
  final Timestamp? createdAt;

  const ReportModel({
    required this.id,
    required this.reportedBy,
    required this.reportedByName,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.status = 'open',
    this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ReportModel(
      id: doc.id,
      reportedBy: d['reportedBy'] as String? ?? '',
      reportedByName: d['reportedByName'] as String? ?? '',
      targetType: d['targetType'] as String? ?? 'job',
      targetId: d['targetId'] as String? ?? '',
      reason: d['reason'] as String? ?? '',
      status: d['status'] as String? ?? 'open',
      createdAt: d['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'reportedBy': reportedBy,
        'reportedByName': reportedByName,
        'targetType': targetType,
        'targetId': targetId,
        'reason': reason,
        'status': status,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };
}
