class Job {
  final String id;
  final String jobTitle;
  final String companyName;
  final String location;
  final String salary;
  final List<String> requiredSkills;
  final String description;
  final DateTime postedDate;
  final String jobType; // Full-time, Part-time, etc.

  Job({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.requiredSkills,
    required this.description,
    required this.postedDate,
    required this.jobType,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      companyName: json['companyName'] ?? '',
      location: json['location'] ?? '',
      salary: json['salary'] ?? '',
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      description: json['description'] ?? '',
      postedDate: json['postedDate'] != null
          ? DateTime.parse(json['postedDate'])
          : DateTime.now(),
      jobType: json['jobType'] ?? 'Full-time',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'location': location,
      'salary': salary,
      'requiredSkills': requiredSkills,
      'description': description,
      'postedDate': postedDate.toIso8601String(),
      'jobType': jobType,
    };
  }
}
