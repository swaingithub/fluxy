import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluxy/fluxy.dart';

void main() {
  testWidgets('AI optimizations syntax check', (WidgetTester tester) async {
    // 1. Test Tailwind Parser with new values
    final parsedStyle = Tailwind.parse('text-center font-bold z-10 opacity-50 scale-50 rotate-45');
    // We just ensure parsing doesn't throw and matches the expected output correctly natively 
    expect(parsedStyle.textAlign, TextAlign.center);
    expect(parsedStyle.fontWeight, FontWeight.bold);
    expect(parsedStyle.zIndex, 10.0);
    expect(parsedStyle.opacity, 0.5);
    expect(parsedStyle.transformScale, 0.5);

    // 2. Test semantic widgets
    final testWidget = Fx.col(
      children: [
        Fx.card(
          child: Fx.text('Card Content').tw('font-bold text-center z-10 opacity-50'),
        ),
        Fx.listTile(
          title: Fx.text('Title'),
          subtitle: Fx.text('Subtitle'),
          leading: Fx.avatar(image: 'https://via.placeholder.com/150'),
          trailing: Fx.icon(Icons.arrow_forward),
        ),
      ],
    );

    // Provide Directionality to avoid errors since Fx.col and children are generic widgets.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: testWidget,
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });
}
