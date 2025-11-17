import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SmartImageWidget extends StatelessWidget {
  final String? cloudUrl;
  final String? localPath;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SmartImageWidget({
    super.key,
    this.cloudUrl,
    this.localPath,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);

    if (cloudUrl != null && cloudUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: CachedNetworkImage(
          imageUrl: cloudUrl!,
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            if (localPath != null) {
              return _buildLocalImage(radius);
            }
            return _buildErrorWidget();
          },
        ),
      );
    }

    if (localPath != null) {
      return _buildLocalImage(radius);
    }

    return _buildErrorWidget();
  }

  Widget _buildLocalImage(BorderRadius radius) {
    final file = File(localPath!);
    
    if (!file.existsSync()) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.broken_image,
        size: width * 0.5,
        color: Colors.grey[400],
      ),
    );
  }
}