import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trip_planner/core/routes/app_router.dart';
import 'package:trip_planner/core/routes/app_routes.dart';
import 'package:trip_planner/features/trips/fake_trip_repository.dart';
import 'package:trip_planner/features/trips/trip.dart';
import 'package:trip_planner/features/trips/trip_form_screen.dart';
import 'package:trip_planner/features/trips/trips_model.dart';

void main() {
  test('the trip form route returns a Trip', () {
    final route = AppRouter.generate(
      const RouteSettings(name: AppRoutes.tripForm),
    );
    expect(route, isA<Route<Trip>>());
  });

  testWidgets('pushNamed<Trip> opens the form', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TripsModel(FakeTripRepository()),
        child: MaterialApp(
          onGenerateRoute: AppRouter.generate,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed<Trip>(AppRoutes.tripForm),
              child: const Text('add'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('add'));
    await tester.pumpAndSettle();
    expect(find.byType(TripFormScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
