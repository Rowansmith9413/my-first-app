// lib/screens/add_skill_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_provider.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({super.key});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _nameController = TextEditingController();
  String _selectedIcon = 'lightbulb'; // 默认图标字符串

  final List<String> _iconOptions = ['lightbulb', 'code', 'music_note', 'brush', 'fitness_center'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  IconData _getIconData(String str) {
    switch (str) {
      case 'lightbulb': return Icons.lightbulb;
      case 'code': return Icons.code;
      case 'music_note': return Icons.music_note;
      case 'brush': return Icons.brush;
      case 'fitness_center': return Icons.fitness_center;
      default: return Icons.stars;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新技能'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '技能名称',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Text('选择图标', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _iconOptions.map((icon) {
                return ChoiceChip(
                  label: Icon(_getIconData(icon)),
                  selected: _selectedIcon == icon,
                  onSelected: (selected) {
                    setState(() => _selectedIcon = icon);
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入技能名称')),
                  );
                  return;
                }
                await context
                    .read<SkillProvider>()
                    .addSkill(_nameController.text.trim(), _selectedIcon);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}