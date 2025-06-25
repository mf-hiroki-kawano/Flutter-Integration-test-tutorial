import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_app/domain/memo_repository.dart';
import 'package:todo_app/presentation/todo_detail_page.dart';
import 'setup.dart';

import 'widget_todo_detail_page_test.mocks.dart';

@GenerateMocks([MemoRepository])
void main() {
  group('TodoDetailPage Widget Tests', () {
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
  });
}
