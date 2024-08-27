import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CustomVideoThumbnail extends StatefulWidget {
  final String videoUrl;
  final double height;
  final double width;

  const CustomVideoThumbnail({
    Key? key,
    required this.videoUrl,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  _CustomVideoThumbnailState createState() => _CustomVideoThumbnailState();
}

class _CustomVideoThumbnailState extends State<CustomVideoThumbnail> {
  static final Map<String, Uint8List?> _thumbnailCache = {};
  static const int maxCacheSize = 100; // Maximum number of thumbnails to cache

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _getVideoThumbnail(widget.videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              height: widget.height,
              width: widget.width,
            );
          } else {
            return _buildErrorPlaceholder();
          }
        } else {
          return _buildLoadingPlaceholder();
        }
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey,
      child: const Center(child: Text('')),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey,
      child: const Center(child: Icon(Icons.error, color: Colors.red)),
    );
  }

  Future<Uint8List?> _getVideoThumbnail(String videoUrl) async {
    if (_thumbnailCache.containsKey(videoUrl)) {
      return _thumbnailCache[videoUrl];
    }

    if (_thumbnailCache.length >= maxCacheSize) {
      // Remove the oldest entry to free up space
      String oldestKey = _thumbnailCache.keys.first;
      _thumbnailCache.remove(oldestKey);
    }

    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxHeight: (widget.height * 1.5).toInt(), // Further reduced dimensions
        maxWidth: (widget.width * 1.5).toInt(), // Further reduced dimensions
        quality: 50, // Reduced quality for faster generation
      );

      if (uint8list != null) {
        _thumbnailCache[videoUrl] = uint8list;
        return uint8list;
      } else {
        return null;
      }
    } catch (e) {
      print("Error generating thumbnail for $videoUrl: $e");
      return null;
    }
  }
}
