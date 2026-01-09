import 'package:flutter/material.dart';
import '../app_shell.dart';

class StudentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailsPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final name = student["full_name"]?.toString() ?? "-";
    final admissionNo = student["admission_no"]?.toString() ?? "-";

    // Optional fields (show "-" if not provided by API)
    final batchName =
        student["batch_name"]?.toString() ?? student["batch"]?.toString() ?? "-";
    final branchCity = student["branch_city"]?.toString() ??
        student["branch"]?.toString() ??
        "-";
    final active = (student["active"] == true) ? "Active" : "Inactive";

    return AppShell(
      title: "Student Details",
      selectedIndex: 1,
      breadcrumbs: const [BreadcrumbItem("Students")],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Admission No: $admissionNo",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow("Branch", branchCity),
                    const Divider(height: 20),
                    _infoRow("Batch", batchName),
                    const Divider(height: 20),
                    _infoRow("Status", active),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.lock_outline, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Student details can only be edited in the Admin Dashboard.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
