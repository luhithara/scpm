import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color navy = Color(0xFF172B4D);
  static const Color blue = Color(0xFF3268B2);
  static const Color teal = Color(0xFF259B83);
  static const Color orange = Color(0xFFE39A36);
  static const Color purple = Color(0xFF8063B7);
  static const Color red = Color(0xFFD64545);
  static const Color bg = Color(0xFFF4F6FA);
  static const Color grey = Color(0xFF6B778C);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: bg,
      );
}
