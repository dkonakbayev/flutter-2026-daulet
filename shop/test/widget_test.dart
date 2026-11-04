
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:shop/main.dart';
import 'package:shop/models/cart.dart';

void main() {
  testWidgets('Book shop displays books', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Cart(),
        child: const Shell(),
      ),
    );

    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Widgets All the Way Down'), findsOneWidget);
    expect(find.text('Null Safety for Humans'), findsOneWidget);
  });

  testWidgets('User can add a book to cart', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => Cart(),
        child: const Shell(),
      ),
    );

    // Find and tap the Add button.
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add').first);
    await tester.pump();

    // Check that the success message appears.
    expect(find.text('Added to cart'), findsOneWidget);

    // Check that the book was added.
    expect(find.text('Added'), findsOneWidget);
  });
}
