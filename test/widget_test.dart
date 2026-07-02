import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brownie/main.dart';

void main() {
  testWidgets('shows Birdle app', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Birdle'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.arrow_circle_up), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('empty tiles use dark fill in dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    final tile = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final decoration = tile.decoration as BoxDecoration;

    expect(decoration.color, isNot(Colors.white));
  });

  testWidgets('toggles between light and dark mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.byTooltip('Switch to light mode'));
    await tester.pump();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to dark mode'));
    await tester.pump();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
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

  testWidgets('shows game over and restart button after all tries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    for (var i = 0; i < 6; i++) {
      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.tap(find.byIcon(Icons.arrow_circle_up));
      await tester.pump();
    }

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Game over! The word was'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('restart button starts a new game', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    for (var i = 0; i < 6; i++) {
      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.tap(find.byIcon(Icons.arrow_circle_up));
      await tester.pump();
    }

    await tester.tap(find.text('Play again'));
    await tester.pump();

    expect(find.textContaining('Game over! The word was'), findsNothing);
    expect(find.text('Play again'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });
}
