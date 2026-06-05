import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/widgets/responsive_center.dart';
import 'package:rozgar/user/constants/app_colors.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/auth_provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('NAV: RoleSelectionScreen');
    final auth = AuthProvider.to;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final adminDomain = dotenv.env['ADMIN_EMAIL_DOMAIN'] ?? '@rozgar.admin';
    final showAdmin = email.endsWith(adminDomain);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.paddingOf(context).top + 24,
                  24,
                  32,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Rozgar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you want to use the platform',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 16,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Chip(
                        avatar: const Icon(Icons.email_outlined, size: 18),
                        label: Text(email),
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ResponsiveCenter(
                  maxWidth: 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _RoleCard(
                        title: AppStrings.roleSeeker,
                        subtitle: 'Browse jobs, apply, and track applications',
                        icon: Icons.person_search,
                        color: AppColors.primary,
                        onTap: () => auth.saveUserRole('jobSeeker'),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        title: AppStrings.roleEmployer,
                        subtitle: 'Post jobs, review applicants, and hire talent',
                        icon: Icons.business_center,
                        color: Colors.blue,
                        onTap: () => auth.saveUserRole('employer'),
                      ),
                      if (showAdmin) ...[
                        const SizedBox(height: 16),
                        _RoleCard(
                          title: AppStrings.roleAdmin,
                          subtitle: 'Moderate jobs, manage users, and view reports',
                          icon: Icons.admin_panel_settings,
                          color: Colors.purple,
                          onTap: () => auth.saveUserRole('admin'),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'You can update your profile after signing in.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (!auth.isLoading.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            );
          }),
        ],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
