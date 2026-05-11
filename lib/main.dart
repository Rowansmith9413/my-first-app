// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/skill_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SkillProvider()),
        ChangeNotifierProxyProvider<SkillProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, skillProvider, previousTasks) =>
              previousTasks!..updateSkillProvider(skillProvider),
        ),
      ],
      child: MaterialApp(
        title: '技能追踪器',
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}