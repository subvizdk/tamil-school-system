import 'package:flutter/material.dart';
import '../app_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _card(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: "Home",
      selectedIndex: 0,
      breadcrumbs: const [BreadcrumbItem("Students")],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _card(context, Icons.people, "Students", "View & manage students", () {
              Navigator.pushReplacementNamed(context, "/students");
            }),
            _card(context, Icons.group_work, "Batches", "Classes / groups by branch", () {
              Navigator.pushReplacementNamed(context, "/batches");
            }),
            _card(context, Icons.menu_book, "Courses", "Manage course list", () {
              Navigator.pushReplacementNamed(context, "/courses");
            }),
            _card(context, Icons.check_circle, "Attendance", "Mark daily attendance", () {
              Navigator.pushReplacementNamed(context, "/attendance_pick");
            }),
            _card(context, Icons.assignment, "Exams", "Enter marks & view results", () {
              Navigator.pushReplacementNamed(context, "/exams_pick");
            }),
          ],
        ),
      ),
    );
  }
}
