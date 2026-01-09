import 'package:flutter/material.dart';

import '../main.dart'; // global api
import '../app_shell.dart';
import 'attendance_page.dart';
import 'exams_page.dart';

class BatchesPage extends StatefulWidget {
  const BatchesPage({super.key});

  @override
  State<BatchesPage> createState() => _BatchesPageState();
}

class _BatchesPageState extends State<BatchesPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _batches = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await api.getBatches();
      setState(() {
        _batches = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openAttendance(Map<String, dynamic> batch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AttendancePage(batch: batch)),
    );
  }

  void _openExams(Map<String, dynamic> batch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExamsPage(batch: batch)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: "Batches",
      selectedIndex: 2,
      breadcrumbs: const [BreadcrumbItem("Batches")],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text("Error: $_error"))
                : ListView.separated(
                    itemCount: _batches.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final b = _batches[index];
                      final name = b["name"]?.toString() ?? "-";
                      final year = b["year"]?.toString() ?? "-";
                      final branchCity = b["branch_city"]?.toString() ?? "-";
                      final courseName = b["course_name"]?.toString() ?? "-";

                      return ListTile(
                        title: Text("$name ($year)"),
                        subtitle: Text("$branchCity • $courseName"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: "Exams",
                              icon: const Icon(Icons.assignment_outlined),
                              onPressed: () => _openExams(b),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => _openAttendance(b),
                      );
                    },
                  ),
      ),
    );
  }
}
