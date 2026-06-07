import 'package:firebase_auth/firebase_auth.dart';
import 'package:rozgar/models/app_user.dart';
import 'package:rozgar/services/firestore_service.dart';
import 'package:rozgar/services/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final NotificationService _notifications = NotificationService();

  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _firestore.getUser(user.uid);
    });
  }

  Future<void> _afterAuth(AppUser user) async {
    await _notifications.saveFcmToken(user.uid);
  }

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String userRole,
    String? profileImageUrl,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return null;

      await user.updateDisplayName(fullName);

      final appUser = AppUser(
        uid: user.uid,
        name: fullName,
        email: email,
        userRole: userRole,
        createdAt: DateTime.now(),
        profileImageUrl: profileImageUrl,
      );
      await _firestore.createUser(appUser);
      await _afterAuth(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AppUser?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user == null) return null;
      final appUser = await _firestore.getUser(cred.user!.uid);
      if (appUser != null) await _afterAuth(appUser);
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
