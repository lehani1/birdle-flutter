import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brownie/main.dart';

void main() {
  testWidgets('shows Birdle app', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Birdle'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.arrow_circle_up), findsOneWidget);
  });

  testWidgets('submits a general five-letter guess', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    await tester.enterText(find.byType(TextField), 'crane');
    await tester.tap(find.byIcon(Icons.arrow_circle_up));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('R'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
  });

  testWidgets('rejects non-five-letter input without throwing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.byIcon(Icons.arrow_circle_up));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Enter a five-letter word'), findsOneWidget);
  });
}
