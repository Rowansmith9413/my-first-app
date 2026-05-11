// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/skill_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'skill_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streak = 0;
  int _todayCompleted = 0;
  int _totalSkills = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  Future<void> _loadStats() async {
    final skillProvider = context.read<SkillProvider>();
    final taskProvider = context.read<TaskProvider>();
    await skillProvider.loadSkills();
    _totalSkills = skillProvider.skills.length;

    final completedTasks = await taskProvider.getAllCompletedTasks();
    _streak = _calculateStreak(completedTasks);

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    _todayCompleted = completedTasks
        .where((t) => t.completedAt != null && t.completedAt! >= startOfToday)
        .length;

    setState(() {});
  }

  int _calculateStreak(List<Task> tasks) {
    if (tasks.isEmpty) return 0;

    // 收集所有完成日期的 yyyy-MM-dd 字符串
    final Set<String> dateSet = {};
    for (final t in tasks) {
      if (t.completedAt != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(t.completedAt!);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        dateSet.add(key);
      }
    }
    if (dateSet.isEmpty) return 0;

    // 降序排序（最近的日期在前）
    final sortedDates = dateSet.toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final yesterdayKey = (() {
      final y = today.subtract(const Duration(days: 1));
      return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
    })();

    // 今天是否有完成记录
    bool hasToday = sortedDates.first == todayKey;
    // 昨天是否有完成记录
    bool hasYesterday = sortedDates.contains(yesterdayKey);

    int streak = 0;
    DateTime? checkDate; // 从哪一天开始往回检查

    if (hasToday) {
      // 如果今天已打卡，从今天开始算
      streak = 1;
      checkDate = today.subtract(const Duration(days: 1));
    } else if (hasYesterday) {
      // 今天没打卡，但昨天有打卡，从昨天开始算
      streak = 1;
      checkDate = yesterdayKey; // 这是一个字符串，我们需要 DateTime
      checkDate = DateTime(today.year, today.month, today.day - 1); // 简化，因为已知昨天有
    } else {
      // 今天和昨天都没打卡，连续天数为0
      return 0;
    }

    // 向前检查，每次减一天，直到 missing
    while (true) {
      final prevDate = checkDate!.subtract(const Duration(days: 1));
      final prevKey = '${prevDate.year}-${prevDate.month.toString().padLeft(2, '0')}-${prevDate.day.toString().padLeft(2, '0')}';
      if (dateSet.contains(prevKey)) {
        streak++;
        checkDate = prevDate;
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    // … 与之前完全一致，这里省略 UI 部分
    return Scaffold(
      appBar: AppBar(
        title: const Text('技能追踪器'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: '连续打卡', value: '$_streak 天'),
                    _StatItem(label: '今日完成', value: '$_todayCompleted 项'),
                    _StatItem(label: '技能总数', value: '$_totalSkills 个'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '你的技能',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<SkillProvider>(
                builder: (context, provider, child) {
                  if (provider.skills.isEmpty) {
                    return const Center(child: Text('还没有添加任何技能'));
                  }
                  return ListView.builder(
                    itemCount: provider.skills.length,
                    itemBuilder: (context, index) {
                      final skill = provider.skills[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(skill.icon)),
                        title: Text(skill.name),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SkillListScreen(skill: skill),
                            ),
                          ).then((_) => _loadStats());
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SkillListScreen()),
          );
          _loadStats();
        },
        icon: const Icon(Icons.format_list_bulleted),
        label: const Text('管理技能'),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}