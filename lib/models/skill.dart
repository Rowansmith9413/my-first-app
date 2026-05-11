// lib/models/skill.dart
class Skill {
  final int? id;
  final String name;
  final String icon; // 存储的是 IconData 的字符串表示，如 “stars”

  Skill({this.id, required this.name, required this.icon});

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as String,
    );
  }
}