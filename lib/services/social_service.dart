import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/core/logger/app_logger.dart';
import 'package:rozgar/user/models/job_comment.dart';
import 'package:rozgar/services/profiling_service.dart';

class JobEngagement {
  final int likeCount;
  final int commentCount;
  final bool likedByMe;

  const JobEngagement({
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
  });
}

class SocialService {
  SocialService._();
  static final SocialService instance = SocialService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _likeDocId(String jobId, String userId) => '${jobId}_$userId';

  Future<void> toggleLike(String jobId, String userId) async {
    final ref = _db.collection('job_likes').doc(_likeDocId(jobId, userId));
    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
      AppLogger.debug('Like removed: $jobId');
    } else {
      await ref.set({
        'jobId': jobId,
        'userId': userId,
        'createdAt': DateTime.now().toIso8601String(),
      });
      AppLogger.debug('Like added: $jobId');
    }
  }

  Stream<bool> isLikedStream(String jobId, String userId) {
    return _db
        .collection('job_likes')
        .doc(_likeDocId(jobId, userId))
        .snapshots()
        .map((d) => d.exists);
  }

  Stream<int> likeCountStream(String jobId) {
    return _db
        .collection('job_likes')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<List<JobComment>> commentsStream(String jobId) {
    return _db
        .collection('job_comments')
        .where('jobId', isEqualTo: jobId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => JobComment.fromMap(d.id, d.data()))
            .toList());
  }

  Future<void> addComment({
    required String jobId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    await _db.collection('job_comments').add({
      'jobId': jobId,
      'userId': userId,
      'userName': userName,
      'text': text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _db.collection('job_comments').doc(commentId).delete();
  }

  Stream<List<String>> userLikedJobIdsStream(String userId) {
    return _db
        .collection('job_likes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()['jobId'] as String).toList());
  }

  Future<JobEngagement> getEngagement(String jobId, String? userId) async {
    return ProfilingService.instance.trace('social_engagement', () async {
      final likes = await _db
          .collection('job_likes')
          .where('jobId', isEqualTo: jobId)
          .get();
      final comments = await _db
          .collection('job_comments')
          .where('jobId', isEqualTo: jobId)
          .get();
      var liked = false;
      if (userId != null) {
        final mine = await _db
            .collection('job_likes')
            .doc(_likeDocId(jobId, userId))
            .get();
        liked = mine.exists;
      }
      return JobEngagement(
        likeCount: likes.docs.length,
        commentCount: comments.docs.length,
        likedByMe: liked,
      );
    });
  }
}
