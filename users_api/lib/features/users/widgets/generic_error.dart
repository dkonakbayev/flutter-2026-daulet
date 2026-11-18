import 'package:flutter/material.dart';

import 'message_view.dart';

class GenericError extends StatelessWidget {
  const GenericError({super.key});

  @override
  Widget build(BuildContext context) => const MessageView(
    icon: Icons.error_outline,
    text: 'Could not read the server answer',
  );
}
