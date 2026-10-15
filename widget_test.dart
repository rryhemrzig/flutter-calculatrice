import 'package:flutter_test/flutter_test.dart';
import 'package:calculatrice_flutter/main.dart';

void main() {
  testWidgets('affiche la calculatrice et remet l’écran à zéro', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.text('7'));
    await tester.pump();
    expect(find.text('7'), findsOneWidget);

    await tester.tap(find.text('C'));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('calcule une addition', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('8'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('13'), findsOneWidget);
  });

  testWidgets('calcule une expression avec priorité opératoire', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('×'));
    await tester.tap(find.text('4'));
    await tester.tap(find.text('='));
    await tester.pump();

    expect(find.text('14'), findsOneWidget);
  });
}
