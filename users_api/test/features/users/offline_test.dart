import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:users_api/features/users/widgets/offline.dart';

void main() {
  testWidgets('Retry button calls onRetry', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Offline(
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('No connection'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));

    expect(retried, isTrue);
  });
}
