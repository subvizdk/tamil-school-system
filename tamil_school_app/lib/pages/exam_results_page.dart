import 'package:flutter/material.dart';
import '../main.dart'; // global api
import '../app_shell.dart';

class ExamResultsPage extends StatefulWidget {
  final Map<String, dynamic> exam; // {id,title,exam_date,max_marks,...}
  const ExamResultsPage({super.key, required this.exam});

  @override
  State<ExamResultsPage> createState() => _ExamResultsPageState();
}

class _ExamResultsPageState extends State<ExamResultsPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _rows = []; // {student_id, student_name, marks, remarks}

  // controllers keyed by student_id
  final Map<int, TextEditingController> _marksCtrls = {};
  final Map<int, TextEditingController> _remarksCtrls = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _marksCtrls.values) {
      c.dispose();
    }
    for (final c in _remarksCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final examId = widget.exam["id"] as int;
      final data = await api.getExamResults(examId);

      final students = (data["students"] as List).cast<dynamic>();
      final rows = students.map((e) => Map<String, dynamic>.from(e)).toList();

      // init controllers
      for (final r in rows) {
        final sid = r["student_id"] as int;

        _marksCtrls.putIfAbsent(
          sid,
          () => TextEditingController(text: (r["marks"] ?? "").toString()),
        );
        _remarksCtrls.putIfAbsent(
          sid,
          () => TextEditingController(text: (r["remarks"] ?? "").toString()),
        );

        // update text if reload
        _marksCtrls[sid]!.text = (r["marks"] ?? "").toString();
        _remarksCtrls[sid]!.text = (r["remarks"] ?? "").toString();
      }

      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final examId = widget.exam["id"] as int;

    // Build payload: only include rows with marks entered
    final List<Map<String, dynamic>> results = [];

    for (final r in _rows) {
      final sid = r["student_id"] as int;
      final marksText = _marksCtrls[sid]?.text.trim() ?? "";
      final remarksText = _remarksCtrls[sid]?.text.trim() ?? "";

      if (marksText.isEmpty) continue;

      final marks = double.tryParse(marksText);
      if (marks == null) continue;

      results.add({
        "student_id": sid,
        "marks": marks,
        "remarks": remarksText,
      });
    }

    try {
      final saved = await api.submitExamResults(examId, results);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Results saved: $saved")),
      );
      await _load(); // refresh and persist
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.exam["title"]?.toString() ?? "Exam";
    final maxMarks = widget.exam["max_marks"]?.toString() ?? "";

    return AppShell(
      appBar: AppBar(title: Text("Results: $title")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("Max marks: $maxMarks")),
                TextButton(onPressed: _load, child: const Text("Reload")),
              ],
            ),
            const SizedBox(height: 8),

            if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              Expanded(child: Center(child: Text("Error: $_error"))),

            if (!_loading && _error == null)
              Expanded(
                child: ListView.separated(
                  itemCount: _rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final r = _rows[index];
                    final sid = r["student_id"] as int;
                    final name = r["student_name"]?.toString() ?? "";

                    return ListTile(
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: TextField(
                                  controller: _marksCtrls[sid],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Marks",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _remarksCtrls[sid],
                                  decoration: const InputDecoration(
                                    labelText: "Remarks",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: const Text("Submit Results"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
