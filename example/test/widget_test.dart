import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxy_example/main.dart';

void main() {
  testWidgets('FluxyShowcase smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FluxyShowcase()));
    expect(find.byType(FluxyShowcase), findsOneWidget);
  });
}
