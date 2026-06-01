import 'package:flutter/material.dart';

@immutable
class SonicFocusTokens extends ThemeExtension<SonicFocusTokens> {
  const SonicFocusTokens({
    required this.backgroundBase,
    required this.backgroundOverlay,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.panelRadius,
    required this.controlRadius,
    required this.containerPadding,
    required this.gutter,
    required this.sectionGap,
  });

  final Color backgroundBase;
  final Color backgroundOverlay;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;

  final double panelRadius;
  final double controlRadius;
  final double containerPadding;
  final double gutter;
  final double sectionGap;

  static const defaultTokens = SonicFocusTokens(
    backgroundBase: Color(0xFF0A0A0B),
    backgroundOverlay: Color(0xFF131314),
    primary: Color(0xFFADC6FF),
    secondary: Color(0xFFD0BCFF),
    tertiary: Color(0xFF4EDEA3),
    onSurface: Color(0xFFE5E2E3),
    onSurfaceVariant: Color(0xFFC2C6D6),
    outline: Color(0xFF8C909F),
    panelRadius: 24,
    controlRadius: 12,
    containerPadding: 20,
    gutter: 24,
    sectionGap: 64,
  );

  @override
  ThemeExtension<SonicFocusTokens> copyWith() => this;

  @override
  ThemeExtension<SonicFocusTokens> lerp(covariant ThemeExtension<SonicFocusTokens>? other, double t) => this;
}

ThemeData buildSonicFocusTheme() {
  const tokens = SonicFocusTokens.defaultTokens;
  const colorScheme = ColorScheme.dark(
    primary: Color(0xFFADC6FF),
    onPrimary: Color(0xFF002E6A),
    secondary: Color(0xFFD0BCFF),
    surface: Color(0xFF201F20),
    onSurface: Color(0xFFE5E2E3),
    onSurfaceVariant: Color(0xFFC2C6D6),
    outline: Color(0xFF8C909F),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tokens.backgroundBase,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 48, height: 56 / 48, fontWeight: FontWeight.w700, letterSpacing: -0.96),
      headlineLarge: TextStyle(fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w600, letterSpacing: -0.32),
      headlineMedium: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400),
      labelMedium: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.7),
      labelSmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400),
    ),
    extensions: const [tokens],
  );
}

extension SonicFocusThemeX on BuildContext {
  SonicFocusTokens get sf => Theme.of(this).extension<SonicFocusTokens>()!;
}
