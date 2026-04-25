class UserProfile {
  final String id;
  final String cnic;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final List<String> skills;
  final List<Education> educations;
  final String? cvUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.cnic,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.skills,
    required this.educations,
    this.cvUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      cnic: json['cnic'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      educations:
          (json['educations'] as List?)
              ?.map((e) => Education.fromJson(e))
              .toList() ??
          [],
      cvUrl: json['cvUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cnic': cnic,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'skills': skills,
      'educations': educations.map((e) => e.toJson()).toList(),
      'cvUrl': cvUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Education {
  final String id;
  final String degree;
  final String institution;
  final String? year;

  Education({
    required this.id,
    required this.degree,
    required this.institution,
    this.year,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] ?? '',
      degree: json['degree'] ?? '',
      institution: json['institution'] ?? '',
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'year': year,
    };
  }
}
