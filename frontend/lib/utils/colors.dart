import 'package:flutter/material.dart';

class AppColors {
  static Color primary = Color(0xff2E7D32);

  static Color secondary = Color(0xff66BB6A);

  static Color bg = Color(0xffF1F8E9);

  static Gradient mainGradient = LinearGradient(
    colors: [
      Color(0xff2E7D32),
      Color(0xff66BB6A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
