import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String companyName;
  final String? companyLogoUrl;
  final String location;
  final String country;
  final double salaryMin;
  final double salaryMax;
  final String currency;
  final String description;
  final List<String> requirements;
  final String type;
  final String status;
  final String employerId;
  final Timestamp? postedAt;
  final Timestamp? deadline;
  final int applicationCount;
  final bool isActive;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    this.companyLogoUrl,
    required this.location,
    this.country = 'Pakistan',
    this.salaryMin = 0,
    this.salaryMax = 0,
    this.currency = 'PKR',
    this.description = '',
    this.requirements = const [],
    this.type = 'fullTime',
    this.status = 'approved',
    required this.employerId,
    this.postedAt,
    this.deadline,
    this.applicationCount = 0,
    this.isActive = true,
  });

  String get formattedSalary {
    if (salaryMin <= 0 && salaryMax <= 0) return 'Negotiable';
    String fmt(double v) {
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
      return v.toStringAsFixed(0);
    }
    return '$currency ${fmt(salaryMin)}–${fmt(salaryMax)}';
  }

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return JobModel.fromMap(doc.id, d);
  }

  factory JobModel.fromMap(String id, Map<String, dynamic> d) {
    return JobModel(
      id: id,
      title: d['title'] as String? ?? '',
      companyName: d['companyName'] as String? ?? 'Unknown',
      companyLogoUrl: d['companyLogoUrl'] as String?,
      location: d['location'] as String? ?? '',
      country: d['country'] as String? ?? 'Pakistan',
      salaryMin: (d['salaryMin'] as num?)?.toDouble() ?? 0,
      salaryMax: (d['salaryMax'] as num?)?.toDouble() ?? 0,
      currency: d['currency'] as String? ?? 'PKR',
      description: d['description'] as String? ?? '',
      requirements: List<String>.from(d['requirements'] ?? []),
      type: d['type'] as String? ?? 'fullTime',
      status: d['status'] as String? ?? 'approved',
      employerId: d['employerId'] as String? ?? '',
      postedAt: d['postedAt'] as Timestamp?,
      deadline: d['deadline'] as Timestamp?,
      applicationCount: d['applicationCount'] as int? ?? 0,
      isActive: d['isActive'] as bool? ?? true,
    );
  }

  factory JobModel.fromJSearch(Map<String, dynamic> d) {
    return JobModel(
      id: d['job_id'] as String? ?? '',
      title: d['job_title'] as String? ?? '',
      companyName: d['employer_name'] as String? ?? 'Unknown',
      companyLogoUrl: d['employer_logo'] as String?,
      location: '${d['job_city'] ?? ''}, ${d['job_country'] ?? 'Pakistan'}',
      country: d['job_country'] as String? ?? 'Pakistan',
      description: d['job_description'] as String? ?? '',
      requirements: List<String>.from(d['job_required_skills'] ?? []),
      employerId: 'external',
      type: 'fullTime',
      status: 'approved',
      isActive: true,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'location': location,
        'country': country,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'currency': currency,
        'description': description,
        'requirements': requirements,
        'type': type,
        'status': status,
        'employerId': employerId,
        'postedAt': postedAt ?? FieldValue.serverTimestamp(),
        'deadline': deadline,
        'applicationCount': applicationCount,
        'isActive': isActive,
      };

  Map<String, dynamic> toHive() => {
        'id': id,
        'title': title,
        'companyName': companyName,
        'companyLogoUrl': companyLogoUrl,
        'location': location,
        'salaryMin': salaryMin,
        'salaryMax': salaryMax,
        'currency': currency,
        'type': type,
        'employerId': employerId,
        'description': description,
      };

  factory JobModel.fromHive(Map map) => JobModel(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        companyLogoUrl: map['companyLogoUrl'] as String?,
        location: map['location'] as String? ?? '',
        salaryMin: (map['salaryMin'] as num?)?.toDouble() ?? 0,
        salaryMax: (map['salaryMax'] as num?)?.toDouble() ?? 0,
        currency: map['currency'] as String? ?? 'PKR',
        type: map['type'] as String? ?? 'fullTime',
        employerId: map['employerId'] as String? ?? '',
        description: map['description'] as String? ?? '',
      );
}
