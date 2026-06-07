class UserProfileModel {
  final String userId;
  final String bio;
  final List<String> skills;
  final String education;
  final String experience;
  final String? profileImageUrl;
  final String? cvResumeUrl;

  const UserProfileModel({
    required this.userId,
    required this.bio,
    required this.skills,
    required this.education,
    required this.experience,
    this.profileImageUrl,
    this.cvResumeUrl,
  });

  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return UserProfileModel(
      userId: id,
      bio: map['bio'] ?? map['address'] ?? '',
      skills: map['skills'] is List
          ? List<String>.from(map['skills'])
          : [],
      education: map['education'] is String
          ? map['education']
          : (map['educations'] is List && (map['educations'] as List).isNotEmpty
              ? (map['educations'][0]['degree'] ?? '').toString()
              : ''),
      experience: map['experience'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      cvResumeUrl: map['cvResumeUrl'] ?? map['cvUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bio': bio,
      'skills': skills,
      'education': education,
      'experience': experience,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (cvResumeUrl != null) 'cvResumeUrl': cvResumeUrl,
    };
  }

  UserProfileModel copyWith({
    String? bio,
    List<String>? skills,
    String? education,
    String? experience,
    String? profileImageUrl,
    String? cvResumeUrl,
  }) {
    return UserProfileModel(
      userId: userId,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      cvResumeUrl: cvResumeUrl ?? this.cvResumeUrl,
    );
  }
}
