import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/constants/app_strings.dart';
import 'package:rozgar/user/providers/auth_provider.dart';
import 'package:rozgar/user/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    AppLogger.i('NAV: LoginScreen');
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthProvider.to;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.work, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                Text(AppStrings.welcomeBack,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                    filled: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => auth.resetPassword(_email.text),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                Obx(() {
                  if (auth.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Text(auth.errorMessage.value,
                      style: const TextStyle(color: Colors.red));
                }),
                const SizedBox(height: 16),
                Obx(() => CustomButton(
                      label: AppStrings.signIn,
                      isLoading: auth.isLoading.value,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          auth.signInWithEmail(_email.text, _password.text);
                        }
                      },
                    )),
                const SizedBox(height: 16),
                const Row(children: [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('OR')),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: auth.signInWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continue with Google'),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: const Text(AppStrings.noAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
