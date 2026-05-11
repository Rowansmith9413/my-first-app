// lib/screens/skill_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/skill.dart';
import 'add_task_screen.dart';
import '../widgets/task_tile.dart';

class SkillDetailScreen extends StatefulWidget {
  final Skill skill;
  const SkillDetailScreen({super.key, required this.skill});

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(widget.skill.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill.name),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.tasks.isEmpty) {
            return const Center(
              child: Text('暂无练习任务，点击 + 添加'),
            );
          }
          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return TaskTile(task: task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(skillId: widget.skill.id!),
            ),
          ).then((_) =>
              context.read<TaskProvider>().loadTasks(widget.skill.id!));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}