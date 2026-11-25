import 'package:flutter/material.dart';

/// Shown only when the list came from the offline cache.
class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: const Text('Offline · showing the last saved list'),
    leading: const Icon(Icons.cloud_off),
    actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
  );
}
