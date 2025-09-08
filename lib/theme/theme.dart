import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8d4e2a),
      surfaceTint: Color(0xff8d4e2a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdbcb),
      onPrimaryContainer: Color(0xff703715),
      secondary: Color(0xff765848),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdbcb),
      onSecondaryContainer: Color(0xff5c4032),
      tertiary: Color(0xff666014),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffefe58b),
      onTertiaryContainer: Color(0xff4e4800),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff221a15),
      onSurfaceVariant: Color(0xff52443d),
      outline: Color(0xff85736c),
      outlineVariant: Color(0xffd7c2b9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e2a),
      inversePrimary: Color(0xffffb690),
      primaryFixed: Color(0xffffdbcb),
      onPrimaryFixed: Color(0xff341100),
      primaryFixedDim: Color(0xffffb690),
      onPrimaryFixedVariant: Color(0xff703715),
      secondaryFixed: Color(0xffffdbcb),
      onSecondaryFixed: Color(0xff2b160b),
      secondaryFixedDim: Color(0xffe6beab),
      onSecondaryFixedVariant: Color(0xff5c4032),
      tertiaryFixed: Color(0xffefe58b),
      onTertiaryFixed: Color(0xff1f1c00),
      tertiaryFixedDim: Color(0xffd2c972),
      onTertiaryFixedVariant: Color(0xff4e4800),
      surfaceDim: Color(0xffe8d7cf),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1eb),
      surfaceContainer: Color(0xfffceae3),
      surfaceContainerHigh: Color(0xfff6e5dd),
      surfaceContainerHighest: Color(0xfff0dfd8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff6a1800),
      surfaceTint: Color(0xffab350f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbf431d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff5d2515),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffa05a46),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff433400),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff856a00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff1a0e0b),
      onSurfaceVariant: Color(0xff47312b),
      outline: Color(0xff654d46),
      outlineVariant: Color(0xff826760),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3c2d29),
      inversePrimary: Color(0xffffb5a0),
      primaryFixed: Color(0xffbf431d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff9e2b04),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xffa05a46),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff834330),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff856a00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff685200),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd9c2bc),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ed),
      surfaceContainer: Color(0xfffbe3dd),
      surfaceContainerHigh: Color(0xfff0d8d1),
      surfaceContainerHighest: Color(0xffe4cdc6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff581300),
      surfaceTint: Color(0xffab350f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff8b2300),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff501c0c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff743826),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff372b00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5a4700),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff3c2721),
      outlineVariant: Color(0xff5b443d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff3c2d29),
      inversePrimary: Color(0xffffb5a0),
      primaryFixed: Color(0xff8b2300),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff631600),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff743826),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff582212),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5a4700),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3f3100),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffcab4ae),
      surfaceBright: Color(0xfffff8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede8),
      surfaceContainer: Color(0xfff6ddd7),
      surfaceContainerHigh: Color(0xffe7cfc9),
      surfaceContainerHighest: Color(0xffd9c2bc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb5a0),
      surfaceTint: Color(0xffffb5a0),
      onPrimary: Color(0xff5f1500),
      primaryContainer: Color(0xffef653d),
      onPrimaryContainer: Color(0xff2f0600),
      secondary: Color(0xffffb5a0),
      onSecondary: Color(0xff552010),
      secondaryContainer: Color(0xff743726),
      onSecondaryContainer: Color(0xfff8a38b),
      tertiary: Color(0xffe8c34f),
      onTertiary: Color(0xff3c2f00),
      tertiaryContainer: Color(0xffcba836),
      onTertiaryContainer: Color(0xff4f3e00),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1c100d),
      onSurface: Color(0xfff6ddd7),
      onSurfaceVariant: Color(0xffe0bfb7),
      outline: Color(0xffa88a82),
      outlineVariant: Color(0xff59413b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff6ddd7),
      inversePrimary: Color(0xffab350f),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff3b0900),
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff872100),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff390b01),
      secondaryFixedDim: Color(0xffffb5a0),
      onSecondaryFixedVariant: Color(0xff713524),
      tertiaryFixed: Color(0xffffe088),
      onTertiaryFixed: Color(0xff241a00),
      tertiaryFixedDim: Color(0xffe8c34f),
      onTertiaryFixedVariant: Color(0xff574500),
      surfaceDim: Color(0xff1c100d),
      surfaceBright: Color(0xff453632),
      surfaceContainerLowest: Color(0xff170b08),
      surfaceContainerLow: Color(0xff251915),
      surfaceContainer: Color(0xff2a1d19),
      surfaceContainerHigh: Color(0xff352723),
      surfaceContainerHighest: Color(0xff40312d),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd2c7),
      surfaceTint: Color(0xffffb5a0),
      onPrimary: Color(0xff4d0f00),
      primaryContainer: Color(0xffef653d),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffd2c7),
      onSecondary: Color(0xff471507),
      secondaryContainer: Color(0xffca7d67),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd965),
      onTertiary: Color(0xff302400),
      tertiaryContainer: Color(0xffcba836),
      onTertiaryContainer: Color(0xff2a2000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1c100d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff7d5cc),
      outline: Color(0xffcbaba2),
      outlineVariant: Color(0xffa78a82),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff6ddd7),
      inversePrimary: Color(0xff892200),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff290500),
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff6a1800),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff290500),
      secondaryFixedDim: Color(0xffffb5a0),
      onSecondaryFixedVariant: Color(0xff5d2515),
      tertiaryFixed: Color(0xffffe088),
      onTertiaryFixed: Color(0xff171000),
      tertiaryFixedDim: Color(0xffe8c34f),
      onTertiaryFixedVariant: Color(0xff433400),
      surfaceDim: Color(0xff1c100d),
      surfaceBright: Color(0xff51413d),
      surfaceContainerLowest: Color(0xff0f0504),
      surfaceContainerLow: Color(0xff271b17),
      surfaceContainer: Color(0xff322521),
      surfaceContainerHigh: Color(0xff3e2f2b),
      surfaceContainerHighest: Color(0xff4a3a36),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece7),
      surfaceTint: Color(0xffffb5a0),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffaf99),
      onPrimaryContainer: Color(0xff1e0300),
      secondary: Color(0xffffece7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffaf99),
      onSecondaryContainer: Color(0xff1e0300),
      tertiary: Color(0xffffefc8),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffe4bf4b),
      onTertiaryContainer: Color(0xff100b00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff1c100d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece7),
      outlineVariant: Color(0xffdcbbb3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff6ddd7),
      inversePrimary: Color(0xff892200),
      primaryFixed: Color(0xffffdbd1),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb5a0),
      onPrimaryFixedVariant: Color(0xff290500),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffffb5a0),
      onSecondaryFixedVariant: Color(0xff290500),
      tertiaryFixed: Color(0xffffe088),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe8c34f),
      onTertiaryFixedVariant: Color(0xff171000),
      surfaceDim: Color(0xff1c100d),
      surfaceBright: Color(0xff5d4c48),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff2a1d19),
      surfaceContainer: Color(0xff3c2d29),
      surfaceContainerHigh: Color(0xff473834),
      surfaceContainerHighest: Color(0xff53433f),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    ),
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
