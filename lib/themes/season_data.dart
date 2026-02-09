import 'package:flutter/material.dart';

// Mudança de nome: SeasonType -> ThemeType
enum ThemeType {
  defaultTheme,
  summer,
  spring,
  autumn,
  winter,
  halloween,
  christmas
}

enum ParticleType { none, rain, snow, leaves, summer, halloween, christmas }

abstract class SeasonTheme {
  String get nameKey;
  Color get lightTop;
  Color get lightBottom;
  Color get darkTop;
  Color get darkBottom;
  Color get accentColor;
  ParticleType get particleType;
}

class DefaultTheme implements SeasonTheme {
  @override
  String get nameKey => 'theme_default';
  @override
  Color get lightTop => const Color(0xFF4FA8C5);
  @override
  Color get lightBottom => const Color(0xFF83a4d4);
  @override
  Color get darkTop => const Color(0xFF141E30);
  @override
  Color get darkBottom => const Color(0xFF243B55);
  @override
  Color get accentColor => const Color(0xFF3B82F6);
  @override
  ParticleType get particleType => ParticleType.none;
}

class SummerTheme implements SeasonTheme {
  @override
  String get nameKey => 'season_summer';
  @override
  Color get lightTop => const Color(0xFF2980B9);
  @override
  Color get lightBottom => const Color(0xFF80E2FF);
  @override
  Color get darkTop => const Color(0xFF0A1025);
  @override
  Color get darkBottom => const Color(0xFF1565C0);
  @override
  Color get accentColor => const Color(0xFF00B0FF);
  @override
  ParticleType get particleType => ParticleType.summer;
}

class SpringTheme implements SeasonTheme {
  @override
  String get nameKey => 'season_spring';
  @override
  Color get lightTop => const Color(0xFFA18CD1);
  @override
  Color get lightBottom => const Color(0xFFFBC2EB);
  @override
  Color get darkTop => const Color(0xFF2E1437);
  @override
  Color get darkBottom => const Color(0xFF4A148C);
  @override
  Color get accentColor => const Color(0xFFD500F9);
  @override
  ParticleType get particleType => ParticleType.rain;
}

class AutumnTheme implements SeasonTheme {
  @override
  String get nameKey => 'season_autumn';
  @override
  Color get lightTop => const Color(0xFFD38312);
  @override
  Color get lightBottom => const Color(0xFFFF8F00);
  @override
  Color get darkTop => const Color(0xFF251614);
  @override
  Color get darkBottom => const Color(0xFF4E342E);
  @override
  Color get accentColor => const Color(0xFFFF6D00);
  @override
  ParticleType get particleType => ParticleType.leaves;
}

class WinterTheme implements SeasonTheme {
  @override
  String get nameKey => 'season_winter';
  @override
  Color get lightTop => const Color(0xFF90A4AE);
  @override
  Color get lightBottom => const Color(0xFFECEFF1);
  @override
  Color get darkTop => const Color(0xFF121212);
  @override
  Color get darkBottom => const Color(0xFF37474F);
  @override
  Color get accentColor => const Color(0xFF00E5FF);
  @override
  ParticleType get particleType => ParticleType.snow;
}

class HalloweenTheme implements SeasonTheme {
  @override
  String get nameKey => 'season_halloween';
  // Azul acinzentado -> Roxo suave
  @override
  Color get lightTop => const Color(0xFF5D6D7E);
  @override
  Color get lightBottom => const Color(0xFF884EA0);
  // Tons escuros para o modo dark
  @override
  Color get darkTop => const Color(0xFF1B2631);
  @override
  Color get darkBottom => const Color(0xFF4A235A);
  // Laranja queimado
  @override
  Color get accentColor => const Color(0xFFD35400);
  @override
  ParticleType get particleType => ParticleType.halloween;
}

class ChristmasTheme implements SeasonTheme {
  @override
  String get nameKey => 'season_christmas';
  // Azul noite festivo -> Verde pinheiro
  @override
  Color get lightTop => const Color(0xFF1F618D);
  @override
  Color get lightBottom => const Color(0xFF117A65);
  // Modo dark
  @override
  Color get darkTop => const Color(0xFF0E1621);
  @override
  Color get darkBottom => const Color(0xFF0B3B2E);
  // Dourado fosco
  @override
  Color get accentColor => const Color(0xFFF1C40F);
  @override
  ParticleType get particleType => ParticleType.christmas;
}

// Função atualizada para usar ThemeType
SeasonTheme getThemeData(ThemeType type) {
  switch (type) {
    case ThemeType.defaultTheme:
      return DefaultTheme();
    case ThemeType.summer:
      return SummerTheme();
    case ThemeType.spring:
      return SpringTheme();
    case ThemeType.autumn:
      return AutumnTheme();
    case ThemeType.winter:
      return WinterTheme();
    case ThemeType.halloween:
      return HalloweenTheme();
    case ThemeType.christmas:
      return ChristmasTheme();
  }
}
