import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trip_planner/core/api/api_exception.dart';
import 'package:trip_planner/features/trips/fake_trip_repository.dart';
import 'package:trip_planner/features/trips/trips_model.dart';
import 'package:trip_planner/features/trips/trips_screen.dart';

Widget _app(TripsModel m) => ChangeNotifierProvider.value(
  value: m,
  child: const MaterialApp(home: TripsScreen()),
);

void main() {
  testWidgets('error state with Retry, then data', (tester) async {
    final repo = FakeTripRepository()..failWith = const NoConnectionException();
    final m = TripsModel(repo);
    await m.load();
    await tester.pumpWidget(_app(m));

    expect(find.textContaining('No connection'), findsOneWidget);
    repo.failWith = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Japan'), findsOneWidget);
  });

  testWidgets('delete asks first; Cancel keeps the trip', (tester) async {
    final m = TripsModel(FakeTripRepository());
    await m.load();
    await tester.pumpWidget(_app(m));

    await tester.tap(find.byType(PopupMenuButton<VoidCallback>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this trip?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Japan'), findsOneWidget);
    expect(m.items, hasLength(2));
  });
}
