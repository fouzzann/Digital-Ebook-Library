import 'package:flutter/material.dart';

class AppColors {
  // Deep Futuristic Dark Backgrounds
  static const Color background = Color(0xFF0B0F17); // Darkest Void
  static const Color backgroundSecondary = Color(0xFF111726); // Deep Navy Slate
  
  // Glassmorphic Surface Colors
  static const Color glassSurface = Color(0x2B1E293B); // Semi-transparent glass
  static const Color surface = Color(0xFF131B2E); // Surface slate
  static const Color surfaceLight = Color(0xFF1E293B); // Light slate border/fill
  static const Color cardBackground = Color(0xFF161F33);

  // Electric Neon Accents & Gradients
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color secondary = Color(0xFF06B6D4); // Cyan Cyber
  static const Color accent = Color(0xFFF59E0B); // Amber Glow
  static const Color emerald = Color(0xFF10B981); // Vibrant Emerald Green
  static const Color rose = Color(0xFFF43F5E); // Electric Rose Red

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color border = Color(0x33475569);
  static const Color borderBright = Color(0x666366F1);

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFD946EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x33ffffff),
      Color(0x05ffffff),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0xCC0B0F17),
      Color(0xFF0B0F17),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGlow = LinearGradient(
    colors: [Color(0x336366F1), Color(0x006366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
