import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.border,
    this.borderRadius,
    this.boxShape = BoxShape.rectangle,
    this.backgroundColor,
    this.child,
    this.colorFilter,
  });

  final String imageUrl;
  final double height;
  final double width;
  final Border? border;
  final BorderRadius? borderRadius;
  final BoxShape boxShape;
  final Color? backgroundColor;
  final Widget? child;
  final ColorFilter? colorFilter;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Colors.grey.withValues(alpha: 0.6);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            border: border,
            borderRadius: boxShape == BoxShape.rectangle ? borderRadius : null,
            shape: boxShape,
            color: backgroundColor,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: colorFilter,
            ),
          ),
          child: child,
        );
      },
      placeholder: (context, url) {
        return Shimmer.fromColors(
          baseColor: placeholderColor,
          highlightColor: Colors.grey.withValues(alpha: 0.3),
          child: _ImagePlaceholder(
            height: height,
            width: width,
            border: border,
            borderRadius: borderRadius,
            boxShape: boxShape,
            color: placeholderColor,
          ),
        );
      },
      errorWidget: (context, url, error) {
        return _ImagePlaceholder(
          height: height,
          width: width,
          border: border,
          borderRadius: borderRadius,
          boxShape: boxShape,
          color: placeholderColor,
          child: const Icon(Icons.error),
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.height,
    required this.width,
    required this.border,
    required this.borderRadius,
    required this.boxShape,
    required this.color,
    this.child,
  });

  final double height;
  final double width;
  final Border? border;
  final BorderRadius? borderRadius;
  final BoxShape boxShape;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        border: border,
        color: color,
        borderRadius: boxShape == BoxShape.rectangle ? borderRadius : null,
        shape: boxShape,
      ),
      child: child,
    );
  }
}
