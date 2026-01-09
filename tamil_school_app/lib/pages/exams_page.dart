import 'package:flutter/material.dart';

import '../app_shell.dart';
import '../main.dart'; // global api
import 'exam_results_page.dart';

class ExamsPage extends StatefulWidget {
  final Map batch;

  const ExamsPage({super.key, required this.batch});

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final batchId = widget.batch["id"] as int;
      final data = await api.getExams(batchId);

      setState(() {
        _exams = (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchName = widget.batch["name"]?.toString() ?? "";
    final year = widget.batch["year"]?.toString() ?? "";
    final branchCity = widget.batch["branch_city"]?.toString() ?? "";

    return AppShell(
      title: "Exams: $batchName",
      selectedIndex: 3,
      breadcrumbs: [
        BreadcrumbItem("Batches", onTap: () => Navigator.pop(context)),
        const BreadcrumbItem("Exams"),
      ],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("$branchCity • $year")),
              ],
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              Expanded(child: Center(child: Text("Error: $_error"))),
            if (!_loading && _error == null)
              Expanded(
                child: ListView.separated(
                  itemCount: _exams.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    final title = exam["title"]?.toString() ?? "";
                    final maxMarks = exam["max_marks"]?.toString() ?? "";

                    return ListTile(
                      title: Text(title),
                      subtitle: Text("Max marks: $maxMarks"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExamResultsPage(exam: exam),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
