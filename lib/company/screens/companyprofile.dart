import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/models/user_profile_model.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/company/widgets/company_shell.dart';
import 'package:rozgar/user/widgets/network_image_widget.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _firestore = FirestoreService();
  final _bioCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _profileImageUrlCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await _firestore.getUser(uid);
    final profile = await _firestore.getUserProfile(uid);
    _bioCtrl.text = profile?.bio ?? '';
    _industryCtrl.text = profile?.experience ?? '';
    _profileImageUrlCtrl.text =
        profile?.profileImageUrl ?? user?.profileImageUrl ?? '';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      await _firestore.saveUserProfile(UserProfileModel(
        userId: user.uid,
        bio: _bioCtrl.text.trim(),
        skills: _industryCtrl.text.trim().isEmpty
            ? []
            : [_industryCtrl.text.trim()],
        education: '',
        experience: _industryCtrl.text.trim(),
        profileImageUrl: _profileImageUrlCtrl.text.trim().isEmpty
            ? null
            : _profileImageUrlCtrl.text.trim(),
      ));
      if (_profileImageUrlCtrl.text.trim().isNotEmpty) {
        await _firestore.updateUserProfileImage(
          user.uid,
          _profileImageUrlCtrl.text.trim(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company profile saved'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _industryCtrl.dispose();
    _profileImageUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompanyShell(
      title: 'Company Profile',
      navIndex: 3,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  ProfileAvatar(
                    imageUrl: _profileImageUrlCtrl.text.isEmpty
                        ? null
                        : _profileImageUrlCtrl.text,
                    radius: 50,
                    fallbackText: 'C',
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _profileImageUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Company Logo URL',
                      hintText: 'https://images.unsplash.com/...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'About Company',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _industryCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Industry / Sector',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Profile'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}


