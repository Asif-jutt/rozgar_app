import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/models/user_profile_model.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/services/permission_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/user/widgets/drawer.dart';
import 'package:rozgar/core/widgets/network_image_widget.dart';

class BuildprofileUI extends StatefulWidget {
  const BuildprofileUI({super.key});

  @override
  State<BuildprofileUI> createState() => _BuildprofileUIState();
}

class _BuildprofileUIState extends State<BuildprofileUI> {
  final _firestore = FirestoreService();
  final _bioCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _profileImageUrlCtrl = TextEditingController();
  final _cvUrlCtrl = TextEditingController();
  final Set<String> _selectedSkills = {};
  bool _saving = false;

  static const _skillOptions = [
    'Flutter', 'Dart', 'Firebase', 'React', 'Node.js', 'Python',
    'Java', 'SQL', 'UI/UX', 'Marketing', 'Sales', 'Communication',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final p = await _firestore.getUserProfile(uid);
    if (p != null && mounted) {
      _bioCtrl.text = p.bio;
      _educationCtrl.text = p.education;
      _experienceCtrl.text = p.experience;
      _profileImageUrlCtrl.text = p.profileImageUrl ?? '';
      _cvUrlCtrl.text = p.cvResumeUrl ?? '';
      _selectedSkills.addAll(p.skills);
      setState(() {});
    }
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _saving = true);
    try {
      await PermissionService.instance.requestStoragePermission();
      final profile = UserProfileModel(
        userId: user.uid,
        bio: _bioCtrl.text.trim(),
        skills: _selectedSkills.toList(),
        education: _educationCtrl.text.trim(),
        experience: _experienceCtrl.text.trim(),
        profileImageUrl: _profileImageUrlCtrl.text.trim().isEmpty
            ? null
            : _profileImageUrlCtrl.text.trim(),
        cvResumeUrl:
            _cvUrlCtrl.text.trim().isEmpty ? null : _cvUrlCtrl.text.trim(),
      );
      await _firestore.saveUserProfile(profile);

      if (_profileImageUrlCtrl.text.trim().isNotEmpty) {
        await _firestore.updateUserProfileImage(
          user.uid,
          _profileImageUrlCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          backgroundColor: AppColors.successColor,
        ),
      );
      Navigator.pushReplacementNamed(context, '/user_home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _educationCtrl.dispose();
    _experienceCtrl.dispose();
    _profileImageUrlCtrl.dispose();
    _cvUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.buildProfile,
        showBackButton: true,
      ),
      drawer: const SeekerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ProfileAvatar(
                imageUrl: _profileImageUrlCtrl.text.isEmpty
                    ? null
                    : _profileImageUrlCtrl.text,
                radius: 50,
                fallbackText: 'U',
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Profile Image URL',
              hintText: 'https://example.com/photo.jpg',
              prefixIcon: Icons.image,
              controller: _profileImageUrlCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'CV / Resume URL',
              hintText: 'https://drive.google.com/... or any link',
              prefixIcon: Icons.link,
              controller: _cvUrlCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Bio',
              hintText: 'Tell employers about yourself',
              prefixIcon: Icons.info_outline,
              controller: _bioCtrl,
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            Text(AppStrings.selectSkills, style: AppTextStyles.headline4),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skillOptions
                  .map(
                    (s) => FilterChip(
                      label: Text(s),
                      selected: _selectedSkills.contains(s),
                      onSelected: (v) => setState(() {
                        v ? _selectedSkills.add(s) : _selectedSkills.remove(s);
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Education',
              hintText: 'e.g. BS Computer Science - COMSATS',
              prefixIcon: Icons.school,
              controller: _educationCtrl,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Experience',
              hintText: 'e.g. 2 years Flutter Developer',
              prefixIcon: Icons.work_history,
              controller: _experienceCtrl,
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: AppStrings.save,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
