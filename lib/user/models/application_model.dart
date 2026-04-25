class JobApplication {
  final String id;
  final String jobId;
  final String userId;
  final String jobTitle;
  final String companyName;
  final String status; // Applied, Under Review, Interview, Rejected, Accepted
  final DateTime appliedDate;
  final String? interviewDate;
  final String? feedback;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.appliedDate,
    this.interviewDate,
    this.feedback,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      userId: json['userId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      status: json['status'] ?? 'Applied',
      appliedDate: json['appliedDate'] != null
          ? DateTime.parse(json['appliedDate'])
          : DateTime.now(),
      interviewDate: json['interviewDate'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'userId': userId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'status': status,
      'appliedDate': appliedDate.toIso8601String(),
      'interviewDate': interviewDate,
      'feedback': feedback,
    };
  }
}
