import 'package:counter_app/main.dart';
import 'package:counter_app/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'widget_tester_extension.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('カウントアップ機能', () {
    group('正常系',() {
      setUpAll(() async {
        debugPrint('カウントアップ機能正常系テスト開始');
      });
      setUp(() async {
        debugPrint('testCase start');
      });

      testWidgets('正常に数値が加算されること', (tester) async {
        // Load app widget.
        await tester.pumpWidget(const MyApp());
        // 初期表示確認
        await tester.pumpUntil(find.byType(MyApp));
        expect(find.byType(MyApp),findsOneWidget);
        expect(find.text('ボタンを押すことで数値を増加できます'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);

        for(var i = 0; i < 10; i++){
          await tester.increment();
        }
        expect(find.text('10'), findsOneWidget);
      });

      testWidgets('カウントアップ結果画面に遷移すること', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.increment();
        await tester.transitionResultPage();
        expect(find.byType(ResultPage), findsOneWidget);
        expect(find.text('計算結果'), findsOneWidget);
      });

      // TODO: 数値の乗算機能は未実装のため、本テストケースはskip対応とする
      testWidgets('正常に数値が乗算されること', (tester) async {},skip: true);
    });
    group('異常系', () {
      setUpAll(() async {
        debugPrint('カウントアップ機能異常系テスト開始');
      });
      setUp(() async {
        debugPrint('testCase start');
      });

      testWidgets('数値が0で確定した場合にエラーメッセージが表示されること', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.transitionResultPage();
        expect(find.text('0以外の数値で確定してください'), findsOneWidget);
      });
    });
  });
}

extension MainTestExtension on WidgetTester {
  // 1増加
  Future<void> increment () async {
    await tap(find.byKey(const ValueKey('increment')));
    await pumpAndSettle();
  }
}