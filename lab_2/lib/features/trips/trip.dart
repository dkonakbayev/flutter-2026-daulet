import '../../core/api/json_read.dart';
import 'trip_status.dart';

/// One planned trip — an item of the user's collection on MockAPI.io.
class Trip {
  const Trip({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.rating,
    this.notes,
  });

  /// A new, unsaved trip (empty [id]); the form fills the rest.
  factory Trip.draft({
    String countryCode = '',
    String countryName = '',
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return Trip(
      id: '',
      countryCode: countryCode,
      countryName: countryName,
      startDate: start,
      endDate: start.add(const Duration(days: 7)),
      budget: 0,
      rating: 3,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
    id: json.read<String>('id'),
    countryCode: json.read<String>('countryCode'),
    countryName: json.read<String>('countryName'),
    startDate: _date(json, 'startDate'),
    endDate: _date(json, 'endDate'),
    budget: json.read<num>('budget').toDouble(),
    rating: json.read<num>('rating').toInt(),
    notes: json.read<String?>('notes'),
  );

  final String id;
  final String countryCode;
  final String countryName;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;

  /// 1–5: how much the user wants this trip.
  final int rating;
  final String? notes;

  bool get isNew => id.isEmpty;

  /// Length of the trip in days, both ends included.
  int get days => _day(endDate).difference(_day(startDate)).inDays + 1;

  TripStatus get status => statusOn(DateTime.now());

  TripStatus statusOn(DateTime today) {
    final d = _day(today);
    if (d.isBefore(_day(startDate))) return TripStatus.upcoming;
    if (d.isAfter(_day(endDate))) return TripStatus.past;
    return TripStatus.ongoing;
  }

  Trip copyWith({
    String? id,
    String? countryCode,
    String? countryName,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    int? rating,
    String? notes,
  }) => Trip(
    id: id ?? this.id,
    countryCode: countryCode ?? this.countryCode,
    countryName: countryName ?? this.countryName,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    budget: budget ?? this.budget,
    rating: rating ?? this.rating,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'countryCode': countryCode,
    'countryName': countryName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'budget': budget,
    'rating': rating,
    'notes': notes,
  };

  // UTC midnight: day arithmetic that ignores daylight-saving shifts
  static DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static DateTime _date(Map<String, dynamic> json, String key) {
    final text = json.read<String>(key);
    try {
      return DateTime.parse(text);
    } on FormatException {
      throw FormatException('field "$key": not a date: $text');
    }
  }
}
