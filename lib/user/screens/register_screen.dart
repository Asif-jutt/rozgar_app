import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:rozgar/user/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _role = 'jobSeeker';

  @override
  void initState() {
    super.initState();
    AppLogger.i('NAV: RegisterScreen');
    final args = Get.arguments;
    if (args is String) _role = args;
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthProvider.to;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.signUp)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: AppStrings.fullName,
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: Icon(Icons.email_outlined),
                  filled: true,
                ),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.password,
                  prefixIcon: Icon(Icons.lock_outlined),
                  filled: true,
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: AppStrings.confirmPassword,
                  prefixIcon: Icon(Icons.lock_outlined),
                  filled: true,
                ),
                validator: (v) => v != _password.text ? 'Passwords must match' : null,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomButton(
                    label: AppStrings.signUp,
                    isLoading: auth.isLoading.value,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        auth.signUpWithEmail(
                          _email.text,
                          _password.text,
                          _name.text,
                          _role,
                        );
                      }
                    },
                  )),
              TextButton(
                onPressed: () => Get.offNamed(AppRoutes.login),
                child: const Text(AppStrings.hasAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
