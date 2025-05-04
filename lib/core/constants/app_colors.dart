import 'package:flutter/material.dart';

class AppColors {
  static const primaryDark = Color(0xFF1A237E);  // Dark Navy Blue
  static const primary = Color(0xFF283593);      // Navy Blue
  static const primaryLight = Color(0xFF3949AB);  // Light Navy Blue
  
  static const background = Colors.white;
  static const error = Color(0xFFD32F2F);
  static const text = Color(0xFF212121);
  static const textLight = Color(0xFF757575);
  
  static const gradientStart = Color(0xFF1A237E);
  static const gradientEnd = Color(0xFF3949AB);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}