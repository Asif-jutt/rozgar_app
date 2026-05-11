import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/services/auth_service.dart';
import 'package:rozgar/services/database_service.dart';
import 'package:rozgar/user/models/user_model.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = names.map((n) => n[0]).join().toUpperCase();
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: AppStrings.myProfile,
          showBackButton: true,
        ),
        body: const Center(
          child: Text('Please log in to view your profile'),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.myProfile,
        showBackButton: true,
      ),
      drawer: UserDrawer(
        userName: currentUser.email ?? 'User',
        userEmail: currentUser.email ?? '',
        onLogout: () async {
          await _authService.logout();
        },
      ),
      body: StreamBuilder<UserProfile?>(
        stream: _databaseService.getUserProfileStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final profile = snapshot.data;

          if (profile == null) {
            return const Center(
              child: Text('Profile not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  elevation: AppDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            _getInitials(profile.fullName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: AppSpacing.horizontalSpaceLarge),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.fullName,
                                style: AppTextStyles.headline4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.email,
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                profile.address.isNotEmpty
                                    ? profile.address
                                    : 'Address not set',
                                style: AppTextStyles.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.verticalSpaceLarge),

                // Contact Information
                Text('Contact Information',
                    style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.verticalSpaceMedium),
                _buildInfoCard(
                  'Phone',
                  profile.phoneNumber.isNotEmpty
                      ? profile.phoneNumber
                      : 'Not provided',
                  Icons.phone,
                ),
                const SizedBox(height: AppSpacing.verticalSpaceSmall),
                _buildInfoCard(
                  'CNIC',
                  profile.cnic.isNotEmpty ? profile.cnic : 'Not provided',
                  Icons.card_membership,
                ),
                const SizedBox(height: AppSpacing.verticalSpaceLarge),

                // My Skills Section
                Text(AppStrings.mySkills, style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.verticalSpaceMedium),
                if (profile.skills.isEmpty)
                  const Text('No skills added yet')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            backgroundColor: AppColors.primaryColor,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: AppSpacing.verticalSpaceLarge),

                // Education Section
                Text('Education', style: AppTextStyles.headline3),
                const SizedBox(height: AppSpacing.verticalSpaceMedium),
                if (profile.educations.isEmpty)
                  const Text('No education added yet')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: profile.educations.length,
                    itemBuilder: (context, index) {
                      final education = profile.educations[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(
                              AppDimensions.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                education.degree,
                                style: AppTextStyles.headline4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                education.institution,
                                style: AppTextStyles.bodySmall,
                              ),
                              if (education.year != null)
                                Text(
                                  'Year: ${education.year}',
                                  style: AppTextStyles.labelSmall,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.verticalSpaceLarge),

                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/buildprofile');
                    },
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryColor),
            const SizedBox(width: AppSpacing.horizontalSpaceMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

