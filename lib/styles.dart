import 'package:flutter/material.dart';

class AppStyles {
  static const skyGradientLight = [Color(0xFF3B82F6), Color(0xFF93C5FD)];
  static const textMainLight = Color(0xFF1E293B);
  static const accentColor = Color(0xFF2563EB);

  static const skyGradientDark = [Color(0xFF0F172A), Color(0xFF334155)];
  static const textMainDark = Color(0xFFF8FAFC);
  static const accentColorDark = Color(0xFF38BDF8);

  static LinearGradient getSkyGradient(bool isDark) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark ? skyGradientDark : skyGradientLight,
    );
  }

  static Color getText(bool isDark) => isDark ? textMainDark : textMainLight;

  static List<BoxShadow> glassShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFF1E3A8A).withValues(alpha: 0.1),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ),
    ];
  }

  static BoxDecoration glassDecorationNoShadow(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.15 : 0.55),
          Colors.white.withValues(alpha: isDark ? 0.05 : 0.15),
        ],
      ),
      borderRadius: BorderRadius.circular(35),
      border: Border.all(
        color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.40),
        width: 1.5,
      ),
    );
  }


  static BoxDecoration glassDecorationMobile(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.25 : 0.70),
          Colors.white.withValues(alpha: isDark ? 0.10 : 0.30),
        ],
      ),
      borderRadius: BorderRadius.circular(35),
      border: Border.all(
        color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.50),
        width: 1.5,
      ),
    );
  }

  static BoxDecoration glassDecoration(bool isDark) {
    return glassDecorationNoShadow(isDark)
        .copyWith(boxShadow: glassShadow(isDark));
  }

  static TextStyle get titleStyle => const TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      );
}