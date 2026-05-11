import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:rozgar/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool isPasswordHidden = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppStrings.login, showBackButton: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text
              Text(AppStrings.welcome, style: AppTextStyles.headline2),
              const SizedBox(height: AppSpacing.verticalSpaceSmall),
              Text('Login to your account', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.verticalSpaceLarge),

              // Email TextField
              CustomTextField(
                controller: emailController,
                label: AppStrings.email,
                hintText: 'Enter your email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final emailValue = value?.trim() ?? '';
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (emailValue.isEmpty) {
                    return 'Please enter your email.';
                  }
                  if (!emailRegex.hasMatch(emailValue)) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.verticalSpaceMedium),

              // Password TextField
              CustomTextField(
                controller: passwordController,
                label: AppStrings.password,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock,
                obscureText: isPasswordHidden,
                suffixIcon: Icons.visibility,
                onSuffixIconPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.verticalSpaceSmall),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email first.'),
                        ),
                      );
                      return;
                    }
                    _authService.resetPassword(emailController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent to your email.'),
                      ),
                    );
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
                isLoading: isLoading,
                onPressed: _login,
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
      ),
    );
  }
}
