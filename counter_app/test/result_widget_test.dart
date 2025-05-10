import 'package:counter_app/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('0以外の数値が表示される場合', (tester) async {
    final result = 10;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(result: result),
      ),
    );  

    final titleFinder = find.text('Result Page');
    final resultFinder = find.text(result.toString());
    final messageFinder = find.text('Congratulations!!!');

    expect(titleFinder, findsOneWidget);
    expect(resultFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });

  testWidgets('0が表示される場合', (tester) async {
    final result = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(result: result),
      ),
    );  

    final resultFinder = find.text(result.toString());
    final messageFinder = find.text('0以外の数値で確定してください');

    expect(resultFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
