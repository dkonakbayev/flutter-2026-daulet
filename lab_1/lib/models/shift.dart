import 'dart:math';

import 'cause.dart';
import 'countdown.dart';

class Shift {
  const Shift({
    required this.id,
    required this.title,
    required this.cause,
    required this.startsAt,
    required this.slots,
    required this.place,
    List<String> volunteers = const [],
    this.online = false,
    this.notes,
    this.favourite = false,
  }) : _volunteers = volunteers;

  Shift.empty()
    : id = DateTime.now().microsecondsSinceEpoch.toString(),
      title = '',
      cause = Cause.environment,
      startsAt = DateTime.now().add(const Duration(days: 1)),
      slots = 10,
      place = '',
      _volunteers = const [],
      online = false,
      notes = null,
      favourite = false;

  static const length = Duration(hours: 3);

  final String id;
  final String title;
  final Cause cause;
  final DateTime startsAt;
  final int slots;
  final String place;
  final bool online;
  final String? notes;
  final bool favourite;
  final List<String> _volunteers;

  List<String> get volunteers => List.unmodifiable(_volunteers);

  int get taken => _volunteers.length;
  int get free => max(0, slots - taken);
  bool get isFull => free == 0;
  bool get isPast => startsAt.isBefore(DateTime.now());

  bool contains(String name) {
    final wanted = name.trim().toLowerCase();
    return wanted.isNotEmpty &&
        _volunteers.any((v) => v.toLowerCase() == wanted);
  }

  ({int taken, int free}) get places => (taken: taken, free: free);

  Countdown countdownAt(DateTime now) =>
      Countdown.of(startsAt, startsAt.add(length), now);

  Shift copyWith({
    String? title,
    Cause? cause,
    DateTime? startsAt,
    int? slots,
    String? place,
    List<String>? volunteers,
    bool? online,
    String? notes,
    bool? favourite,
  }) {
    return Shift(
      id: id,
      title: title ?? this.title,
      cause: cause ?? this.cause,
      startsAt: startsAt ?? this.startsAt,
      slots: slots ?? this.slots,
      place: place ?? this.place,
      volunteers: volunteers ?? _volunteers,
      online: online ?? this.online,
      notes: notes ?? this.notes,
      favourite: favourite ?? this.favourite,
    );
  }

  Shift signUp(String name) =>
      copyWith(volunteers: [..._volunteers, name.trim()]);

  Shift withdraw(String name) {
    final gone = name.trim().toLowerCase();
    return copyWith(
      volunteers: _volunteers.where((v) => v.toLowerCase() != gone).toList(),
    );
  }

  Shift toggleFavourite() => copyWith(favourite: !favourite);
}

List<Shift> sortedByDate(Iterable<Shift> shifts) {
  return shifts.toList()..sort((a, b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
    return a.startsAt.compareTo(b.startsAt);
  });
}
