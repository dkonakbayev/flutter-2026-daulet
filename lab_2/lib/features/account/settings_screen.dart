import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../countries/countries_model.dart';
import '../countries/regions.dart';
import 'auth_model.dart';
import 'profile_photo.dart';
import 'settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    await context.read<AuthModel>().logout();
    await nav.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  void _setRegion(BuildContext context, String? region) {
    unawaited(context.read<SettingsModel>().setDefaultRegion(region));
    unawaited(context.read<CountriesModel>().filterRegion(region));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ProfilePhoto(),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: s.dark,
            onChanged: (v) => unawaited(s.setDark(v)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: s.defaultRegion,
            decoration: const InputDecoration(labelText: 'Default region'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All regions')),
              for (final r in Regions.all)
                DropdownMenuItem(value: r, child: Text(r)),
            ],
            onChanged: (v) => _setRegion(context, v),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.about),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
