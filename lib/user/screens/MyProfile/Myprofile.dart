import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  int _selectedBottomNavIndex = 0;

  // Sample Data
  final List<String> skills = ['Flutter', 'Dart', 'Firebase', 'REST API'];
  final List<Map<String, String>> educations = [
    {'degree': 'Matric', 'institution': 'ABC High School'},
    {'degree': 'Bachelor', 'institution': 'XYZ University'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.myProfile,
        showBackButton: true,
      ),
      drawer: UserDrawer(
        userName: 'John Doe',
        userEmail: 'john@example.com',
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/Login');
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Card(
              elevation: AppDimensions.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryColor,
                      child: const Text(
                        'JD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.horizontalSpaceLarge),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('John Doe', style: AppTextStyles.headline4),
                          const SizedBox(height: 4),
                          Text(
                            'john@example.com',
                            style: AppTextStyles.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Karachi, Pakistan',
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

            // My Skills Section
            Text(AppStrings.mySkills, style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: AppSpacing.horizontalSpaceMedium,
                mainAxisSpacing: AppSpacing.verticalSpaceMedium,
              ),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: AppDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  color: AppColors.primaryLight.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.successColor,
                          size: AppDimensions.iconLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          skills[index],
                          style: AppTextStyles.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // My Educations Section
            Text(AppStrings.myEducations, style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: educations.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: AppDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    bottom: AppSpacing.verticalSpaceMedium,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.school,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              educations[index]['degree']!,
                              style: AppTextStyles.labelLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          educations[index]['institution']!,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Other Info Section
            Text(AppStrings.otherInfo, style: AppTextStyles.headline3),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: AppSpacing.horizontalSpaceMedium,
              mainAxisSpacing: AppSpacing.verticalSpaceMedium,
              children: [
                Card(
                  elevation: AppDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.primaryColor,
                          size: AppDimensions.iconLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Phone', style: AppTextStyles.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          '+92 3001234567',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: AppDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLarge,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: AppColors.primaryColor,
                          size: AppDimensions.iconLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text('Location', style: AppTextStyles.labelSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Karachi, Pakistan',
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        items: [
          NavigationItem(icon: Icons.home, label: AppStrings.home),
          NavigationItem(icon: Icons.search, label: AppStrings.findJobs),
          NavigationItem(icon: Icons.edit, label: AppStrings.edit),
        ],
        onTap: (index) {
          setState(() => _selectedBottomNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/home');
              break;
            case 2:
              Navigator.pushNamed(context, '/buildprofile');
              break;
          }
        },
      ),
    );
  }
}
