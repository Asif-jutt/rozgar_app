class JobComment {
  final String id;
  final String jobId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const JobComment({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory JobComment.fromMap(String id, Map<String, dynamic> map) {
    return JobComment(
      id: id,
      jobId: map['jobId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'User',
      text: map['text'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'jobId': jobId,
        'userId': userId,
        'userName': userName,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
