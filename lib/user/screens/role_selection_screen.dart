import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/user_auth_provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('NAV: RoleSelectionScreen');
    final auth = UserAuthProvider.to;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final adminDomain = dotenv.env['ADMIN_EMAIL_DOMAIN'] ?? '@rozgar.admin';
    final showAdmin = email.endsWith(adminDomain);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _RoleCard(
              title: AppStrings.roleSeeker,
              subtitle: 'Find and apply for jobs',
              icon: Icons.person,
              color: AppColors.primary,
              onTap: () => auth.saveUserRole('jobSeeker'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              title: AppStrings.roleEmployer,
              subtitle: 'Post jobs and hire talent',
              icon: Icons.business,
              color: Colors.blue,
              onTap: () => auth.saveUserRole('employer'),
            ),
            if (showAdmin) ...[
              const SizedBox(height: 16),
              _RoleCard(
                title: AppStrings.roleAdmin,
                subtitle: 'Manage platform',
                icon: Icons.admin_panel_settings,
                color: Colors.purple,
                onTap: () => auth.saveUserRole('admin'),
              ),
            ],
            Obx(() {
              if (!auth.isLoading.value) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
