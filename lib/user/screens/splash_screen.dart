import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirestoreService _firestore = FirestoreService();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final appUser = await _firestore.getUser(firebaseUser.uid);

      if (!mounted) return;

      if (appUser == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      switch (appUser.userRole) {
        case 'seeker':
          Navigator.of(context).pushReplacementNamed('/user_home');
          break;
        case 'company':
          Navigator.of(context).pushReplacementNamed('/company_dashboard');
          break;
        case 'admin':
          Navigator.of(context).pushReplacementNamed('/admin_dashboard');
          break;
        default:
          Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      debugPrint('Splash auth check error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work_outline,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rozgar',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connecting Talent with Opportunity',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

