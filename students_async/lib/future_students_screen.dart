import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/loading_view.dart';
import 'widgets/error_view.dart';
import 'widgets/empty_view.dart';
import 'widgets/student_list.dart';

class FutureStudentsScreen extends StatefulWidget {
  const FutureStudentsScreen({super.key});

  @override
  State<FutureStudentsScreen> createState() => _FutureStudentsScreenState();
}

class _FutureStudentsScreenState extends State<FutureStudentsScreen> {
  final _api = FakeApi();

  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _api.fetchStudents();
  }

  void _retry() {
    setState(() {
      _studentsFuture = _api.fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FutureBuilder Students'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Switch(
            value: true,
            onChanged: (_) {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(error: snapshot.error!, onRetry: _retry);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return const EmptyView();
          }

          return StudentList(students: students);
        },
      ),
    );
  }
}
