import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/user/widgets/job_comments_section.dart';
import 'package:rozgar/company/models/job_model.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rozgar/user/screens/chat/chat_screen.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';
import 'package:rozgar/company/screens/applicant_profile_view.dart';

class CompanyJobDetailsPage extends StatelessWidget {
  final JobModel job;

  const CompanyJobDetailsPage({super.key, required this.job});

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Job Insights'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobBannerImage(
              imageUrl: job.imageUrl,
              category: job.category,
              height: 200,
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: AppTextStyles.headline1.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildInfoChip(Icons.work, job.category),
                        _buildInfoChip(Icons.location_on, job.location),
                        _buildInfoChip(Icons.monetization_on, job.salary),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Description', style: AppTextStyles.headline3),
                    const SizedBox(height: 8),
                    Text(
                      job.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('jobs')
                          .doc(job.jobId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        int likes = job.likes.length;
                        int views = job.impressions;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final List currentLikes = data['likes'] ?? [];
                          likes = currentLikes.length;
                          views = data['impressions'] ?? 0;
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\u2764\uFE0F $likes Likes',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\uD83D\uDC41\uFE0F $views Views',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobCommentsSection(jobId: job.jobId, isCompany: true),
                  const SizedBox(height: 24),
                  const Text('Applicants', style: AppTextStyles.headline2),
                  const SizedBox(height: 16),
                  StreamBuilder<List<ApplicationModel>>(
                    stream: firestore.jobApplicationsStream(job.jobId),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snap.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final apps = snap.data ?? [];
                      if (apps.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No applicants yet.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: apps.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final app = apps[index];
                          final applicantName =
                              app.applicantName ?? 'Unknown Applicant';
                          final initils = applicantName.isNotEmpty
                              ? applicantName
                                    .trim()
                                    .split(' ')
                                    .map((e) => e.isNotEmpty ? e[0] : '')
                                    .take(2)
                                    .join('')
                                    .toUpperCase()
                              : '?';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryColor
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  initils,
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                applicantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: _getStatusColor(app.status),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      app.status,
                                      style: TextStyle(
                                        color: _getStatusColor(app.status),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.assignment),
                                    color: AppColors.primaryColor,
                                    tooltip: 'View Application Data',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Application Details'),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Name: ${app.applicantName ?? 'N/A'}',
                                                ),
                                                Text(
                                                  'Email: ${app.email ?? 'N/A'}',
                                                ),
                                                Text(
                                                  'Phone: ${app.phone ?? 'N/A'}',
                                                ),
                                                Text(
                                                  'University: ${app.university ?? 'N/A'}',
                                                ),
                                                Text(
                                                  'Semester: ${app.semester ?? 'N/A'}',
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Resume/Details:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  app.resumeText.isEmpty
                                                      ? 'No resume provided'
                                                      : app.resumeText,
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    color: Colors.blue,
                                    tooltip: 'Chat',
                                    onPressed: () {
                                      final currentUid = FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.uid;
                                      if (currentUid != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              currentUserId: currentUid,
                                              otherUserId: app.userId,
                                              otherUserName: applicantName,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                    ),
                                    color: Colors.grey,
                                    tooltip: 'View Profile',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ApplicantProfileView(
                                            userId: app.userId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApplicantProfileView(
                                      userId: app.userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('accept')) return Colors.green;
    if (lower.contains('reject')) return Colors.red;
    if (lower.contains('review')) return Colors.orange;
    return AppColors.primaryColor;
  }
}
