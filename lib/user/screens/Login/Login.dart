import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.login, showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Text
            Text(AppStrings.welcome, style: AppTextStyles.headline2),
            const SizedBox(height: AppSpacing.verticalSpaceSmall),
            Text('Login to your account', style: AppTextStyles.bodySmall),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // CNIC TextField
            CustomTextField(
              label: AppStrings.cnic,
              hintText: 'Enter your CNIC number',
              prefixIcon: Icons.card_membership,
              keyboardType: TextInputType.number,
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
            const SizedBox(height: AppSpacing.verticalSpaceSmall),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Forgot password logic
                },
                child: const Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Login Button
            CustomButton(
              text: AppStrings.login,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/user_home');
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Sign Up Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: AppTextStyles.bodySmall,
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/Signup'),
                  child: const Text(
                    AppStrings.signup,
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
