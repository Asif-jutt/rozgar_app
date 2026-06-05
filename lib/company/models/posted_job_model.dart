import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/user/models/job_model.dart';

class PostedJobModel extends JobModel {
  final String? rejectionReason;

  const PostedJobModel({
    required super.id,
    required super.title,
    required super.companyName,
    super.companyLogoUrl,
    required super.location,
    super.country,
    super.salaryMin,
    super.salaryMax,
    super.currency,
    super.description,
    super.requirements,
    super.type,
    super.status,
    required super.employerId,
    super.postedAt,
    super.deadline,
    super.applicationCount,
    super.isActive,
    this.rejectionReason,
  });

  factory PostedJobModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return PostedJobModel(
      id: doc.id,
      title: d['title'] as String? ?? '',
      companyName: d['companyName'] as String? ?? '',
      companyLogoUrl: d['companyLogoUrl'] as String?,
      location: d['location'] as String? ?? '',
      country: d['country'] as String? ?? 'Pakistan',
      salaryMin: (d['salaryMin'] as num?)?.toDouble() ?? 0,
      salaryMax: (d['salaryMax'] as num?)?.toDouble() ?? 0,
      currency: d['currency'] as String? ?? 'PKR',
      description: d['description'] as String? ?? '',
      requirements: List<String>.from(d['requirements'] ?? []),
      type: d['type'] as String? ?? 'fullTime',
      status: d['status'] as String? ?? 'pending',
      employerId: d['employerId'] as String? ?? '',
      postedAt: d['postedAt'] as Timestamp?,
      deadline: d['deadline'] as Timestamp?,
      applicationCount: d['applicationCount'] as int? ?? 0,
      isActive: d['isActive'] as bool? ?? true,
      rejectionReason: d['rejectionReason'] as String?,
    );
  }
}
