import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';

class BuildprofileUI extends StatelessWidget {
  const BuildprofileUI({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> skills = [
      'Flutter',
      'React Native',
      'JavaScript',
      'Python',
      'Java',
      'C++',
      'SQL',
      'MongoDB',
      'Firebase',
      'AWS',
      'Docker',
      'UI Design',
      'UX Design',
    ];

    final List<String> degrees = [
      'Matric',
      'Bachelor',
      'Master',
      'PhD'
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.buildProfile,
        showBackButton: true,
      ),
      drawer: UserDrawer(
        userName: 'Your Name',
        userEmail: 'your@email.com',
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/Login');
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.selectSkills, style: AppTextStyles.headline4),
            const SizedBox(height: 8),
            Text('Select skills from the list',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),

            const SizedBox(height: 24),

            Text(AppStrings.enterDegrees, style: AppTextStyles.headline4),
            const SizedBox(height: 8),

            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select Degree'),
              value: null,
              items: degrees
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d),
                      ))
                  .toList(),
              onChanged: (_) {},
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: AppStrings.address,
              hintText: 'Enter your address',
              prefixIcon: Icons.location_on,
              maxLines: 2,
              minLines: 2,
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: AppStrings.email,
              hintText: 'Enter your email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            CustomButton(
              text: AppStrings.uploadCV,
              onPressed: () {},
              isOutlined: true,
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: AppStrings.create,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}