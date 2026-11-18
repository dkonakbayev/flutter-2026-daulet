import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_model.dart';
import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  Future<void> _open(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await launchUrl(uri);
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No app can open this')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final site = user.website;
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(user.username),
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: Text(user.email),
            onTap: () =>
                _open(context, Uri(scheme: 'mailto', path: user.email)),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text(user.phone),
            subtitle: Text(user.phoneDigits),
            onTap: () =>
                _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
          ),
          if (site != null)
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(site),
              onTap: () => _open(context, Uri.parse('https://$site')),
            ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('${a.street}, ${a.suite}'),
            subtitle: Text('${a.city}, ${a.zipcode}'),
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: Text('${a.geo.lat}, ${a.geo.lng}'),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy token to clipboard'),
              onTap: () async {
                final token = context.read<AuthModel>().token;
                if (token == null) return;
                await Clipboard.setData(ClipboardData(text: token));
              },
            ),
        ],
      ),
    );
  }
}
