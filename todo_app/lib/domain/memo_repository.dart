import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Memo {
  final String text;
  final DateTime timestamp;

  Memo({required this.text, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Memo.fromJson(Map<String, dynamic> json) =>
      Memo(text: json['text'], timestamp: DateTime.parse(json['timestamp']));
}

abstract class MemoRepository {
  Future<List<Memo>> loadMemos(int taskIndex);
  Future<void> saveMemos(int taskIndex, List<Memo> memos);
}

class SharedPreferencesMemoRepository implements MemoRepository {
  static const String _memoKeyPrefix = 'todo_memo_';

  @override
  Future<List<Memo>> loadMemos(int taskIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final String? memosJson = prefs.getString(
      _memoKeyPrefix + taskIndex.toString(),
    );
    if (memosJson != null) {
      final List<dynamic> decodedMemos = jsonDecode(memosJson);
      return decodedMemos.map((memo) => Memo.fromJson(memo)).toList();
    }
    return [];
  }

  @override
  Future<void> saveMemos(int taskIndex, List<Memo> memos) async {
    final prefs = await SharedPreferences.getInstance();
    final memosJson = jsonEncode(memos.map((memo) => memo.toJson()).toList());
    await prefs.setString(_memoKeyPrefix + taskIndex.toString(), memosJson);
  }
}
