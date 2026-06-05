import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_colors.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String seekerId;
  final String seekerName;
  final String? seekerPhotoUrl;
  final String status;
  final Timestamp? appliedAt;
  final String? resumeUrl;
  final String? coverLetter;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.seekerId,
    required this.seekerName,
    this.seekerPhotoUrl,
    this.status = 'pending',
    this.appliedAt,
    this.resumeUrl,
    this.coverLetter,
  });

  Color get statusColor {
    switch (status) {
      case 'accepted':
        return AppColors.statusAccepted;
      case 'rejected':
        return AppColors.statusRejected;
      case 'viewed':
        return AppColors.statusViewed;
      default:
        return AppColors.statusPending;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'viewed':
        return 'Viewed';
      default:
        return 'Pending';
    }
  }

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ApplicationModel(
      id: doc.id,
      jobId: d['jobId'] as String? ?? '',
      jobTitle: d['jobTitle'] as String? ?? '',
      companyName: d['companyName'] as String? ?? '',
      seekerId: d['seekerId'] as String? ?? '',
      seekerName: d['seekerName'] as String? ?? '',
      seekerPhotoUrl: d['seekerPhotoUrl'] as String?,
      status: d['status'] as String? ?? 'pending',
      appliedAt: d['appliedAt'] as Timestamp?,
      resumeUrl: d['resumeUrl'] as String?,
      coverLetter: d['coverLetter'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'seekerId': seekerId,
        'seekerName': seekerName,
        'seekerPhotoUrl': seekerPhotoUrl,
        'status': status,
        'appliedAt': appliedAt ?? FieldValue.serverTimestamp(),
        'resumeUrl': resumeUrl,
        'coverLetter': coverLetter,
      };

  Map<String, dynamic> toHive() => {
        'id': id,
        'jobId': jobId,
        'jobTitle': jobTitle,
        'companyName': companyName,
        'seekerId': seekerId,
        'seekerName': seekerName,
        'resumeUrl': resumeUrl,
        'coverLetter': coverLetter,
      };

  factory ApplicationModel.fromHive(Map map) => ApplicationModel(
        id: map['id'] as String? ?? '',
        jobId: map['jobId'] as String? ?? '',
        jobTitle: map['jobTitle'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        seekerId: map['seekerId'] as String? ?? '',
        seekerName: map['seekerName'] as String? ?? '',
        resumeUrl: map['resumeUrl'] as String?,
        coverLetter: map['coverLetter'] as String?,
      );
}
