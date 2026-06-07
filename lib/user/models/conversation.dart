class Conversation {
  final String id;
  final List<String> participantIds;
  final String seekerId;
  final String companyId;
  final String seekerName;
  final String companyName;
  final String? jobId;
  final String? jobTitle;
  final String lastMessage;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.participantIds,
    required this.seekerId,
    required this.companyId,
    required this.seekerName,
    required this.companyName,
    this.jobId,
    this.jobTitle,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      participantIds: map['participantIds'] is List
          ? List<String>.from(map['participantIds'])
          : [],
      seekerId: map['seekerId'] ?? '',
      companyId: map['companyId'] ?? '',
      seekerName: map['seekerName'] ?? 'Seeker',
      companyName: map['companyName'] ?? 'Company',
      jobId: map['jobId'],
      jobTitle: map['jobTitle'],
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String displayNameFor(String currentUserId) =>
      currentUserId == seekerId ? companyName : seekerName;
}
