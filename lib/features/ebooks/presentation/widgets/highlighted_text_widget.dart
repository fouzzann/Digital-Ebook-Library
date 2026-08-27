import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final TextStyle highlightStyle;
  final int maxLines;
  final TextOverflow overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.highlightStyle = const TextStyle(
      color: AppColors.accent,
      fontWeight: FontWeight.bold,
      backgroundColor: Color(0x33F59E0B),
    ),
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();
    final List<TextSpan> spans = [];

    int start = 0;
    int index = lowerText.indexOf(lowerQuery, start);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.merge(highlightStyle),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(children: spans),
    );
  }
}
