import 'package:flutter/material.dart';

import '../api/api_error_message.dart';
import '../api/api_exception.dart';
import 'message_view.dart';

/// The error state of every list. Exhaustive switch, no `default`.
class ErrorView extends StatelessWidget {
  const ErrorView(this.error, {super.key, required this.onRetry});

  final ApiException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final icon = switch (error) {
      NoConnectionException() => Icons.wifi_off,
      UnauthorizedException() => Icons.lock_outline,
      NotFoundException() => Icons.search_off,
      RequestException() => Icons.block,
      ServerException() => Icons.cloud_off,
      BadResponseException() => Icons.error_outline,
    };
    return MessageView(
      icon: icon,
      text: ApiErrorMessage.of(error),
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
