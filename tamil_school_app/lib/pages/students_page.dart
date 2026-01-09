import 'package:flutter/material.dart';
import '../main.dart'; // global api
import '../app_shell.dart';
import 'student_details_page.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];
  String _search = "";

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final batchId = 1;  // You will get this batchId from previous screens, for now let's hardcode it
      final data = await api.getStudents(batchId);

      setState(() {
        _students = data;
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
    return AppShell(
      title: "Students",
      selectedIndex: 1,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Search by name"),
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text("Error: $_error")))
            else
              Expanded(
              child: ListView.separated(
                itemCount: _students.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final name = student["full_name"]?.toString() ?? "-";
                  final admissionNo = student["admission_no"]?.toString() ?? "-";

                  return ListTile(
                    title: Text(name),
                    subtitle: Text("Admission No: $admissionNo"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentDetailsPage(student: student),
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
