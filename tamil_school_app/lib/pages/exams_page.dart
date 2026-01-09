import 'package:flutter/material.dart';
import '../main.dart'; // to access global `api`
import 'exam_results_page.dart';
import '../app_shell.dart';

class ExamsPage extends StatefulWidget {
  final Map<String, dynamic> batch;
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
        _exams = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  Future<void> _submitResults(int examId) async {
    // You will need to collect marks and remarks for each student
    final List<Map<String, dynamic>> results = []; // collect marks + remarks for each student

    try {
      final saved = await api.submitExamResults(examId, results);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved results for $saved students")),
      );
      _loadExams(); // reload exams after submitting
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving results: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchName = widget.batch["name"];
    final year = widget.batch["year"];
    final branchCity = widget.batch["branch_city"];

    return AppShell(
      appBar: AppBar(title: Text("Exams: $batchName")),
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

            if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              Expanded(child: Center(child: Text("Error: $_error"))),

            if (!_loading && _error == null)
              Expanded(
                child: ListView.separated(
                  itemCount: _exams.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    final title = exam["title"];
                    final examId = exam["id"];
                    final maxMarks = exam["max_marks"];

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

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
