import 'package:flutter/material.dart';

class JobBannerImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final String? category;

  const JobBannerImage({
    super.key,
    this.imageUrl,
    this.width = double.infinity,
    this.height = 120,
    this.fit = BoxFit.cover,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work, size: 50, color: Colors.grey),
            if (category != null) Text(category!, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage(imageUrl!)
          : null,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? (fallbackText != null && fallbackText!.isNotEmpty 
              ? Text(fallbackText![0].toUpperCase(), style: TextStyle(fontSize: radius * 0.8)) 
              : Icon(Icons.person, size: radius, color: Colors.grey))
          : null,
    );
  }
}
