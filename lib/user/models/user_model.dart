import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/shared/constants/firebase_constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final String? phoneEncrypted;
  final String? cnicEncrypted;
  final String? salaryExpectationEncrypted;
  final String? resumeUrl;
  final String? resumePublicId;
  final List<String> skills;
  final String? experience;
  final String? education;
  final bool isActive;
  final bool isPremium;
  final Timestamp? createdAt;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'jobSeeker',
    this.phoneEncrypted,
    this.cnicEncrypted,
    this.salaryExpectationEncrypted,
    this.resumeUrl,
    this.resumePublicId,
    this.skills = const [],
    this.experience,
    this.education,
    this.isActive = true,
    this.isPremium = false,
    this.createdAt,
    this.fcmToken,
  });

  String? get phone => phoneEncrypted != null
      ? EncryptionHelper.decryptString(phoneEncrypted!)
      : null;
  String? get cnic => cnicEncrypted != null
      ? EncryptionHelper.decryptString(cnicEncrypted!)
      : null;
  String? get salaryExpectation => salaryExpectationEncrypted != null
      ? EncryptionHelper.decryptString(salaryExpectationEncrypted!)
      : null;

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? role,
    String? phone,
    String? cnic,
    String? salaryExpectation,
    String? resumeUrl,
    String? resumePublicId,
    List<String>? skills,
    String? experience,
    String? education,
    bool? isActive,
    bool? isPremium,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      phoneEncrypted: phone != null
          ? EncryptionHelper.encryptString(phone)
          : phoneEncrypted,
      cnicEncrypted: cnic != null
          ? EncryptionHelper.encryptString(cnic)
          : cnicEncrypted,
      salaryExpectationEncrypted: salaryExpectation != null
          ? EncryptionHelper.encryptString(salaryExpectation)
          : salaryExpectationEncrypted,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumePublicId: resumePublicId ?? this.resumePublicId,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: d['email'] as String? ?? '',
      displayName: d['displayName'] as String?,
      photoUrl: d['photoUrl'] as String?,
      role: d['role'] as String? ?? 'jobSeeker',
      phoneEncrypted: d['phoneEncrypted'] as String?,
      cnicEncrypted: d['cnicEncrypted'] as String?,
      salaryExpectationEncrypted: d['salaryExpectationEncrypted'] as String?,
      resumeUrl: d['resumeUrl'] as String?,
      resumePublicId: d['resumePublicId'] as String?,
      skills: List<String>.from(d['skills'] ?? []),
      experience: d['experience'] as String?,
      education: d['education'] as String?,
      isActive: d['isActive'] as bool? ?? true,
      isPremium: d['isPremium'] as bool? ?? false,
      createdAt: d['createdAt'] as Timestamp?,
      fcmToken: d['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'phoneEncrypted': phoneEncrypted,
        'cnicEncrypted': cnicEncrypted,
        'salaryExpectationEncrypted': salaryExpectationEncrypted,
        'resumeUrl': resumeUrl,
        'resumePublicId': resumePublicId,
        'skills': skills,
        'experience': experience,
        'education': education,
        'isActive': isActive,
        'isPremium': isPremium,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
        'fcmToken': fcmToken,
      };

  Map<String, dynamic> toHive() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'isPremium': isPremium,
      };

  factory UserModel.fromHive(Map map) => UserModel(
        uid: map['uid'] as String,
        email: map['email'] as String? ?? '',
        displayName: map['displayName'] as String?,
        role: map['role'] as String? ?? 'jobSeeker',
        isPremium: map['isPremium'] as bool? ?? false,
      );
}
