import 'package:flutter_test/flutter_test.dart';
import '../github_actions_test/counter.dart';

void main() {
  group('Counter', () {
    test('初期値は0', () {
      final counter = Counter();
      expect(counter.value, 0);
    });

    test('increment() を呼ぶと 1 増える', () {
      final counter = Counter();
      counter.increment();
      expect(counter.value, 1);
    });

    test('decrement() を呼ぶと 1 減る', () {
      final counter = Counter();
      counter.decrement();
      expect(counter.value, -1);
    });
  });
}
