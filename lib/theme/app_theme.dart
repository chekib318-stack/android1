import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// هوية بصرية مستوحاة من تونس: أزرق سيدي بوسعيد، بياض الياسمين،
/// أوكر الصحراء، أخضر الزليج، وأحمر الهريسة كلمسة تحفيز نادرة.
/// هذا ليس نظام ألوان Duolingo (أخضر/أبيض قياسي) بل هوية خاصة بالمشروع.
class AppColors {
  AppColors._();

  static const Color sidiBlue = Color(0xFF1F5C78); // الأزرق الأيقوني للأبواب والنوافذ
  static const Color sidiBlueDeep = Color(0xFF123B4D); // ظل أعمق للنصوص/الأزرار الثانوية
  static const Color jasmine = Color(0xFFFCFAF3); // خلفية دافئة، الياسمين التونسي
  static const Color jasmineDim = Color(0xFFF3EEE0); // خلفية بطاقات هادئة
  static const Color ochre = Color(0xFFD98B3F); // أوكر الكثبان، للتحفيز والسلسلة اليومية
  static const Color zellige = Color(0xFF3E7A5C); // أخضر الزليج، للنجاح والإتقان
  static const Color harissa = Color(0xFFC1402E); // أحمر الهريسة، نادر: أخطاء/تنبيه فقط
  static const Color ink = Color(0xFF1C2430); // نص أساسي داكن
  static const Color inkFaint = Color(0xFF6B7580); // نص ثانوي رمادي مزرق
}

class AppTheme {
  AppTheme._();

  static TextTheme get _textTheme => TextTheme(
        // عنوان العرض الكبير: خط "Lalezar" له شخصية ودودة وسميكة، يستعمل بحذر
        displayLarge: GoogleFonts.lalezar(
          fontSize: 40,
          color: AppColors.ink,
          height: 1.15,
        ),
        headlineMedium: GoogleFonts.lalezar(
          fontSize: 26,
          color: AppColors.ink,
        ),
        // نص أساسي: خط "Tajawal" واضح ومريح للقراءة الطويلة
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 17,
          color: AppColors.ink,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 15,
          color: AppColors.inkFaint,
        ),
        // خط الأرقام/الشارات: "Cairo" بأوزان بارزة للعدادات (XP، الأيام...)
        labelLarge: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.jasmine,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.jasmine,
        primaryColor: AppColors.sidiBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.sidiBlue,
          primary: AppColors.sidiBlue,
          secondary: AppColors.ochre,
          tertiary: AppColors.zellige,
          error: AppColors.harissa,
          surface: AppColors.jasmine,
        ),
        textTheme: _textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.jasmine,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.lalezar(
            fontSize: 20,
            color: AppColors.sidiBlueDeep,
          ),
          iconTheme: const IconThemeData(color: AppColors.sidiBlueDeep),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.zellige,
            foregroundColor: AppColors.jasmine,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            elevation: 4,
            shadowColor: AppColors.zellige.withOpacity(0.4),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sidiBlue,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            side: const BorderSide(color: AppColors.sidiBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      );
}
