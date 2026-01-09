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
        _batches = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: "Batches",
      selectedIndex: 2,
      breadcrumbs: const [BreadcrumbItem("Students")],
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
                      return ListTile(
                        title: Text("${b["name"]} (${b["year"]})"),
                        subtitle:
                            Text("${b["branch_city"]} • ${b["course_name"]}"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendancePage(batch: b),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
