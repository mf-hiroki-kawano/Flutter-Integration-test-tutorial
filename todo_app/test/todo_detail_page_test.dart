import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_app/presentation/todo_detail_page.dart';
import 'package:todo_app/domain/memo_repository.dart';
import 'setup.dart';

import 'todo_detail_page_test.mocks.dart';

@GenerateMocks([MemoRepository])
void main() {
  group('TodoDetailPage Tests', () {
    late MockMemoRepository mockRepository;
    late Widget testWidget;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockRepository = MockMemoRepository();
      testWidget = MaterialApp(
        home: TodoDetailPage(
          taskIndex: 1,
          todoText: 'Test Task',
          memoRepository: mockRepository,
        ),
      );
    });

    group('Initialization', () {
      testWidgets('should load memos on initialization', (
        WidgetTester tester,
      ) async {
        final testMemos = [
          Memo(text: 'Test memo 1', timestamp: DateTime(2024, 1, 1, 12, 0)),
          Memo(text: 'Test memo 2', timestamp: DateTime(2024, 1, 1, 13, 0)),
        ];

        when(mockRepository.loadMemos(1)).thenAnswer((_) async => testMemos);

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        verify(mockRepository.loadMemos(1)).called(1);
      });
    });

    group('Memo Display', () {
      testWidgets('should display memos in list', (WidgetTester tester) async {
        final testMemos = [
          Memo(text: 'First memo', timestamp: DateTime(2024, 1, 1, 12, 0)),
          Memo(text: 'Second memo', timestamp: DateTime(2024, 1, 1, 13, 0)),
        ];

        when(mockRepository.loadMemos(1)).thenAnswer((_) async => testMemos);

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        expect(find.text('First memo'), findsOneWidget);
        expect(find.text('Second memo'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(2));
      });
    });

    group('Add Memo', () {
      testWidgets('should save memo when save button is pressed', (
        WidgetTester tester,
      ) async {
        when(mockRepository.loadMemos(1)).thenAnswer((_) async => []);
        when(mockRepository.saveMemos(any, any)).thenAnswer((_) async {});

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'New memo');
        await tester.tap(find.text('保存'));
        await tester.pumpAndSettle();

        verify(mockRepository.saveMemos(1, any)).called(1);
      });
    });

    group('Delete Memo', () {
      testWidgets('should delete memo when delete button is pressed', (
        WidgetTester tester,
      ) async {
        final testMemos = [
          Memo(text: 'First memo', timestamp: DateTime(2024, 1, 1, 12, 0)),
          Memo(text: 'Second memo', timestamp: DateTime(2024, 1, 1, 13, 0)),
        ];

        when(mockRepository.loadMemos(1)).thenAnswer((_) async => testMemos);
        when(mockRepository.saveMemos(any, any)).thenAnswer((_) async {});

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();

        verify(mockRepository.saveMemos(1, any)).called(1);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle repository errors gracefully', (
        WidgetTester tester,
      ) async {
        when(
          mockRepository.loadMemos(1),
        ).thenThrow(Exception('Database error'));

        await tester.pumpWidget(testWidget);
        await tester.pumpAndSettle();

        // Should not crash and should still display the UI
        expect(find.text('Test Task'), findsOneWidget);
        expect(find.text('メモ一覧:'), findsOneWidget);
      });
    });
  });
}
