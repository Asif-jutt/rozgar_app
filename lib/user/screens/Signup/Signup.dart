import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/constants/app_constants.dart';
import 'package:rozgar/user/widgets/app_bar_widgets.dart';
import 'package:rozgar/user/widgets/custom_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final CollectionReference<Map<String, dynamic>> usersCollection =
      FirebaseFirestore.instance.collection('users');
  bool isLoading = false;
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  // creating authentication instance
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> register() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw FirebaseAuthException(
          code: 'user-not-created',
          message: 'User account could not be created. Please try again.',
        );
      }

      await usersCollection.doc(uid).set({
        'id': uid,
        'fullName': name.text.trim(),
        'email': email.text.trim().toLowerCase(),
        'phoneNumber': '',
        'cnic': '',
        'address': '',
        'skills': <String>[],
        'educations': <Map<String, dynamic>>[],
        'cvUrl': null,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful.')),
      );
      Navigator.pushReplacementNamed(context, '/buildprofile');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please log in.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password must be at least 6 characters.';
      } else {
        message = e.message ?? 'Registration failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.signup,
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Account', style: AppTextStyles.headline2),
            const SizedBox(height: AppSpacing.verticalSpaceSmall),
            Text(
              'Join our job portal community',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // Name
            CustomTextField(
              controller: name,
              label: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Email
            CustomTextField(
              controller: email,
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

            // Password
            CustomTextField(
              controller: password,
              label: AppStrings.password,
              hintText: 'Enter your password',
              prefixIcon: Icons.lock,
              obscureText: isPasswordHidden,
              suffixIcon: Icons.visibility,
              onSuffixIconPressed: (){
                setState(() {
                  isPasswordHidden = !isPasswordHidden;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            // Confirm Password
            CustomTextField(
              controller: confirmPassword,
              label: AppStrings.confirmPassword,
              hintText: 'Confirm your password',
              prefixIcon: Icons.lock,
              obscureText: isConfirmPasswordHidden,
              suffixIcon: Icons.visibility,
              // showing password on clicking icon
              onSuffixIconPressed: (){

                setState((){
                  isConfirmPasswordHidden = !isConfirmPasswordHidden;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password.';
                }
                if (value != password.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceLarge),

            // SIGNUP BUTTON
            CustomButton(
              text: AppStrings.signup,
              onPressed: () async {
                await register();
              },
            ),
            const SizedBox(height: AppSpacing.verticalSpaceMedium),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodySmall,
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/Login'),
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
      ),
    );
  }
}