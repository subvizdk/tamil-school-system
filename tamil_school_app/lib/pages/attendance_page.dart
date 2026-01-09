import 'package:flutter/material.dart';
import '../main.dart'; // uses global `api`
import '../app_shell.dart';

class AttendancePage extends StatefulWidget {
  final Map<String, dynamic> batch;
  const AttendancePage({super.key, required this.batch});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool _loading = true;
  String? _error;

  late DateTime _selectedDate;

  List<Map<String, dynamic>> _students = []; // {student_id, student_name, status, note}

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _load();
  }

  String _dateStr(DateTime d) {
    final y = d.year.toString().padLeft(4, "0");
    final m = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "$y-$m-$day";
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final batchId = widget.batch["id"] as int;
      final dateStr = _dateStr(_selectedDate);

      final data = await api.getAttendance(batchId, dateStr);
      final students = (data["students"] as List).cast<dynamic>();

      setState(() {
        _students = students.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _loading = false;
      });
    }
  }

  void _setStatus(int index, String status) {
    setState(() {
      _students[index]["status"] = status; // "P", "A", "L"
    });
  }

  Future<void> _submit() async {
    final batchId = widget.batch["id"] as int;
    final dateStr = _dateStr(_selectedDate);

    // Only submit records that have a status chosen
    final records = _students
        .where((s) => s["status"] != null && (s["status"] as String).isNotEmpty)
        .map((s) => {
              "student_id": s["student_id"],
              "status": s["status"],
              "note": s["note"] ?? "",
            })
        .toList();

    try {
      final saved = await api.submitAttendance(batchId, dateStr, records);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance saved: $saved")),
      );
      await _load(); // refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchName = widget.batch["name"];
    final year = widget.batch["year"];
    final branchCity = widget.batch["branch_city"];

    return AppShell(
      title: "Attendance: $batchName",
      selectedIndex: 2,
      breadcrumbs: [
        BreadcrumbItem("Batches", onTap: () => Navigator.pop(context)),
        BreadcrumbItem("Attendance"),
      ],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text("$branchCity • $year")),
                TextButton(
                  onPressed: _pickDate,
                  child: Text("Date: ${_dateStr(_selectedDate)}"),
                ),
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
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = _students[index];
                    final name = s["student_name"] ?? "";
                    final status = s["status"];
                    return ListTile(
                      title: Text(name),
                      subtitle: Text("Status: ${status ?? '-'}"),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          _statusBtn(index, "P", "P", status == "P"),
                          _statusBtn(index, "A", "A", status == "A"),
                          _statusBtn(index, "L", "L", status == "L"),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: const Text("Submit Attendance"),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _statusBtn(int index, String label, String value, bool selected) {
    return OutlinedButton(
      onPressed: () => _setStatus(index, value),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? Colors.black12 : null,
        minimumSize: const Size(40, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: Text(label),
    );
  }
}