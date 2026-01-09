import 'package:flutter/material.dart';
import 'services/api_service.dart';

import 'pages/home_page.dart';
import 'pages/students_page.dart';
import 'pages/batches_page.dart';
import 'pages/courses_page.dart';
import 'pages/batch_picker_page.dart';
import 'pages/attendance_page.dart';
import 'pages/exams_page.dart';

void main() => runApp(const MyApp());

final api = ApiService();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamil School',
      home: const LoginPage(),
      routes: {
        "/home": (_) => const HomePage(),
        "/students": (_) => const StudentsPage(),
        "/batches": (_) => const BatchesPage(),
        "/courses": (_) => const CoursesPage(),

        "/attendance_pick": (_) => BatchPickerPage(
              title: "Pick Batch (Attendance)",
              drawerIndex: 4,
              onPicked: (context, batch) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendancePage(batch: batch),
                  ),
                );
              },
            ),

        "/exams_pick": (_) => BatchPickerPage(
              title: "Pick Batch (Exams)",
              drawerIndex: 5,
              onPicked: (context, batch) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExamsPage(batch: batch),
                  ),
                );
              },
            ),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await api.login(_username.text.trim(), _password.text);

    setState(() => _loading = false);

    if (!ok) {
      setState(() => _error = "Login failed (check username/password)");
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const Text("Logging in...")
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
