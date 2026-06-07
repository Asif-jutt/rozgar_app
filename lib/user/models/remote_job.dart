import 'package:rozgar/core/app_images.dart';

/// External job listing from Remotive REST API (non-Firebase source).
class RemoteJob {
  final String id;
  final String title;
  final String company;
  final String category;
  final String location;
  final String url;
  final String description;
  final String salary;
  final String? imageUrl;
  final List<String> tags;

  const RemoteJob({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.location,
    required this.url,
    this.description = '',
    this.salary = 'See listing',
    this.imageUrl,
    this.tags = const [],
  });

  factory RemoteJob.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tags = tagsRaw is List
        ? tagsRaw.map((e) => e.toString()).toList()
        : <String>[];

    return RemoteJob(
      id: '${json['id'] ?? json['url'] ?? ''}',
      title: json['title']?.toString() ?? 'Remote Job',
      company: json['company_name']?.toString() ?? 'Company',
      category: json['category']?.toString() ?? 'Remote',
      location: json['candidate_required_location']?.toString() ?? 'Remote',
      url: json['url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      salary: json['salary']?.toString() ?? 'See listing',
      imageUrl: json['company_logo_url']?.toString() ??
          AppImages.jobImageForCategory(
            json['category']?.toString() ?? 'Remote',
          ),
      tags: tags,
    );
  }
}
