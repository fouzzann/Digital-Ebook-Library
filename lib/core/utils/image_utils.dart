import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

Widget buildEbookCoverImage({
  required String coverUrl,
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (coverUrl.isEmpty) {
    return _buildFallback();
  }

  if (coverUrl.startsWith('http://') || coverUrl.startsWith('https://')) {
    return Image.network(
      coverUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
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
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    } catch (_) {
      return _buildFallback();
    }
  }

  return _buildFallback();
}

Widget _buildFallback() {
  return Container(
    color: AppColors.surfaceLight,
    child: const Center(
      child: Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 36),
    ),
  );
}
