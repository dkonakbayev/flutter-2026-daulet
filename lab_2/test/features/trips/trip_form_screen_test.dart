import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trip_planner/features/trips/fake_trip_repository.dart';
import 'package:trip_planner/features/trips/trip.dart';
import 'package:trip_planner/features/trips/trip_form_screen.dart';
import 'package:trip_planner/features/trips/trips_model.dart';

/// Opens the form from a home screen and records what it returned.
Future<List<Trip?>> _open(WidgetTester tester, TripsModel m) async {
  final results = <Trip?>[];
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: m,
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await Navigator.of(context).push<Trip>(
                MaterialPageRoute(builder: (_) => const TripFormScreen()),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  testWidgets('a clean form leaves without asking', (tester) async {
    await _open(tester, TripsModel(FakeTripRepository()));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a dirty form asks before leaving', (tester) async {
    await _open(tester, TripsModel(FakeTripRepository()));
    await tester.enterText(find.byType(TextFormField).first, 'Spain');
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('Save never asks and returns the created trip', (tester) async {
    final m = TripsModel(FakeTripRepository());
    final results = await _open(tester, m);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Spain');
    await tester.enterText(fields.at(1), 'esp');
    await tester.enterText(fields.at(4), '1500');
    await tester.scrollUntilVisible(
      find.text('Save'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsNothing);
    expect(results.single?.countryCode, 'ESP');
    expect(m.items.map((t) => t.countryName), contains('Spain'));
  });
}
