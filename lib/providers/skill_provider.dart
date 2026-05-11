// lib/providers/skill_provider.dart
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/skill.dart';

class SkillProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Skill> _skills = [];

  List<Skill> get skills => _skills;

  Future<void> loadSkills() async {
    final data = await _dbHelper.getSkills();
    _skills = data.map((map) => Skill.fromMap(map)).toList();
    notifyListeners();
  }

  Future<void> addSkill(String name, String icon) async {
    // 传入 Skill 对象，不带 .toMap()
    final int id = await _dbHelper.insertSkill(Skill(name: name, icon: icon));
    if (id > 0) {
      _skills.insert(0, Skill(id: id, name: name, icon: icon));
      notifyListeners();
    }
  }

  Future<void> deleteSkill(int id) async {
    await _dbHelper.deleteSkill(id);
    _skills.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}