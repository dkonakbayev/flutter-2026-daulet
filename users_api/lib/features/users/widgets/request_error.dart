import 'package:flutter/material.dart';

import 'message_view.dart';

class RequestError extends StatelessWidget {
  const RequestError({super.key});

  @override
  Widget build(BuildContext context) => const MessageView(
    icon: Icons.block,
    text: 'The server refused this request',
  );
}
