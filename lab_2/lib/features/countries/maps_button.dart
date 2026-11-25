import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the country in Google Maps (an `https:` link).
class MapsButton extends StatelessWidget {
  const MapsButton(this.url, {super.key});

  final String url;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Could not open the map')));
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () => _open(context),
    icon: const Icon(Icons.map_outlined),
    label: const Text('Open in Google Maps'),
  );
}
