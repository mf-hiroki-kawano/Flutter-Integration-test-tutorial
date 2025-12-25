# todo_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## レポート生成 (XML → HTML)

JUnit 形式の XML から、総実行時間と成功率を含む HTML レポートを生成できます。

使い方:

```
python3 todo_app/scripts/junit_to_html.py \
	todo_app/integration_test_report_20250920_151039.xml \
	-o todo_app/integration_test_report_with_summary.html
```

- 総実行時間: 各 `<testcase>` の `time` を合算
- 成功率: `(tests - failures - errors - skipped) / tests * 100`
- 出力先を省略すると `<入力XML>_with_summary.html` が生成されます
