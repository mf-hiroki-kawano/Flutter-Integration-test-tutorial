import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoDetailPage extends StatefulWidget {
  final String todoText;

  const TodoDetailPage({Key? key, required this.todoText}) : super(key: key);

  @override
  _TodoDetailPageState createState() => _TodoDetailPageState();
}

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

class _TodoDetailPageState extends State<TodoDetailPage> {
  final TextEditingController _memoController = TextEditingController();
  List<Memo> _memos = [];
  static const String _memoKey = 'todo_memo_';

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? memosJson = prefs.getString(_memoKey + widget.todoText);
    if (memosJson != null) {
      final List<dynamic> decodedMemos = jsonDecode(memosJson);
      setState(() {
        _memos = decodedMemos.map((memo) => Memo.fromJson(memo)).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    }
  }

  Future<void> _saveMemo() async {
    if (_memoController.text.isEmpty) return;

    final newMemo = Memo(text: _memoController.text, timestamp: DateTime.now());

    final prefs = await SharedPreferences.getInstance();
    final updatedMemos = [..._memos, newMemo];
    final memosJson = jsonEncode(
      updatedMemos.map((memo) => memo.toJson()).toList(),
    );

    await prefs.setString(_memoKey + widget.todoText, memosJson);

    setState(() {
      _memos = updatedMemos..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
    _memoController.clear();
  }

  Future<void> _deleteMemo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedMemos = List<Memo>.from(_memos)..removeAt(index);
    final memosJson = jsonEncode(
      updatedMemos.map((memo) => memo.toJson()).toList(),
    );

    await prefs.setString(_memoKey + widget.todoText, memosJson);

    setState(() {
      _memos = updatedMemos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('タスクの詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('タスク内容:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(widget.todoText, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Text('メモ一覧:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _memos.length,
                itemBuilder: (context, index) {
                  final memo = _memos[index];
                  return Card(
                    child: ListTile(
                      title: Text(memo.text),
                      subtitle: Text(
                        '${memo.timestamp.year}/${memo.timestamp.month}/${memo.timestamp.day} '
                        '${memo.timestamp.hour}:${memo.timestamp.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMemo(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _memoController,
                    decoration: InputDecoration(
                      hintText: 'メモを入力',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _saveMemo, child: Text('保存')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
