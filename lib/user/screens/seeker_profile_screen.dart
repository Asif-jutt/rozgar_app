import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/theme_provider.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:rozgar/user/providers/profile_provider.dart';

class SeekerProfileScreen extends StatefulWidget {
  const SeekerProfileScreen({super.key});

  @override
  State<SeekerProfileScreen> createState() => _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends State<SeekerProfileScreen> {
  final _phone = TextEditingController();
  final _cnic = TextEditingController();
  final _salary = TextEditingController();
  final _experience = TextEditingController();
  final _education = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.i('NAV: SeekerProfileScreen');
    final p = ProfileProvider.to.profile.value;
    if (p != null) {
      _phone.text = p.phone ?? '';
      _cnic.text = p.cnic ?? '';
      _salary.text = p.salaryExpectation ?? '';
      _experience.text = p.experience ?? '';
      _education.text = p.education ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileProvider.to;
    final auth = AuthProvider.to;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = profile.profile.value ?? auth.currentUser.value;
        if (user == null) return const Center(child: Text('Not signed in'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showPhotoSheet(),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl != null
                      ? CachedNetworkImageProvider(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text((user.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 36))
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(user.displayName ?? '', style: Theme.of(context).textTheme.titleLarge),
              Text(user.email),
              if (user.isPremium)
                const Chip(label: Text('⭐ Premium')),
              const SizedBox(height: 24),
              if (!user.isPremium)
                Card(
                  color: Colors.amber.shade50,
                  child: ListTile(
                    title: const Text(AppStrings.premiumTitle),
                    subtitle: const Text('No ads, resume boost, unlimited applications'),
                    trailing: FilledButton(
                      onPressed: profile.purchasePremium,
                      child: const Text(AppStrings.premiumPrice),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone 🔒',
                  prefixIcon: Icon(Icons.lock_outline),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cnic,
                decoration: const InputDecoration(
                  labelText: 'CNIC 🔒',
                  prefixIcon: Icon(Icons.lock_outline),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _salary,
                decoration: const InputDecoration(
                  labelText: 'Salary Expectation (PKR) 🔒',
                  prefixIcon: Icon(Icons.lock_outline),
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _experience,
                decoration: const InputDecoration(
                  labelText: 'Experience',
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _education,
                decoration: const InputDecoration(
                  labelText: 'Education',
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: profile.uploadResume,
                icon: const Icon(Icons.upload_file),
                label: const Text(AppStrings.uploadResume),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: ThemeProvider.to.isDarkMode.value,
                onChanged: (_) => ThemeProvider.to.toggleTheme(),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => profile.updateProfile({
                  'phone': _phone.text,
                  'cnic': _cnic.text,
                  'salaryExpectation': _salary.text,
                  'experience': _experience.text,
                  'education': _education.text,
                }),
                child: const Text(AppStrings.saveChanges),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: auth.signOut,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(AppStrings.signOut),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showPhotoSheet() {
    Get.bottomSheet(
      Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Get.back();
              ProfileProvider.to.uploadProfileImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Get.back();
              ProfileProvider.to.uploadProfileImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}
