import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/models/app_models.dart';
import 'package:rozgar/shared/services/firestore_service.dart';
import 'package:rozgar/shared/services/secure_storage_service.dart';

/// Authentication provider for job seeker users
/// Handles login, registration, password reset, and user state management
class UserAuthProvider extends GetxController {
  static UserAuthProvider get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  /// Current authenticated user
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Loading state
  RxBool isLoading = false.obs;

  /// Error message
  RxString errorMessage = ''.obs;

  /// Password visibility toggle
  RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAuthListener();
  }

  /// Initializes authentication state listener
  void _initAuthListener() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        currentUser.value = null;
      }
    });
  }

  /// Loads user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      final data = await _firestore.readDocument(
        collection: FirebaseCollections.users,
        docId: userId,
      );

      if (data != null) {
        currentUser.value = UserModel.fromJson({...data, 'id': userId});
        AppLogger.currentRole = currentUser.value?.role ?? 'USER';
        AppLogger.i('User data loaded: ${currentUser.value?.fullName}');
      }
    } catch (e, st) {
      AppLogger.e('Error loading user data', st);
    }
  }

  /// Registers a new job seeker user
  /// [email]: User email
  /// [password]: User password
  /// [fullName]: User full name
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create Firestore user document
      await _firestore.createDocument(
        collection: FirebaseCollections.users,
        docId: userCredential.user!.uid,
        data: {
          'email': email,
          'fullName': fullName,
          'role': 'user',
          'isVerified': false,
          'isActive': true,
          'phone': null,
          'profileImageUrl': null,
          'bio': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // Save credentials securely
      await SecureStorageService.saveCredentials(
        email: email,
        password: password,
      );

      // Track signup event (analytics removed due to dependency constraints)
      AppLogger.i('Signup tracked (email)');

      AppLogger.i('User registered successfully: $email');
      return true;
    } on FirebaseAuthException catch (e, st) {
      _handleAuthException(e);
      AppLogger.e('Registration error', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs in a user with email and password
  /// [email]: User email
  /// [password]: User password
  /// [rememberMe]: Whether to save credentials
  Future<bool> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (rememberMe) {
        await SecureStorageService.saveCredentials(
          email: email,
          password: password,
        );
      }

      // Track login event (analytics removed due to dependency constraints)
      AppLogger.i('Login tracked (email)');

      AppLogger.i('User logged in: $email');
      return true;
    } on FirebaseAuthException catch (e, st) {
      _handleAuthException(e);
      AppLogger.e('Login error', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Sends password reset email
  /// [email]: User email
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.sendPasswordResetEmail(email: email);

      AppLogger.i('Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e, st) {
      _handleAuthException(e);
      AppLogger.e('Password reset error', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates user profile
  /// [fullName]: Updated full name
  /// [phone]: Updated phone number
  /// [bio]: Updated bio
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? bio,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;

      await _firestore.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: updates,
      );

      // Update local user
      currentUser.value = currentUser.value?.copyWith(
        fullName: fullName ?? currentUser.value?.fullName,
        phone: phone ?? currentUser.value?.phone,
        bio: bio ?? currentUser.value?.bio,
        updatedAt: DateTime.now(),
      );

      AppLogger.i('User profile updated');
      return true;
    } catch (e, st) {
      AppLogger.e('Error updating profile', st);
      errorMessage.value = 'Failed to update profile';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Uploads profile image
  /// [imageUrl]: URL of uploaded image
  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      isLoading.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore.updateDocument(
        collection: FirebaseCollections.users,
        docId: userId,
        data: {'profileImageUrl': imageUrl},
      );

      currentUser.value = currentUser.value?.copyWith(
        profileImageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      AppLogger.i('Profile image updated');
      return true;
    } catch (e, st) {
      AppLogger.e('Error updating profile image', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs out the current user
  Future<bool> logout() async {
    try {
      isLoading.value = true;

      await _auth.signOut();
      currentUser.value = null;
      await SecureStorageService.removeAuthToken();

      AppLogger.i('User logged out');
      return true;
    } catch (e, st) {
      AppLogger.e('Error logging out', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes user account
  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Delete Firestore user document
      await _firestore.deleteDocument(
        collection: FirebaseCollections.users,
        docId: userId,
      );

      // Delete Firebase Auth user
      await _auth.currentUser?.delete();

      currentUser.value = null;
      AppLogger.i('User account deleted');
      return true;
    } on FirebaseAuthException catch (e, st) {
      errorMessage.value = 'Failed to delete account';
      AppLogger.e('Error deleting account', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles Firebase Auth exceptions and sets user-friendly error messages
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value = 'User not found. Please register first.';
      case 'wrong-password':
        errorMessage.value = 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        errorMessage.value = 'This email is already registered.';
      case 'weak-password':
        errorMessage.value = 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        errorMessage.value = 'Invalid email address.';
      case 'operation-not-allowed':
        errorMessage.value = 'This operation is not allowed.';
      case 'too-many-requests':
        errorMessage.value = 'Too many attempts. Please try later.';
      default:
        errorMessage.value = 'Authentication failed: ${e.message}';
    }
  }

  /// Checks if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Gets current user email
  String? get currentEmail => _auth.currentUser?.email;

  /// Toggles password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}
