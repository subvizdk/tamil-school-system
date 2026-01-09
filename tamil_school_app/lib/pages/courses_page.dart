import 'package:flutter/material.dart';

import '../app_shell.dart';
import '../main.dart'; // uses global api

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _courses = [];
  String _q = "";

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
      final data = await api.getCourses(q: _q.trim().isEmpty ? null : _q.trim());
      setState(() {
        _courses = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
      title: "Courses",
      selectedIndex: -1, // not in drawer currently
      breadcrumbs: const [BreadcrumbItem("Courses")],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Search courses",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) {
                setState(() => _q = v);
              },
              onSubmitted: (_) => _load(),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.search),
                  label: const Text("Search"),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() => _q = "");
                    _load();
                  },
                  child: const Text("Clear"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(child: Center(child: Text("Error: $_error")))
            else if (_courses.isEmpty)
              const Expanded(child: Center(child: Text("No courses found")))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _courses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final c = _courses[index];

                    final name = c["name"]?.toString() ??
                        c["title"]?.toString() ??
                        "-";
                    final active = (c["active"] == true);
                    final batchesCount = c["batches_count"] ?? c["batch_count"];

                    return ListTile(
                      title: Text(name),
                      subtitle: batchesCount != null
                          ? Text("Batches: $batchesCount")
                          : null,
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _StatusChip(active: active),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailsPage(course: c),
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

class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: active ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
      ),
      child: Text(
        active ? "Active" : "Inactive",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: active ? Colors.green[800] : Colors.grey[800],
        ),
      ),
    );
  }
}

class CourseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final name = course["name"]?.toString() ?? course["title"]?.toString() ?? "-";
    final active = (course["active"] == true) ? "Active" : "Inactive";
    final batchesCount = course["batches_count"] ?? course["batch_count"];

    return AppShell(
      title: "Course Details",
      selectedIndex: -1,
      breadcrumbs: [
        BreadcrumbItem("Courses", onTap: () => Navigator.pop(context)),
        BreadcrumbItem(name),
      ],
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
                      child: Icon(Icons.menu_book_outlined),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
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
                    _infoRow("Status", active),
                    const Divider(height: 20),
                    _infoRow("Batches", batchesCount?.toString() ?? "-"),
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
                        "Course details can only be edited in the Admin Dashboard.",
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
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
