# A planted crash, read from its stack trace

**What was planted.** In `Trip.fromJson` the budget was read as

```dart
budget: json['budget'] as double,
```

MockAPI (and `jsonDecode`) give `3000` — an `int` — for a whole number.

**What the test printed** (`flutter test test/features/trips/trip_test.dart`):

```
type 'int' is not a subtype of type 'double' in type cast
package:trip_planner/features/trips/trip.dart 42:28  new Trip.fromJson
test\features\trips\trip_test.dart 18:20             main.<fn>
```

**How to read it**

| Part | Value | Meaning |
| --- | --- | --- |
| Message | `type 'int' is not a subtype of type 'double' in type cast` | a `TypeError` from an `as` cast: the JSON had an `int` where the code demanded a `double` |
| First own frame | `package:trip_planner/features/trips/trip.dart 42:28` | our package, not the SDK: file `lib/features/trips/trip.dart`, **line 42, column 28** — the `as double` |
| Function | `new Trip.fromJson` | the factory constructor that parses one trip |
| Next frame | `test/features/trips/trip_test.dart 18:20` | who called it: the `fromJson` test |
| Path | `lib/features/trips/trip.dart` → called from `test/features/trips/trip_test.dart` | |

**Fix.** Numbers are read as `num` and converted (R14):

```dart
budget: json.read<num>('budget').toDouble(),
```

In the app the same mistake would not crash: `HttpTripRepository._parse` turns a
`TypeError` / `FormatException` into `BadResponseException('trips: …')`, and the
list shows "Could not read the server answer" with Retry.
