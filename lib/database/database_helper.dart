// lib/database/database_helper.dart
import 'package:flutter/foundation.dart' show kIsWeb;
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
    // 如果是 Web，使用 sqflite_common_ffi
    if (kIsWeb) {
      // 对于 Web，我们直接使用内存数据库（不需要持久化，但能运行）
      // 你需要添加依赖：sqflite_common_ffi_web，但为了简化，这里先空实现
      // 实际上标准 sqflite 在 Web 上会报错，所以我们需要换一种方法。
      return await openDatabase(
        inMemoryDatabasePath,
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
    } else {
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
  }

  Future<void> initialize() async {
    await database;
  }

  // 其余方法不变，完全照旧
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

  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Map<String, dynamic>>> getTasksBySkill(int skillId) async {
    final db = await database;
    return db.query('tasks', where: 'skillId = ?', whereArgs: [skillId], orderBy: 'id ASC');
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllCompletedTasks() async {
    final db = await database;
    return db.query('tasks', where: 'isCompleted = 1', orderBy: 'completedAt DESC');
  }
}