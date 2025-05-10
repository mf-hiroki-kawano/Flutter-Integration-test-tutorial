import 'dart:async';

import 'package:counter_app/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> transitionResultPage() async {
    await tap(find.widgetWithText(ElevatedButton, '確定'));
    await pumpUntil(find.byType(ResultPage));
  }

  Future<void> pumpUntil(
    FinderBase<Element> finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final timer = Timer(timeout, () {});
    try {
      while (timer.isActive) {
        if (any(finder)) {
          return;
        }
        await pumpAndSettle();
      }
      throw TimeoutException('Timed to find $finder', timeout);
    } finally {
      timer.cancel();
    }
  }
}