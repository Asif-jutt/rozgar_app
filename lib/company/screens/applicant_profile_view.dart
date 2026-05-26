import 'package:flutter/material.dart';
import 'package:rozgar/core/app_images.dart';
import 'package:rozgar/user/models/user_profile_model.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/models/app_user.dart';

class ApplicantProfileView extends StatefulWidget {
  final String userId;

  const ApplicantProfileView({super.key, required this.userId});

  @override
  State<ApplicantProfileView> createState() => _ApplicantProfileViewState();
}

class _ApplicantProfileViewState extends State<ApplicantProfileView> {
  final _firestore = FirestoreService();
  bool _loading = true;
  UserProfileModel? _profile;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _profile = await _firestore.getUserProfile(widget.userId);
    _user = await _firestore.getUser(widget.userId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _profile?.profileImageUrl != null &&
                              _profile!.profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profile!.profileImageUrl!)
                          : const NetworkImage(AppImages.defaultAvatar)
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.name ?? 'Unknown',
                    style: AppTextStyles.headline3,
                  ),
                  const SizedBox(height: 4),
                  Text(_user?.email ?? '', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 24),
                  if (_profile != null) ...[
                    _section('Bio', _profile!.bio),
                    _section('Skills', _profile!.skills.join(', ')),
                    _section('Experience', _profile!.experience),
                    _section('Education', _profile!.education),
                    _section('Resume URL / Text', _profile!.cvResumeUrl),
                  ] else
                    const Text('No detailed profile found.'),
                ],
              ),
            ),
    );
  }

  Widget _section(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
