class JobModel {
  final String jobId;
  final String companyId;
  final String title;
  final String description;
  final String salary;
  final String location;
  final String requirements;
  final String category;
  final String? companyName;
  final String? imageUrl;
  final DateTime? postedAt;

  const JobModel({
    required this.jobId,
    required this.companyId,
    required this.title,
    required this.description,
    required this.salary,
    required this.location,
    required this.requirements,
    required this.category,
    this.companyName,
    this.imageUrl,
    this.postedAt,
  });

  factory JobModel.fromMap(String id, Map<String, dynamic> map) {
    return JobModel(
      jobId: id,
      companyId: map['companyId'] ?? '',
      title: map['title'] ?? map['jobTitle'] ?? '',
      description: map['description'] ?? '',
      salary: map['salary'] ?? 'Negotiable',
      location: map['location'] ?? '',
      requirements: map['requirements'] is List
          ? (map['requirements'] as List).join(', ')
          : (map['requiredSkills'] is List
              ? (map['requiredSkills'] as List).join(', ')
              : (map['requirements'] ?? '').toString()),
      category: map['category'] ?? map['jobType'] ?? 'General',
      companyName: map['companyName'],
      imageUrl: map['imageUrl'],
      postedAt: map['postedAt'] != null
          ? DateTime.tryParse(map['postedAt'].toString())
          : (map['postedDate'] != null
              ? DateTime.tryParse(map['postedDate'].toString())
              : null),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'companyId': companyId,
      'title': title,
      'description': description,
      'salary': salary,
      'location': location,
      'requirements': requirements,
      'category': category,
      if (companyName != null) 'companyName': companyName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'postedAt': (postedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  List<String> get requirementList => requirements
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}
