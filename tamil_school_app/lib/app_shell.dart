import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/students_page.dart';
import 'pages/batches_page.dart';
import 'pages/exams_page.dart';

class BreadcrumbItem {
  final String label;

  /// If null => current page (not clickable)
  final VoidCallback? onTap;

  const BreadcrumbItem(this.label, {this.onTap});
}

class AppShell extends StatelessWidget {
  final String title;
  final int selectedIndex;
  final Widget body;

  /// Optional breadcrumbs shown under the AppBar
  final List<BreadcrumbItem> breadcrumbs;

  const AppShell({
    super.key,
    required this.title,
    required this.selectedIndex,
    required this.body,
    this.breadcrumbs = const [],
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),

        // Back on subpages; hamburger on root pages
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),

        // ✅ Always allow opening the menu, even on subpages
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open),
              tooltip: "Menu",
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: _AppDrawer(selectedIndex: selectedIndex),
      body: SafeArea(
        child: Column(
          children: [
            if (breadcrumbs.isNotEmpty) _BreadcrumbBar(items: breadcrumbs),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const _BreadcrumbBar({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.home_outlined, size: 18),
          const SizedBox(width: 8),
          for (int i = 0; i < items.length; i++) ...[
            _Crumb(items[i]),
            if (i != items.length - 1) ...[
              const SizedBox(width: 6),
              const Text("›", style: TextStyle(color: Colors.black54)),
              const SizedBox(width: 6),
            ]
          ],
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  final BreadcrumbItem item;

  const _Crumb(this.item);

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: item.onTap == null ? FontWeight.w700 : FontWeight.w600,
      color: item.onTap == null ? Colors.black87 : Colors.blue,
    );

    if (item.onTap == null) return Text(item.label, style: style);

    return InkWell(
      onTap: item.onTap,
      child: Text(item.label, style: style),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final int selectedIndex;

  const _AppDrawer({required this.selectedIndex});

  void _go(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Tamil School",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            const Divider(),
            ListTile(
              selected: selectedIndex == 0,
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text("Home"),
              onTap: () => _go(context, const HomePage()),
            ),
            ListTile(
              selected: selectedIndex == 1,
              leading: const Icon(Icons.people_outline),
              title: const Text("Students"),
              onTap: () => _go(context, const StudentsPage()),
            ),
            ListTile(
              selected: selectedIndex == 2,
              leading: const Icon(Icons.groups_outlined),
              title: const Text("Batches"),
              onTap: () => _go(context, const BatchesPage()),
            ),
            ListTile(
              selected: selectedIndex == 3,
              leading: const Icon(Icons.edit_calendar_outlined),
              title: const Text("Exams"),
              onTap: () => _go(context, const ExamsPage()),
            ),
          ],
        ),
      ),
    );
  }
}