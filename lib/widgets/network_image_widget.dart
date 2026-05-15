import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rozgar/core/app_images.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackText;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 28,
    this.fallbackText = 'U',
  });

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!
        : AppImages.defaultAvatar;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => _fallback(),
          errorWidget: (_, __, ___) => _fallback(),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: const Color(0xFF0D47A1),
      alignment: Alignment.center,
      child: Text(
        fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}

class JobBannerImage extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final double height;

  const JobBannerImage({
    super.key,
    this.imageUrl,
    this.category = 'General',
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!
        : AppImages.jobImageForCategory(category);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: height,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: Colors.grey.shade300,
          child: const Icon(Icons.work, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}
