import 'package:flutter/material.dart';

class StaleBanner extends StatelessWidget {
  const StaleBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: const Text('Saved data · no connection'),
    leading: const Icon(Icons.cloud_off),
    actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
  );
}
