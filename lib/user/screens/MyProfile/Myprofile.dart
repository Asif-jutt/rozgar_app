import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/drawer.dart';
import 'package:rozgar/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Myprofile extends StatelessWidget {
  const Myprofile({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirestoreService();

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.myProfile,
        showBackButton: true,
      ),
      drawer: const SeekerDrawer(),
      body: uid == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder(
              stream: firestore.userProfileStream(uid),
              builder: (context, profileSnap) {
                return FutureBuilder(
                  future: firestore.getUser(uid),
                  builder: (context, userSnap) {
                    final user = userSnap.data;
                    final profile = profileSnap.data;
                    final name = user?.name ?? 'User';
                    final email = user?.email ?? '';
                    final imageUrl =
                        profile?.profileImageUrl ?? user?.profileImageUrl;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  ProfileAvatar(
                                    imageUrl: imageUrl,
                                    radius: 50,
                                    fallbackText: name,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(name, style: AppTextStyles.headline3),
                                  Text(email, style: AppTextStyles.bodySmall),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (profile?.bio.isNotEmpty == true)
                            _section('Bio', profile!.bio),
                          if (profile?.skills.isNotEmpty == true)
                            _chipsSection('Skills', profile!.skills),
                          if (profile?.education.isNotEmpty == true)
                            _section('Education', profile!.education),
                          if (profile?.experience.isNotEmpty == true)
                            _section('Experience', profile!.experience),
                          if (profile?.cvResumeUrl != null &&
                              profile!.cvResumeUrl!.isNotEmpty)
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.link,
                                    color: AppColors.primaryColor),
                                title: const Text('CV / Resume'),
                                subtitle: Text(
                                  profile.cvResumeUrl!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.open_in_new),
                                onTap: () => _openUrl(profile.cvResumeUrl!),
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/buildprofile'),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _section(String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Text(body, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _chipsSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((s) => Chip(label: Text(s))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
