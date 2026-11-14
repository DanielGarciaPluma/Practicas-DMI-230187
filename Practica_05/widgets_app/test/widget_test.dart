import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:widgets_app/main.dart';

void main() {
  testWidgets('Home screen renders the custom dashboard', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Pluma Studio'), findsOneWidget);
    expect(find.text('Widgets App'), findsOneWidget);
    expect(find.text('Explora módulos'), findsOneWidget);
  });

  testWidgets('Home screen lays out cards on a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MainApp());

    expect(tester.takeException(), isNull);
  });
}
