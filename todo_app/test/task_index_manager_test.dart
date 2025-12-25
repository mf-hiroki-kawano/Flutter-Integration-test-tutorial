import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/domain/task_index_manager.dart';

import 'setup.dart';

final TaskIndexManager manager = TaskIndexManager();

void main() {
  group('TaskIndexManager Tests', () {
    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      // manager = TaskIndexManager();
    });

    tearDown(() async {
      await manager.resetTaskIndexMap();
    });

    test('should assign index 1 for first task', () async {
      final index = await manager.assignIndexForTask('First Task');
      expect(index, equals(1));
    });
  });
}
