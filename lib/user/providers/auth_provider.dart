export 'user_auth_provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/providers/notification_service.dart';
import 'package:rozgar/user/constants/app_routes.dart';
import 'package:rozgar/user/models/user_model.dart';

class AuthProvider extends GetxController {
  static AuthProvider get to => Get.find();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  GoogleSignIn? _googleSignIn;

  /// Whether Google Sign-In is configured for the current platform.
  bool get isGoogleSignInAvailable {
    if (!kIsWeb) return true;
    final clientId = _googleWebClientId;
    return clientId != null &&
        clientId.isNotEmpty &&
        !clientId.startsWith('your_');
  }

  String? get _googleWebClientId =>
      dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? dotenv.env['GOOGLE_CLIENT_ID'];

  GoogleSignIn get _googleSignInInstance {
    _googleSignIn ??= GoogleSignIn(
      clientId: kIsWeb ? _googleWebClientId : null,
    );
    return _googleSignIn!;
  }

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    try {
      if (firebaseUser == null) {
        currentUser.value = null;
        AppLogger.currentRole = 'USER';
        AppLogger.i('Auth state: signed out');
        if (Get.currentRoute != AppRoutes.login &&
            Get.currentRoute != AppRoutes.onboarding &&
            Get.currentRoute != AppRoutes.register &&
            Get.currentRoute != AppRoutes.roleSelect &&
            Get.currentRoute != AppRoutes.splash) {
          Get.offAllNamed(AppRoutes.login);
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(firebaseUser.uid)
          .get();
      FirestoreReadCounter.increment();

      if (!doc.exists) {
        currentUser.value = null;
        Get.offAllNamed(AppRoutes.roleSelect);
        return;
      }

      final user = UserModel.fromFirestore(doc);
      currentUser.value = user;
      AppLogger.currentRole = user.role;
      AppLogger.i('Auth state: signed in as ${user.role}');

      switch (user.role) {
        case 'employer':
          if (Get.currentRoute != AppRoutes.companyHome) {
            Get.offAllNamed(AppRoutes.companyHome);
          }
        case 'admin':
          if (Get.currentRoute != AppRoutes.adminDashboard) {
            Get.offAllNamed(AppRoutes.adminDashboard);
          }
        default:
          if (Get.currentRoute != AppRoutes.userFeed) {
            Get.offAllNamed(AppRoutes.userFeed);
          }
      }
    } catch (e, st) {
      AppLogger.e('Auth state change error', st);
      errorMessage.value = 'Failed to load user profile. Please try again.';
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _friendlyAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
    String role,
  ) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      final token = await NotificationService.instance.getToken();
      final user = UserModel(
        uid: cred.user!.uid,
        email: email.trim(),
        displayName: name,
        role: role,
        fcmToken: token,
      );
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(user.uid)
          .set(user.toFirestore());
      currentUser.value = user;
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _friendlyAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    if (!isGoogleSignInAvailable) {
      errorMessage.value =
          'Google Sign-In is not configured for web. Use email and password.';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final googleUser = await _googleSignInInstance.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final doc = await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(cred.user!.uid)
          .get();
      FirestoreReadCounter.increment();
      if (!doc.exists) {
        Get.offAllNamed(AppRoutes.roleSelect);
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = _friendlyAuthError(e);
    } catch (e) {
      AppLogger.e('Google sign-in error', StackTrace.current);
      errorMessage.value = 'Google Sign-In failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (isGoogleSignInAvailable) {
      await _googleSignInInstance.signOut();
    }
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> saveUserRole(String role) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    isLoading.value = true;
    try {
      final token = await NotificationService.instance.getToken();
      final fbUser = FirebaseAuth.instance.currentUser!;
      final user = UserModel(
        uid: uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName,
        photoUrl: fbUser.photoURL,
        role: role,
        fcmToken: token,
      );
      await FirebaseFirestore.instance
          .collection(FirebaseCollections.users)
          .doc(uid)
          .set(user.toFirestore());
      currentUser.value = user;
      AppLogger.currentRole = role;
      switch (role) {
        case 'employer':
          Get.offAllNamed(AppRoutes.companyHome);
        case 'admin':
          Get.offAllNamed(AppRoutes.adminDashboard);
        default:
          Get.offAllNamed(AppRoutes.userFeed);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      Get.snackbar('Email Sent', 'Check your inbox for reset link');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', _friendlyAuthError(e));
    }
  }

  bool isAdminEmail(String email) {
    final domain = dotenv.env['ADMIN_EMAIL_DOMAIN'] ?? '@rozgar.admin';
    return email.endsWith(domain);
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
