import 'package:flutter/material.dart';

enum AppSeason { normal, halloween, christmas, valentines }

extension AppSeasonLabel on AppSeason {
  String get label => switch (this) {
        AppSeason.normal => 'Normal',
        AppSeason.halloween => 'Halloween',
        AppSeason.christmas => 'Navidad',
        AppSeason.valentines => 'San Valentín',
      };
}

class AppTheme {
  static AppSeason seasonForDate(DateTime date) {
    final month = date.month;
    final day = date.day;
    if ((month == 10 && day >= 30) || (month == 11 && day <= 3)) {
      return AppSeason.halloween;
    }
    if ((month == 12 && day >= 5) || (month == 1 && day <= 5)) {
      return AppSeason.christmas;
    }
    if (month == 2 && day == 14) return AppSeason.valentines;
    return AppSeason.normal;
  }

  ThemeData getTheme(AppSeason season) {
    final (seed, background, foreground, fontFamily) = switch (season) {
      AppSeason.normal => (
          const Color(0xFF5B5BD6),
          const Color(0xFF101014),
          Colors.white,
          'Roboto'
        ),
      AppSeason.halloween => (
          const Color(0xFFFF7518),
          const Color(0xFF170D1C),
          const Color(0xFFFFE5C2),
          'serif'
        ),
      AppSeason.christmas => (
          const Color(0xFF138A52),
          const Color(0xFF071A13),
          const Color(0xFFE8FFF2),
          'sans-serif'
        ),
      AppSeason.valentines => (
          const Color(0xFFE84372),
          const Color(0xFF210D16),
          const Color(0xFFFFE7EF),
          'cursive'
        ),
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: background,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: fontFamily,
            bodyColor: foreground,
            displayColor: foreground,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        centerTitle: false,
      ),
    );
  }
}
