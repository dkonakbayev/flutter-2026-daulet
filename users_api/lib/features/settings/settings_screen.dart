import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/auth_model.dart';
import '../users/users_model.dart';
import 'profile_screen.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>().items;
    final saved = s.city;
    final cities = <String>{
      for (final u in users) u.address.city,
      ?saved,
    }.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: s.dark,
            onChanged: s.setDark,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            initialValue: s.city,
            decoration: const InputDecoration(labelText: 'City filter'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('All cities'),
              ),
              for (final c in cities)
                DropdownMenuItem<String?>(value: c, child: Text(c)),
            ],
            onChanged: s.setCity,
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () async {
              final nav = Navigator.of(context);
              await context.read<AuthModel>().logout();
              nav.popUntil((r) => r.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
