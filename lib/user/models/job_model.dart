import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String jobTitle;
  final String companyName;
  final String? companyId;
  final String location;
  final String salary;
  final List<String> requiredSkills;
  final String description;
  final DateTime postedDate;
  final String jobType; // Full-time, Part-time, etc.
  final String image;

  Job({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.companyId,
    required this.location,
    required this.salary,
    required this.requiredSkills,
    required this.description,
    required this.postedDate,
    required this.jobType,
    required this.image,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      companyId: json['companyId'],
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      description: json['description'] ?? '',
      // postedDate can be Firestore Timestamp or ISO string
      postedDate: (() {
        final raw = json['postedDate'];
        if (raw is Timestamp) return raw.toDate();
        if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
        return DateTime.now();
      })(),
      jobType: json['jobType'] ?? 'Full-time',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'companyId': companyId,
      'location': location,
      'salary': salary,
      'requiredSkills': requiredSkills,
      'description': description,
      'postedDate': postedDate.toIso8601String(),
      'jobType': jobType,
      'image': image,
    };
  }
}
