/// External job listing from Remotive REST API (non-Firebase source).
class RemoteJob {
  final String id;
  final String title;
  final String company;
  final String category;
  final String location;
  final String url;

  const RemoteJob({
    required this.id,
    required this.title,
    required this.company,
    required this.category,
    required this.location,
    required this.url,
  });

  factory RemoteJob.fromJson(Map<String, dynamic> json) {
    return RemoteJob(
      id: '${json['id'] ?? json['url'] ?? ''}',
      title: json['title']?.toString() ?? 'Remote Job',
      company: json['company_name']?.toString() ?? 'Company',
      category: json['category']?.toString() ?? 'Remote',
      location: json['candidate_required_location']?.toString() ?? 'Remote',
      url: json['url']?.toString() ?? '',
    );
  }
}
