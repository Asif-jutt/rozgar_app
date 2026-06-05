import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/company/constants/company_strings.dart';
import 'package:rozgar/company/models/applicant_model.dart';
import 'package:rozgar/company/providers/applicants_provider.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/constants/app_routes.dart';

class ApplicantCard extends StatelessWidget {
  final ApplicantModel applicant;
  const ApplicantCard({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (applicant.status) {
      case 'accepted':
        statusColor = AppColors.statusAccepted;
      case 'rejected':
        statusColor = AppColors.statusRejected;
      case 'viewed':
        statusColor = AppColors.statusViewed;
      default:
        statusColor = AppColors.statusPending;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: applicant.seekerPhotoUrl != null
              ? NetworkImage(applicant.seekerPhotoUrl!)
              : null,
          child: applicant.seekerPhotoUrl == null
              ? Text(applicant.seekerName[0])
              : null,
        ),
        title: Text(applicant.seekerName),
        subtitle: Text(applicant.seekerEmail),
        trailing: Chip(
          label: Text(applicant.status),
          backgroundColor: statusColor.withValues(alpha: 0.15),
        ),
        onTap: () => Get.toNamed(
          AppRoutes.companyApplicantDetail,
          arguments: applicant,
        ),
      ),
    );
  }
}
