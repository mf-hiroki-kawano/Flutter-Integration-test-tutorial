import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/domain/memo_repository.dart';
import 'setup.dart';

void main() {
  group('MemoRepository Tests', () {
    late SharedPreferencesMemoRepository repository;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      repository = SharedPreferencesMemoRepository();
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('todo_memo_'))
          .toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    });

    group('Memo class', () {
      test('should create Memo with text and timestamp', () {
        final timestamp = DateTime(2024, 1, 1, 12, 0);
        final memo = Memo(text: 'Test memo', timestamp: timestamp);

        expect(memo.text, equals('Test memo'));
        expect(memo.timestamp, equals(timestamp));
      });
    });
  });
}
