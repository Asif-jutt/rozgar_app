import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rozgar/user/models/application_model.dart';
import 'package:rozgar/user/models/user_model.dart';

class ApplicantModel {
  final String applicationId;
  final String status;
  final Timestamp? appliedAt;
  final String? resumeUrl;
  final String? coverLetter;
  final String seekerUid;
  final String seekerName;
  final String seekerEmail;
  final String? seekerPhotoUrl;
  final List<String> seekerSkills;
  final String? seekerExperience;

  const ApplicantModel({
    required this.applicationId,
    required this.status,
    this.appliedAt,
    this.resumeUrl,
    this.coverLetter,
    required this.seekerUid,
    required this.seekerName,
    required this.seekerEmail,
    this.seekerPhotoUrl,
    this.seekerSkills = const [],
    this.seekerExperience,
  });

  factory ApplicantModel.fromDocs(
    ApplicationModel app,
    UserModel? user,
  ) {
    return ApplicantModel(
      applicationId: app.id,
      status: app.status,
      appliedAt: app.appliedAt,
      resumeUrl: app.resumeUrl,
      coverLetter: app.coverLetter,
      seekerUid: app.seekerId,
      seekerName: app.seekerName,
      seekerEmail: user?.email ?? '',
      seekerPhotoUrl: app.seekerPhotoUrl ?? user?.photoUrl,
      seekerSkills: user?.skills ?? [],
      seekerExperience: user?.experience,
    );
  }
}
