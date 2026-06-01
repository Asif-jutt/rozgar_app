import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/user/providers/firestore_service.dart';
import 'package:rozgar/user/constants/app_constants.dart';

class JobCommentsSection extends StatefulWidget {
  final String jobId;
  final bool isCompany;

  const JobCommentsSection({
    super.key,
    required this.jobId,
    required this.isCompany,
  });

  @override
  State<JobCommentsSection> createState() => _JobCommentsSectionState();
}

class _JobCommentsSectionState extends State<JobCommentsSection> {
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _commentController = TextEditingController();

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await _firestore.getUser(user.uid);
    String userName = doc?.name ?? 'Unknown User';

    await _firestore.addJobComment(widget.jobId, user.uid, userName, text);
    _commentController.clear();
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comments', style: AppTextStyles.headline3),
        const SizedBox(height: 16),
        if (!widget.isCompany)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primaryColor),
                onPressed: _postComment,
              ),
            ],
          ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: _firestore.getJobComments(widget.jobId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Text('No comments yet.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      data['userName'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(data['text'] ?? ''),
                    trailing: Text(
                      _formatTime(data['timestamp'] as Timestamp?),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
