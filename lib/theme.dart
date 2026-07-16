import 'package:flutter/material.dart';

/// Tailwind color palette translated to Flutter [Color] values, plus the
/// bespoke brand colors used by the SoloS UI. Mirrors the Tailwind classes
/// used across the original React components so the port stays pixel-faithful.
class AppColors {
  AppColors._();

  // Slate
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);

  // Amber
  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber200 = Color(0xFFFDE68A);
  static const amber300 = Color(0xFFFCD34D);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const amber800 = Color(0xFF92400E);
  static const amber900 = Color(0xFF78350F);

  // Green (SSO badge)
  static const green300 = Color(0xFF86EFAC);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green800 = Color(0xFF166534);
  static const green900 = Color(0xFF14532D);

  // Blue (info callout)
  static const blue50 = Color(0xFFEFF6FF);
  static const blue200 = Color(0xFFBFDBFE);
  static const blue600 = Color(0xFF2563EB);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);

  // Brand-specific
  static const loginBg = Color(0xFFEFE6D5);
  static const loginButton = Color(0xFFD4A373);
  static const loginButtonHover = Color(0xFFC29262);
  static const white = Colors.white;
}
