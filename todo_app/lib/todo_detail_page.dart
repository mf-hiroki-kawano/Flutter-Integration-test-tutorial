import 'package:flutter/material.dart';
import 'package:todo_app/memo_repository.dart';

class TodoDetailPage extends StatefulWidget {
  final int taskIndex;
  final String todoText;
  final MemoRepository memoRepository;

  TodoDetailPage({
    Key? key,
    required this.taskIndex,
    required this.todoText,
    MemoRepository? memoRepository,
  }) : memoRepository = memoRepository ?? SharedPreferencesMemoRepository(),
       super(key: key);

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final TextEditingController _memoController = TextEditingController();
  List<Memo> _memos = [];

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
    final memos = await widget.memoRepository.loadMemos(widget.taskIndex);
    setState(() {
      _memos = memos..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> _saveMemo() async {
    if (_memoController.text.isEmpty) return;
    final newMemo = Memo(text: _memoController.text, timestamp: DateTime.now());
    final updatedMemos = [..._memos, newMemo];
    await widget.memoRepository.saveMemos(widget.taskIndex, updatedMemos);
    setState(() {
      _memos = updatedMemos..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
    _memoController.clear();
  }

  Future<void> _deleteMemo(int index) async {
    final updatedMemos = List<Memo>.from(_memos)..removeAt(index);
    await widget.memoRepository.saveMemos(widget.taskIndex, updatedMemos);
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
