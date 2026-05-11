// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/skill.dart';
import '../models/task.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'skill_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE skills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            skillId INTEGER NOT NULL,
            title TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            completedAt INTEGER,
            FOREIGN KEY (skillId) REFERENCES skills(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<void> initialize() async {
    await database; // 触发初始化
  }

  // ---------- 技能操作 ----------
  Future<int> insertSkill(Skill skill) async {
    final db = await database;
    return db.insert('skills', skill.toMap());
  }

  Future<List<Map<String, dynamic>>> getSkills() async {
    final db = await database;
    return db.query('skills');
  }

  Future<int> deleteSkill(int id) async {
    final db = await database;
    return db.delete('skills', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- 任务操作 ----------
  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Map<String, dynamic>>> getTasksBySkill(int skillId) async {
    final db = await database;
    return db.query('tasks',
        where: 'skillId = ?', whereArgs: [skillId], orderBy: 'id ASC');
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllCompletedTasks() async {
    final db = await database;
    return db
        .query('tasks', where: 'isCompleted = 1', orderBy: 'completedAt DESC');
  }
}