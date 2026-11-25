import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import 'error_view.dart';
import 'loading_view.dart';

/// The four states of a list in one place: loading, error with Retry,
/// empty, data. Both lists use it.
class ListStateView extends StatelessWidget {
  const ListStateView({
    super.key,
    required this.loading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.empty,
    required this.child,
  });

  final bool loading;
  final ApiException? error;
  final bool isEmpty;
  final VoidCallback onRetry;
  final Widget empty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (loading && isEmpty) return const LoadingView();
    if (e != null) return ErrorView(e, onRetry: onRetry);
    if (isEmpty) return empty;
    return child;
  }
}
