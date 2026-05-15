import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.signup,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Text('Create Account', style: AppTextStyles.headline2),
            const SizedBox(height: AppSpacing.verticalSpaceSmall),
            Text(
              'Join our job portal community',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Name TextField
            CustomTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Email TextField
            CustomTextField(
              label: AppStrings.email,
              hintText: 'Enter your email',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Password TextField
            CustomTextField(
              label: AppStrings.password,
              hintText: 'Enter your password',
              prefixIcon: Icons.lock,
              obscureText: true,
              suffixIcon: Icons.visibility,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Confirm Password TextField
            CustomTextField(
              label: AppStrings.confirmPassword,
              hintText: 'Confirm your password',
              prefixIcon: Icons.lock,
              obscureText: true,
              suffixIcon: Icons.visibility,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Signup Button
            CustomButton(
              text: AppStrings.signup,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/buildprofile');
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodySmall,
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    AppStrings.login,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
