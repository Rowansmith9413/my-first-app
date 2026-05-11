// lib/models/task.dart
class Task {
  final int? id;
  final int skillId;
  final String title;
  final bool isCompleted;
  final int? completedAt; // 完成时的时间戳（毫秒）

  Task({
    this.id,
    required this.skillId,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  Task copyWith({bool? isCompleted, int? completedAt}) {
    return Task(
      id: id,
      skillId: skillId,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'skillId': skillId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      skillId: map['skillId'] as int,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      completedAt: map['completedAt'] as int?,
    );
  }
}