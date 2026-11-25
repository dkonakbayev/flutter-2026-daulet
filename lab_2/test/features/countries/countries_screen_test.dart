import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/features/countries/countries_model.dart';
import 'package:trip_planner/features/countries/countries_screen.dart';
import 'package:trip_planner/features/countries/fake_country_repository.dart';

void main() {
  testWidgets('error state with Retry, then data', (tester) async {
    final repo = FakeCountryRepository()..failWith = const ServerException(503);
    final model = CountriesModel(repo);
    await model.load();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: CountriesScreen()),
      ),
    );

    expect(find.textContaining('503'), findsOneWidget);
    repo.failWith = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('France'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('empty state has a sentence and an action', (tester) async {
    final model = CountriesModel(FakeCountryRepository());
    await model.search('nowhere');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: CountriesScreen()),
      ),
    );
    expect(find.text('No countries match your search.'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('France'), findsOneWidget);
  });
}
