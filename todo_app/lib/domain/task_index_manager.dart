import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskIndexManager {
  static const String _mapKey = 'task_index_map';

  /// タスク名→indexのマッピングを取得
  Future<Map<String, int>> loadTaskIndexMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_mapKey);
    if (jsonStr == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((k, v) => MapEntry(k, v as int));
  }

  /// マッピングを保存
  Future<void> saveTaskIndexMap(Map<String, int> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mapKey, jsonEncode(map));
  }

  /// マッピングをリセット
  Future<void> resetTaskIndexMap() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mapKey);
  }

  /// 新しいタスク名に未使用indexを割り当てて返す
  Future<int> assignIndexForTask(String taskName) async {
    final map = await loadTaskIndexMap();
    if (map.containsKey(taskName)) return map[taskName]!;
    int newIndex = 1;
    if (map.isNotEmpty) {
      final used = map.values.toSet();
      while (used.contains(newIndex)) {
        newIndex++;
      }
    }
    map[taskName] = newIndex;
    await saveTaskIndexMap(map);
    return newIndex;
  }

  /// タスク名でマッピングから削除
  Future<void> removeTask(String taskName) async {
    final map = await loadTaskIndexMap();
    map.remove(taskName);
    await saveTaskIndexMap(map);
  }
}
