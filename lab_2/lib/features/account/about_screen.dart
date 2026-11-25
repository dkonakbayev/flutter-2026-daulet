import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/env.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // created once, not in build
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  static const _mode = kReleaseMode
      ? 'release'
      : kProfileMode
      ? 'profile'
      : 'debug';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('About')),
    body: FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) {
        final info = snapshot.data;
        final version = info == null
            ? '…'
            : '${info.version} (${info.buildNumber})';
        return ListView(
          children: [
            ListTile(title: const Text('Version'), subtitle: Text(version)),
            const ListTile(title: Text('Build mode'), subtitle: Text(_mode)),
            const ListTile(
              title: Text('Environment'),
              subtitle: Text(Env.name),
            ),
            const ListTile(title: Text('Trips host'), subtitle: Text(Env.host)),
            const ListTile(
              title: Text('Catalogue host'),
              subtitle: Text(Env.countriesHost),
            ),
            ListTile(
              title: const Text('Licences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Trip Planner',
                applicationVersion: version,
              ),
            ),
          ],
        );
      },
    ),
  );
}
