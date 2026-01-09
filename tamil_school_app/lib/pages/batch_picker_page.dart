import 'package:flutter/material.dart';
import '../main.dart'; // global api
import '../app_shell.dart';

typedef OnBatchPicked = void Function(BuildContext context, Map<String, dynamic> batch);

class BatchPickerPage extends StatefulWidget {
  final String title;
  final int drawerIndex;
  final OnBatchPicked onPicked;

  const BatchPickerPage({
    super.key,
    required this.title,
    required this.drawerIndex,
    required this.onPicked,
  });

  @override
  State<BatchPickerPage> createState() => _BatchPickerPageState();
}

class _BatchPickerPageState extends State<BatchPickerPage> {
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
        _error = "$e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: widget.title,
      selectedIndex: widget.drawerIndex,
      breadcrumbs: [BreadcrumbItem(widget.title)],
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text("Error: $_error"))
                : ListView.separated(
                    itemCount: _batches.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final b = _batches[i];
                      return ListTile(
                        title: Text("${b["name"]} (${b["year"]})"),
                        subtitle: Text("${b["branch_city"]} • ${b["course_name"]}"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => widget.onPicked(context, b),
                      );
                    },
                  ),
      ),
    );
  }
}
