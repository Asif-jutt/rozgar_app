class AdminUser {
  final String id;
  final String adminName;
  final String email;
  final String phoneNumber;
  final String role; // 'super_admin', 'moderator'
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastLogin;

  AdminUser({
    required this.id,
    required this.adminName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.permissions,
    required this.createdAt,
    this.lastLogin,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      adminName: json['adminName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'moderator',
      permissions: List<String>.from(json['permissions'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminName': adminName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'permissions': permissions,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
