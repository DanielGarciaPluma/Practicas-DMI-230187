import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/config/theme/app_theme.dart';

void main() {
  group('AppTheme.seasonForDate', () {
    test('includes both Halloween date boundaries', () {
      expect(AppTheme.seasonForDate(DateTime(2026, 10, 30)), AppSeason.halloween);
      expect(AppTheme.seasonForDate(DateTime(2026, 11, 3)), AppSeason.halloween);
    });

    test('includes the Christmas season across the year boundary', () {
      expect(AppTheme.seasonForDate(DateTime(2026, 12, 5)), AppSeason.christmas);
      expect(AppTheme.seasonForDate(DateTime(2027, 1, 5)), AppSeason.christmas);
    });

    test('recognizes the normal and Valentine dates', () {
      expect(AppTheme.seasonForDate(DateTime(2026, 11, 4)), AppSeason.normal);
      expect(AppTheme.seasonForDate(DateTime(2026, 11, 25)), AppSeason.normal);
      expect(AppTheme.seasonForDate(DateTime(2026, 2, 14)), AppSeason.valentines);
    });
  });
}
