import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_clean_calendar/generated/assets.dart';
import 'package:shimmer/shimmer.dart';

class CachedNetworkImageItem extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final BoxFit? boxFit;

  const CachedNetworkImageItem(
    this.imageUrl, {
    super.key,
    this.radius = 10,
    this.boxFit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
          imageUrl: imageUrl,
          errorWidget: (context, url, error) {
            return Image.asset(
              Assets.assetsPlaceholderImage,
              fit: boxFit ?? BoxFit.contain,
            );
          },
          filterQuality: FilterQuality.medium,
          fit: boxFit ?? BoxFit.contain,
          placeholder: (context, url) {
            // return Image.asset(Assets.imagesPlaceholderImage);
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                color: Colors.white,
              ),
            );
          }),
    );
  }
}
