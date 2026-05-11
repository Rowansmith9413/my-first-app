// lib/widgets/skill_card.dart
import 'package:flutter/material.dart';
import '../models/skill.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;
  const SkillCard({super.key, required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(child: Text(skill.icon)),
        title: Text(skill.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}