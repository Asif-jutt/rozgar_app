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
  final List<String> likes;
  final int impressions;
  final int commentsCount;

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
    this.likes = const [],
    this.impressions = 0,
    this.commentsCount = 0,
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
      likes: map['likes'] is List ? List<String>.from(map['likes']) : [],
      impressions: map['impressions'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
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
      'likes': likes,
      'impressions': impressions,
      'commentsCount': commentsCount,
    };
  }

  List<String> get requirementList => requirements
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  JobModel copyWith({
    List<String>? likes,
    int? impressions,
    int? commentsCount,
  }) {
    return JobModel(
      jobId: jobId,
      companyId: companyId,
      title: title,
      description: description,
      salary: salary,
      location: location,
      requirements: requirements,
      category: category,
      companyName: companyName,
      imageUrl: imageUrl,
      postedAt: postedAt,
      likes: likes ?? this.likes,
      impressions: impressions ?? this.impressions,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}