import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/config/theme/app_theme.dart';

void main() {
  testWidgets('TokTik seasonal theme renders app content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme().getTheme(AppSeason.halloween),
        home: const Scaffold(body: Center(child: Text('TokTik'))),
      ),
    );

    expect(find.text('TokTik'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('TokTik'))).brightness,
      Brightness.dark,
    );
  });
}
