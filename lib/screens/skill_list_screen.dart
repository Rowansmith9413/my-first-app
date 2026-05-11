// lib/screens/skill_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_provider.dart';
import '../models/skill.dart';
import 'add_skill_screen.dart';
import 'skill_detail_screen.dart';

class SkillListScreen extends StatefulWidget {
  final Skill? skill; // 如果传递了某个技能，则直接进入详情，否则显示列表
  const SkillListScreen({super.key, this.skill});

  @override
  State<SkillListScreen> createState() => _SkillListScreenState();
}

class _SkillListScreenState extends State<SkillListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SkillProvider>().loadSkills();
      if (widget.skill != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SkillDetailScreen(skill: widget.skill!),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的技能'),
      ),
      body: Consumer<SkillProvider>(
        builder: (context, provider, child) {
          if (provider.skills.isEmpty) {
            return const Center(child: Text('点击 + 添加第一个技能'));
          }
          return ListView.builder(
            itemCount: provider.skills.length,
            itemBuilder: (context, index) {
              final skill = provider.skills[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(child: Text(skill.icon)),
                  title: Text(skill.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('确认删除'),
                          content: Text('确定要删除「${skill.name}」吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.deleteSkill(skill.id!);
                                Navigator.pop(ctx);
                              },
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SkillDetailScreen(skill: skill),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSkillScreen()),
          ).then((_) => context.read<SkillProvider>().loadSkills());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}