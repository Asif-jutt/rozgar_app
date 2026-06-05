import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';
import 'package:rozgar/shared/services/firestore_service.dart';

/// Admin user model
class AdminModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'moderator', 'admin', 'super_admin'
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? notes;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.notes,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'moderator',
      permissions: List<String>.from(json['permissions'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      notes: json['notes'],
    );
  }

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'moderator',
      permissions: List<String>.from(data['permissions'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'name': name,
    'role': role,
    'permissions': permissions,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
    'notes': notes,
  };

  bool hasPermission(String permission) {
    return permissions.contains(permission) || role == 'super_admin';
  }

  AdminModel copyWith({
    String? email,
    String? name,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? lastLogin,
    String? notes,
  }) {
    return AdminModel(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      notes: notes ?? this.notes,
    );
  }
}

/// Authentication provider for administrators
/// Handles admin login, permissions, and system management
class AdminAuthProvider extends GetxController {
  static AdminAuthProvider get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  /// Current admin profile
  Rx<AdminModel?> currentAdmin = Rx<AdminModel?>(null);

  /// Loading state
  RxBool isLoading = false.obs;

  /// Error message
  RxString errorMessage = ''.obs;

  /// List of all admins
  RxList<AdminModel> admins = <AdminModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initAuthListener();
  }

  /// Initializes authentication state listener
  void _initAuthListener() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadAdminData(user.uid);
      } else {
        currentAdmin.value = null;
      }
    });
  }

  /// Loads admin data from Firestore
  Future<void> _loadAdminData(String userId) async {
    try {
      final data = await _firestore.readDocument(
        collection: 'admins',
        docId: userId,
      );

      if (data != null) {
        currentAdmin.value = AdminModel.fromJson({...data, 'id': userId});
        AppLogger.currentRole = 'ADMIN';
        AppLogger.i('Admin loaded: ${currentAdmin.value?.name}');
      }
    } catch (e, st) {
      AppLogger.e('Error loading admin data', st);
    }
  }

  /// Logs in an admin
  /// [email]: Admin email
  /// [password]: Admin password
  Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify admin role
      final data = await _firestore.readDocument(
        collection: 'admins',
        docId: userCredential.user!.uid,
      );

      if (data == null) {
        throw Exception('Admin profile not found');
      }

      // Update last login
      await _firestore.updateDocument(
        collection: 'admins',
        docId: userCredential.user!.uid,
        data: {'lastLogin': FieldValue.serverTimestamp()},
      );

      // Track admin login (analytics removed due to dependency constraints)
      AppLogger.i('Admin login tracked');

      AppLogger.i('Admin logged in: $email');
      return true;
    } on FirebaseAuthException catch (e, st) {
      _handleAuthException(e);
      AppLogger.e('Admin login error', st);
      return false;
    } catch (e, st) {
      errorMessage.value = 'Admin authentication failed';
      AppLogger.e('Admin login error', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads all admins (super admin only)
  Future<bool> loadAllAdmins() async {
    try {
      if (!_hasPermission('manage_admins')) {
        throw Exception('Insufficient permissions');
      }

      final docs = await _firestore.queryDocuments(
        collection: 'admins',
        filters: QueryFilters()..addEquals('isActive', true),
      );

      admins.value = docs
          .map((doc) => AdminModel.fromJson({...doc, 'id': doc['id']}))
          .toList();
      AppLogger.i('Loaded ${admins.length} admins');
      return true;
    } catch (e, st) {
      AppLogger.e('Error loading admins', st);
      return false;
    }
  }

  /// Creates a new admin (super admin only)
  /// [email]: Admin email
  /// [password]: Admin password
  /// [name]: Admin name
  /// [role]: Admin role
  /// [permissions]: Admin permissions
  Future<bool> createAdmin({
    required String email,
    required String password,
    required String name,
    required String role,
    required List<String> permissions,
  }) async {
    try {
      if (!_hasPermission('manage_admins')) {
        throw Exception('Insufficient permissions');
      }

      isLoading.value = true;

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin document
      await _firestore.createDocument(
        collection: 'admins',
        docId: userCredential.user!.uid,
        data: {
          'email': email,
          'name': name,
          'role': role,
          'permissions': permissions,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      AppLogger.i('Admin created: $name ($email)');
      return true;
    } on FirebaseAuthException catch (e, st) {
      _handleAuthException(e);
      AppLogger.e('Error creating admin', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates admin permissions (super admin only)
  /// [adminId]: Admin ID to update
  /// [permissions]: New permissions list
  Future<bool> updateAdminPermissions({
    required String adminId,
    required List<String> permissions,
  }) async {
    try {
      if (!_hasPermission('manage_admins')) {
        throw Exception('Insufficient permissions');
      }

      await _firestore.updateDocument(
        collection: 'admins',
        docId: adminId,
        data: {'permissions': permissions},
      );

      AppLogger.i('Admin permissions updated: $adminId');
      return true;
    } catch (e, st) {
      AppLogger.e('Error updating admin permissions', st);
      return false;
    }
  }

  /// Disables an admin account (super admin only)
  /// [adminId]: Admin ID to disable
  Future<bool> disableAdmin(String adminId) async {
    try {
      if (!_hasPermission('manage_admins')) {
        throw Exception('Insufficient permissions');
      }

      await _firestore.updateDocument(
        collection: 'admins',
        docId: adminId,
        data: {'isActive': false},
      );

      AppLogger.i('Admin disabled: $adminId');
      return true;
    } catch (e, st) {
      AppLogger.e('Error disabling admin', st);
      return false;
    }
  }

  /// Logs out the admin
  Future<bool> logout() async {
    try {
      isLoading.value = true;

      await _auth.signOut();
      currentAdmin.value = null;

      AppLogger.i('Admin logged out');
      return true;
    } catch (e, st) {
      AppLogger.e('Error logging out', st);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Checks if current admin has a specific permission
  bool _hasPermission(String permission) {
    return currentAdmin.value?.hasPermission(permission) ?? false;
  }

  /// Handles Firebase Auth exceptions
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value = 'Admin account not found.';
      case 'wrong-password':
        errorMessage.value = 'Incorrect password.';
      case 'user-disabled':
        errorMessage.value = 'This admin account has been disabled.';
      default:
        errorMessage.value = 'Authentication failed: ${e.message}';
    }
  }

  /// Checks if admin is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Checks if current admin is super admin
  bool get isSuperAdmin => currentAdmin.value?.role == 'super_admin';

  /// Gets current admin email
  String? get currentEmail => _auth.currentUser?.email;
}
