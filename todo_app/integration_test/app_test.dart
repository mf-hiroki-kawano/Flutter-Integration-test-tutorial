import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo App Integration Tests', () {
    testWidgets(
      'Complete user flow: add task, add memo, delete memo, delete task',
      (WidgetTester tester) async {
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
      },
    );
  });
}
