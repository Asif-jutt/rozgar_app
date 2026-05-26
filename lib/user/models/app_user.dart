class AppUser {
  final String uid;
  final String name;
  final String email;
  final String userRole;
  final DateTime createdAt;
  final String? profileImageUrl;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.userRole,
    required this.createdAt,
    this.profileImageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? map['displayName'] ?? '',
      email: map['email'] ?? '',
      userRole: map['userRole'] ?? 'seeker',
      createdAt: _parseDate(map['createdAt']),
      profileImageUrl: map['profileImageUrl'] ?? map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'userRole': userRole,
      'createdAt': createdAt.toIso8601String(),
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
