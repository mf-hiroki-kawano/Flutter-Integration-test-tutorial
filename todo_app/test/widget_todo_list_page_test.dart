import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/domain/task_index_manager.dart';
import 'package:todo_app/domain/memo_repository.dart';
import 'setup.dart';

import 'widget_todo_list_page_test.mocks.dart';

@GenerateMocks([TaskIndexManager, MemoRepository])
void main() {
  group('TodoListPage Widget Tests', () {
    late MockTaskIndexManager mockIndexManager;
    late MockMemoRepository mockMemoRepository;
    late Widget testWidget;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockIndexManager = MockTaskIndexManager();
      mockMemoRepository = MockMemoRepository();

      // デフォルトのモック設定
      when(mockIndexManager.assignIndexForTask(any)).thenAnswer((_) async => 1);
      when(mockIndexManager.removeTask(any)).thenAnswer((_) async {});
      when(mockMemoRepository.saveMemos(any, any)).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return MaterialApp(home: TodoListPage());
    }

    group('Initial State', () {
      testWidgets('should display app bar with correct title', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('ToDoリスト'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });
  });
}
