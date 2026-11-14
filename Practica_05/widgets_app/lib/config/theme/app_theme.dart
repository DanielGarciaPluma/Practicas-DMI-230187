import 'package:flutter/material.dart';

const colorList = <Color>[
  Color(0xFF5D5FEF),
  Color(0xFF4DB6AC),
  Color(0xFF66BB6A),
  Color(0xFFEF6C6B),
  Color(0xFF8E6BFF),
  Color(0xFF7C4DFF),
  Color(0xFFFFB74D),
  Color(0xFFEC407A),
  Color(0xFF26A69A),
];

class AppTheme {
  final int selectedColor;
  final bool isDarkmode;

  AppTheme({
    this.selectedColor = 0,
    this.isDarkmode = false,
  }) : assert(selectedColor >= 0, 'Selected color must be greater then 0'),
       assert(
         selectedColor < colorList.length,
         'Selected color must be less or equal than ${colorList.length - 1}',
       );

  ThemeData getTheme() {
    final baseColor = colorList[selectedColor];
    final isDark = isDarkmode;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF101827) : const Color(0xFFF5F4F8),
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: baseColor,
        secondary: const Color(0xFFFFB86C),
        surface: isDark ? const Color(0xFF182336) : Colors.white,
        onSurface: isDark ? Colors.white : const Color(0xFF1E2431),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E2431),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).textTheme.apply(
        bodyColor: isDark ? Colors.white : const Color(0xFF1E2431),
        displayColor: isDark ? Colors.white : const Color(0xFF1E2431),
      ),
    );
  }

  AppTheme copyWith({int? selectedColor, bool? isDarkmode}) => AppTheme(
    selectedColor: selectedColor ?? this.selectedColor,
    isDarkmode: isDarkmode ?? this.isDarkmode,
  );
}
