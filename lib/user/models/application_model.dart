class ApplicationModel {
  final String appId;
  final String jobId;
  final String userId;
  final String companyId;
  final String status;
  final DateTime appliedDate;
  final String resumeText;
  final String? applicantName;
  final String? jobTitle;
  
  // New fields
  final String? university;
  final String? semester;
  final String? email;
  final String? phone;

  const ApplicationModel({
    required this.appId,
    required this.jobId,
    required this.userId,
    required this.companyId,
    required this.status,
    required this.appliedDate,
    required this.resumeText,
    this.applicantName,
    this.jobTitle,
    this.university,
    this.semester,
    this.email,
    this.phone,
  });

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplicationModel(
      appId: id,
      jobId: map['jobId'] ?? '',
      userId: map['userId'] ?? '',
      companyId: map['companyId'] ?? '',
      status: map['status'] ?? 'Pending',
      appliedDate: _parseDate(map['appliedDate']),
      resumeText: map['resumeText'] ?? map['resumeUrl'] ?? '',
      applicantName: map['applicantName'],
      jobTitle: map['jobTitle'],
      university: map['university'],
      semester: map['semester'],
      email: map['email'],
      phone: map['phone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appId': appId,
      'jobId': jobId,
      'userId': userId,
      'companyId': companyId,
      'status': status,
      'appliedDate': appliedDate.toIso8601String(),
      'resumeText': resumeText,
      if (applicantName != null) 'applicantName': applicantName,
      if (jobTitle != null) 'jobTitle': jobTitle,
      if (university != null) 'university': university,
      if (semester != null) 'semester': semester,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
