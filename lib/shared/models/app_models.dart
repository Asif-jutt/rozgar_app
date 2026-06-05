import 'package:cloud_firestore/cloud_firestore.dart';

/// Base model for all domain entities
/// Provides common fields like id, timestamps, and status
abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BaseEntity({required this.id, required this.createdAt, this.updatedAt});

  /// Convert entity to JSON for API calls
  Map<String, dynamic> toJson();

  /// Create entity from Firestore document
  static T fromFirestore<T>(
    DocumentSnapshot doc,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return fromJson({...doc.data() as Map, 'id': doc.id});
  }
}

/// User authentication model
class UserModel extends BaseEntity {
  /// Alias for [BaseEntity.id] used across the app.
  /// Some older code expects `uid`, so we keep it for compatibility.
  final String uid;

  final String email;
  final String fullName;
  final String role; // 'user', 'employer', 'admin'
  final String? phone;
  final String? profileImageUrl;
  final String? bio;
  final bool isVerified;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  UserModel({
    required String id,
    String? uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.profileImageUrl,
    this.bio,
    this.isVerified = false,
    this.isActive = true,
    required DateTime createdAt,
    DateTime? updatedAt,
    this.metadata,
  })  : uid = uid ?? id,
        super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  @override
  Map<String, dynamic> toJson() => {
    'email': email,
    'fullName': fullName,
    'role': role,
    'phone': phone,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'isVerified': isVerified,
    'isActive': isActive,
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: data['role'] ?? 'user',
      phone: data['phone'],
      profileImageUrl: data['profileImageUrl'],
      bio: data['bio'],
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
      metadata: json['metadata'],
    );
  }

  UserModel copyWith({
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? profileImageUrl,
    String? bio,
    bool? isVerified,
    bool? isActive,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Job listing model
class JobModel extends BaseEntity {
  final String title;
  final String description;
  final String company;
  final String companyId;
  final String location;
  final String salary;
  final String jobType; // 'full-time', 'part-time', 'contract', 'internship'
  final List<String> skills;
  final int applicantsCount;
  final bool isActive;
  final String? requiredEducation;
  final String? experience;
  final Map<String, dynamic>? benefits;

  JobModel({
    required String id,
    required this.title,
    required this.description,
    required this.company,
    required this.companyId,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.skills,
    this.applicantsCount = 0,
    this.isActive = true,
    this.requiredEducation,
    this.experience,
    required DateTime createdAt,
    DateTime? updatedAt,
    this.benefits,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'company': company,
    'companyId': companyId,
    'location': location,
    'salary': salary,
    'jobType': jobType,
    'skills': skills,
    'applicantsCount': applicantsCount,
    'isActive': isActive,
    'requiredEducation': requiredEducation,
    'experience': experience,
    'benefits': benefits,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      company: data['company'] ?? '',
      companyId: data['companyId'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
      jobType: data['jobType'] ?? 'full-time',
      skills: List<String>.from(data['skills'] ?? []),
      applicantsCount: data['applicantsCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      requiredEducation: data['requiredEducation'],
      experience: data['experience'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      benefits: data['benefits'],
    );
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      company: json['company'] ?? '',
      companyId: json['companyId'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      jobType: json['jobType'] ?? 'full-time',
      skills: List<String>.from(json['skills'] ?? []),
      applicantsCount: json['applicantsCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      requiredEducation: json['requiredEducation'],
      experience: json['experience'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? ''),
      benefits: json['benefits'],
    );
  }

  JobModel copyWith({
    String? title,
    String? description,
    String? company,
    String? location,
    String? salary,
    String? jobType,
    List<String>? skills,
    int? applicantsCount,
    bool? isActive,
    String? requiredEducation,
    String? experience,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      company: company ?? this.company,
      companyId: companyId,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobType: jobType ?? this.jobType,
      skills: skills ?? this.skills,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      isActive: isActive ?? this.isActive,
      requiredEducation: requiredEducation ?? this.requiredEducation,
      experience: experience ?? this.experience,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Job application model
class ApplicationModel extends BaseEntity {
  final String jobId;
  final String jobTitle;
  final String userId;
  final String company;
  final String
  status; // 'pending', 'reviewed', 'shortlisted', 'rejected', 'accepted'
  final String? coverLetter;
  final List<String>? attachmentUrls;
  final Map<String, dynamic>? score;

  ApplicationModel({
    required String id,
    required this.jobId,
    required this.jobTitle,
    required this.userId,
    required this.company,
    required this.status,
    this.coverLetter,
    this.attachmentUrls,
    required DateTime createdAt,
    DateTime? updatedAt,
    this.score,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  @override
  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'jobTitle': jobTitle,
    'userId': userId,
    'company': company,
    'status': status,
    'coverLetter': coverLetter,
    'attachmentUrls': attachmentUrls,
    'score': score,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      userId: data['userId'] ?? '',
      company: data['company'] ?? '',
      status: data['status'] ?? 'pending',
      coverLetter: data['coverLetter'],
      attachmentUrls: List<String>.from(data['attachmentUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      score: data['score'],
    );
  }

  ApplicationModel copyWith({
    String? status,
    DateTime? updatedAt,
    Map<String, dynamic>? score,
  }) {
    return ApplicationModel(
      id: id,
      jobId: jobId,
      jobTitle: jobTitle,
      userId: userId,
      company: company,
      status: status ?? this.status,
      coverLetter: coverLetter,
      attachmentUrls: attachmentUrls,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      score: score ?? this.score,
    );
  }
}

/// Response wrapper for API calls
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode ?? 500,
    );
  }
}
