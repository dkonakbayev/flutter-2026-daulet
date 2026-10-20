import '../utils/format.dart';

sealed class Countdown {
  const Countdown();

  factory Countdown.of(DateTime start, DateTime end, DateTime now) {
    if (now.isBefore(start)) return Upcoming(start.difference(now));
    if (now.isBefore(end)) return Started(now.difference(start));
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

String countdownLabel(Countdown countdown) => switch (countdown) {
  Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
  Started() => 'In progress',
  Ended() => 'Ended',
};
