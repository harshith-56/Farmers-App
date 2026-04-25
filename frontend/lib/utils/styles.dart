import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyle {
  static BoxDecoration glassCard = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.95),
        Colors.white.withOpacity(0.85),
      ],
    ),
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 25,
        offset: Offset(0, 10),
      )
    ],
  );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 26,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );
}
