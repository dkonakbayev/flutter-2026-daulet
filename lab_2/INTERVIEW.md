# INTERVIEW

## Bug story
Symptom: in the release build the "Add trip" button did nothing, and the console was silent.
First guess: I thought the navigator route name was wrong.
What found it: Navigator.pushNamed<Trip> expects Route<Trip?>, but the router built MaterialPageRoute<dynamic>, so the type cast failed (app_router.dart).
Fix: the form route is created as MaterialPageRoute<Trip>. The test app_router_test.dart was red before the fix and green after.
Habit: I write the red test first and check the release build, not only debug.

## Design decision
Every resource has an interface with an Http and a Fake implementation, and only main.dart chooses one (USE_FAKES).
The alternative was models calling ApiClient directly.
That would have made the defence impossible without a network, and every test would need a MockClient.

## What I would do differently
REST Countries v3.1 was switched off in the middle of the project, and I had to rewrite the parser for v5.
Next time I would call the live API and save a real response before building any screen, and keep all parsing in one layer.