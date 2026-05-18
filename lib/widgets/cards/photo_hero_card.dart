import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/constants.dart';

/// Full-bleed photo card with bottom gradient overlay + content slots.
class PhotoHeroCard extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double radius;
  final Widget? topRight;
  final Widget? bottomContent;
  final VoidCallback? onTap;

  const PhotoHeroCard({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.radius = kRadius,
    this.topRight,
    this.bottomContent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: kBgTertiary,
                  highlightColor: Colors.white,
                  child: Container(color: kBgTertiary),
                ),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: kBgTertiary,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: kTextMuted, size: 40),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(165),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              // Top-right slot
              if (topRight != null)
                Positioned(top: 14, right: 14, child: topRight!),
              // Bottom content slot
              if (bottomContent != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: bottomContent!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
