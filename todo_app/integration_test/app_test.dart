import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('正常系', () {
    testWidgets('タスク一覧画面の初期表示確認', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 初期状態の確認
      expect(find.text('ToDoリスト'), findsOneWidget);
      expect(find.text('やることを入力'), findsOneWidget);
      expect(find.text('追加'), findsOneWidget);
    });

    testWidgets('タスクの追加', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // タスクを追加
      await tester.enterText(find.byType(TextField), 'テストタスク');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // タスクが追加されたことを確認
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('タスク詳細画面への遷移確認', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // タスクを追加
      await tester.enterText(find.byType(TextField), 'テストタスク');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // タスクをタップして詳細画面に遷移
      await tester.tap(find.text('テストタスク'));
      await tester.pumpAndSettle();

      // 詳細画面の確認
      expect(find.text('タスクの詳細'), findsOneWidget);
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.text('メモ一覧:'), findsOneWidget);
      expect(find.text('メモを入力'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
    });

    testWidgets('メモの追加', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // タスクを追加
      await tester.enterText(find.byType(TextField), 'テストタスク');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // タスクをタップして詳細画面に遷移
      await tester.tap(find.text('テストタスク'));
      await tester.pumpAndSettle();

      // メモを追加
      await tester.enterText(find.byType(TextField), 'テストメモ1');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // メモが追加されたことを確認
      expect(find.text('テストメモ1'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // 2つ目のメモを追加
    });

    testWidgets('タスクの削除', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // タスクを追加
      await tester.enterText(find.byType(TextField), 'テストタスク');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();
      // タスクが追加されたことを確認
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      // タスクをタップして詳細画面に遷移
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.text('テストタスク'), findsNothing);
    });

    testWidgets('error test case', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 初期状態の確認
      expect(find.text('ToDoリスト'), findsOneWidget);
      expect(find.text('やることを入力'), findsOneWidget);
      expect(find.text('追加'), findsOneWidget);

      // タスクを追加
      await tester.enterText(find.byType(TextField), 'テストタスク');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // タスクが追加されたことを確認
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      // タスクをタップして詳細画面に遷移
      await tester.tap(find.text('テストタスク'));
      await tester.pumpAndSettle();

      // 詳細画面の確認
      expect(find.text('タスクの詳細'), findsOneWidget);
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.text('メモ一覧:'), findsOneWidget);
      expect(find.text('メモを入力'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);

      // メモを追加
      await tester.enterText(find.byType(TextField), 'テストメモ1');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // メモが追加されたことを確認
      expect(find.text('テストメモ1'), findsNothing);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('skip test case', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 初期状態の確認
      expect(find.text('ToDoリスト'), findsOneWidget);
      expect(find.text('やることを入力'), findsOneWidget);
      expect(find.text('追加'), findsOneWidget);

      // タスクを追加
      await tester.enterText(find.byType(TextField), 'テストタスク');
      await tester.tap(find.text('追加'));
      await tester.pumpAndSettle();

      // タスクが追加されたことを確認
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      // タスクをタップして詳細画面に遷移
      await tester.tap(find.text('テストタスク'));
      await tester.pumpAndSettle();

      // 詳細画面の確認
      expect(find.text('タスクの詳細'), findsOneWidget);
      expect(find.text('テストタスク'), findsOneWidget);
      expect(find.text('メモ一覧:'), findsOneWidget);
      expect(find.text('メモを入力'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);

      // メモを追加
      await tester.enterText(find.byType(TextField), 'テストメモ1');
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // メモが追加されたことを確認
      expect(find.text('テストメモ1'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // 2つ目のメモを追加
    }, skip: true);
  });
}

extension AppExtension on WidgetTester {
  Future<void> deleteTask(String taskName) async {
    final deleteFinder = find.descendant(
      of: find.widgetWithText(ListTile, taskName),
      matching: find.byIcon(Icons.delete),
    );
    await tap(deleteFinder);
    await pumpAndSettle();
  }
}
