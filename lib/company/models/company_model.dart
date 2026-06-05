import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel {
  final String id;
  final String name;
  final String? logoUrl;
  final String? logoPublicId;
  final String? website;
  final String? industry;
  final String size;
  final String? description;
  final String employerId;
  final bool isVerified;
  final Timestamp? createdAt;

  const CompanyModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.logoPublicId,
    this.website,
    this.industry,
    this.size = '1-10',
    this.description,
    required this.employerId,
    this.isVerified = false,
    this.createdAt,
  });

  factory CompanyModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return CompanyModel(
      id: doc.id,
      name: d['name'] as String? ?? '',
      logoUrl: d['logoUrl'] as String?,
      logoPublicId: d['logoPublicId'] as String?,
      website: d['website'] as String?,
      industry: d['industry'] as String?,
      size: d['size'] as String? ?? '1-10',
      description: d['description'] as String?,
      employerId: d['employerId'] as String? ?? doc.id,
      isVerified: d['isVerified'] as bool? ?? false,
      createdAt: d['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'logoUrl': logoUrl,
        'logoPublicId': logoPublicId,
        'website': website,
        'industry': industry,
        'size': size,
        'description': description,
        'employerId': employerId,
        'isVerified': isVerified,
        'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      };

  CompanyModel copyWith({
    String? name,
    String? logoUrl,
    String? logoPublicId,
    String? website,
    String? industry,
    String? size,
    String? description,
  }) =>
      CompanyModel(
        id: id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        logoPublicId: logoPublicId ?? this.logoPublicId,
        website: website ?? this.website,
        industry: industry ?? this.industry,
        size: size ?? this.size,
        description: description ?? this.description,
        employerId: employerId,
        isVerified: isVerified,
        createdAt: createdAt,
      );
}
