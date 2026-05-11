// lib/providers/task_provider.dart
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import 'skill_provider.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  late SkillProvider _skillProvider;

  List<Task> get tasks => _tasks;

  void updateSkillProvider(SkillProvider provider) {
    _skillProvider = provider;
  }

  Future<void> loadTasks(int skillId) async {
    final data = await _dbHelper.getTasksBySkill(skillId);
    _tasks = data.map((map) => Task.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addTask(int skillId, String title) async {
    final task = Task(skillId: skillId, title: title);
    final int id = await _dbHelper.insertTask(task);
    if (id > 0) {
      _tasks.add(Task(id: id, skillId: skillId, title: title));
      notifyListeners();
    }
  }

  Future<void> toggleTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    final now = DateTime.now().millisecondsSinceEpoch;
    final isNowCompleted = !task.isCompleted;
    final updated = task.copyWith(
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? now : null);
    await _dbHelper.updateTask(updated);
    _tasks[index] = updated;
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// 获取全部已完成任务，用于统计连续打卡天数
  Future<List<Task>> getAllCompletedTasks() async {
    final data = await _dbHelper.getAllCompletedTasks();
    return data.map((map) => Task.fromMap(map)).toList();
  }
}