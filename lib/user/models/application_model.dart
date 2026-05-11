import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplication {
  final String id;
  final String jobId;
  final String userId;
  final String? userName;
  final String jobTitle;
  final String companyName;
  final String status; // Applied, Under Review, Interview, Rejected, Accepted
  final DateTime appliedDate;
  final String? interviewDate;
  final String? feedback;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    this.userName,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.appliedDate,
    this.interviewDate,
    this.feedback,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      status: json['status'] ?? 'Applied',
      appliedDate: (() {
        final raw = json['appliedDate'];
        if (raw is Timestamp) return raw.toDate();
        if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
        return DateTime.now();
      })(),
      interviewDate: json['interviewDate'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'userId': userId,
      'userName': userName,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'status': status,
      'appliedDate': appliedDate.toIso8601String(),
      'interviewDate': interviewDate,
      'feedback': feedback,
    };
  }
}
