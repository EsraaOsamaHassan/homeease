import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFFFF3EA);
  static const terracotta = Color(0xFFC8643C);
  static const navy = Color(0xFF1F3A4D);
  static const textDark = Color(0xFF1F2A33);
  static const muted = Color(0xFF7A6F69);
  static const border = Color(0xFFF0DFD2);
  static const peach = Color(0xFFFBE4D6);
  static const tile = Color(0xFFFCEBDF);
  static const beige = Color(0xFFF4E6DA);
  static const blueSoft = Color(0xFFE3EEF8);
  static const yellowSoft = Color(0xFFFCF0D6);
  static const greenSoft = Color(0xFFE2F1E5);
  static const green = Color(0xFF2E7D4F);
  static const redSoft = Color(0xFFFBE1DC);
  static const red = Color(0xFFB3392B);
  static const star = Color(0xFFF2A93B);
  static const disabled = Color(0xFFD9C7BA);
}

class AppText {
  static const eyebrow = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: AppColors.terracotta,
      letterSpacing: 0.3);
  static const h1 = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w800,
      color: AppColors.navy,
      height: 1.25);
  static const h2 = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy);
  static const body =
      TextStyle(fontSize: 13, color: AppColors.muted, height: 1.55);
  static const label = TextStyle(
      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.navy);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      primary: AppColors.terracotta,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

OutlineInputBorder _border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c),
    );

InputDecoration fieldDecoration({String? hint, Widget? prefix, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: _border(AppColors.border),
    enabledBorder: _border(AppColors.border),
    focusedBorder: _border(AppColors.terracotta),
  );
}
