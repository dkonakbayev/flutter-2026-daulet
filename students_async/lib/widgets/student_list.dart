import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class StudentList extends StatelessWidget {
  final List<Student> students;

  const StudentList({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(student.name),
          subtitle: Text(student.group),
          trailing: Text(student.gpa?.toString() ?? '—'),
        );
      },
    );
  }
}
