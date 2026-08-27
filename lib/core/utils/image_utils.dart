import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

Widget buildEbookCoverImage({
  required String coverUrl,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  String? title,
}) {
  if (coverUrl.isEmpty) {
    return _buildStyledCover(title: title, width: width, height: height);
  }

  if (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')) {
    return Image.network(
      coverUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildStyledCover(title: title, width: width, height: height),
    );
  }

  if (!kIsWeb && coverUrl.isNotEmpty) {
    try {
      final file = io.File(coverUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildStyledCover(title: title, width: width, height: height),
        );
      }
    } catch (_) {
      return _buildStyledCover(title: title, width: width, height: height);
    }
  }

  return _buildStyledCover(title: title, width: width, height: height);
}

Widget _buildStyledCover({String? title, double? width, double? height}) {
  return Container(
    width: width,
    height: height,
    padding: const EdgeInsets.all(12),
    decoration: const BoxDecoration(
      gradient: AppColors.primaryGradient,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 32),
        if (title != null && title.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ],
    ),
  );
}
