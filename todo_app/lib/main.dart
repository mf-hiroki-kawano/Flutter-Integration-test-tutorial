import 'package:flutter/material.dart';
import 'todo_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_index_manager.dart';
import 'memo_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // todo_memo_で始まるキーを全て削除
  final keys = prefs
      .getKeys()
      .where((k) => k.startsWith('todo_memo_'))
      .toList();
  for (final k in keys) {
    await prefs.remove(k);
  }

  await TaskIndexManager().resetTaskIndexMap();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Map<String, dynamic>> _todoList = [];
  final TextEditingController _textController = TextEditingController();
  final TaskIndexManager _indexManager = TaskIndexManager();
  final MemoRepository _memoRepository = SharedPreferencesMemoRepository();

  Future<void> _addTodoItem(String task) async {
    if (task.isNotEmpty) {
      int index = await _indexManager.assignIndexForTask(task);
      setState(() {
        _todoList.add({'name': task, 'index': index});
      });
      _textController.clear();
    }
  }

  Future<void> _removeTodoItem(int listIndex) async {
    final task = _todoList[listIndex];
    final String taskName = task['name'];
    final int taskIndex = task['index'];
    await _indexManager.removeTask(taskName);
    await _memoRepository.saveMemos(taskIndex, []); // メモも削除
    setState(() {
      _todoList.removeAt(listIndex);
    });
  }

  Widget _buildTodoItem(Map<String, dynamic> task, int listIndex) {
    return ListTile(
      title: Text(task['name']),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _removeTodoItem(listIndex),
      ),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoDetailPage(
              taskIndex: task['index'],
              todoText: task['name'],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ToDoリスト')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(labelText: 'やることを入力'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _addTodoItem(_textController.text),
                  child: Text('追加'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return _buildTodoItem(_todoList[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
