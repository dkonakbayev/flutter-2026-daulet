import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String group;
  final String birthDate;

  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tiles = [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(name),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(email),
            ),
            ListTile(
              leading: const Icon(Icons.groups),
              title: const Text('Group'),
              subtitle: Text(group),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Date of birth'),
              subtitle: Text(birthDate),
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registration successful!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (constraints.maxWidth >= 600)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 4,
                  children: tiles,
                )
              else
                Column(children: tiles),
            ],
          );
        },
      ),
    ),
  );
}
