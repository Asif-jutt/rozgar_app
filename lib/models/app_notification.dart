class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool read;
  final DateTime createdAt;
  final String? relatedId;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.relatedId,
  });

  factory AppNotification.fromFirestore(String id, Map<String, dynamic> json) {
    return AppNotification(
      id: id,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      relatedId: json['relatedId'],
    );
  }
}
