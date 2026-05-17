import 'package:flutter_test/flutter_test.dart';
import 'package:fluxy/fluxy.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Fluxy App Boot Test', (WidgetTester tester) async {
    // 1. Initialize Minimal Framework
    await Fluxy.init();

    // 2. Build App
    await tester.pumpWidget(
      const FluxyApp(
        title: 'Test App',
        routes: [],
      ),
    );

    // 3. Verify Boot
    expect(find.byType(FluxyApp), findsOneWidget);
  });
}
