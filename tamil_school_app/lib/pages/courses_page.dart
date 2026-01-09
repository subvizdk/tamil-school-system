import 'package:flutter/material.dart';
import '../app_shell.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      title: "Courses",
      selectedIndex: 3,
      body: Center(
        child: Text(
          "Courses screen\n(next: add /api/courses/ and show courses + batches count)",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
