import '../../core/api/json_read.dart';

/// The nested `name` object of REST Countries.
class CountryName {
  const CountryName({required this.common, required this.official});

  factory CountryName.fromJson(Map<String, dynamic> json) => CountryName(
    common: json.read<String>('common'),
    official: json.read<String>('official'),
  );

  final String common;
  final String official;

  CountryName copyWith({String? common, String? official}) => CountryName(
    common: common ?? this.common,
    official: official ?? this.official,
  );

  Map<String, dynamic> toJson() => {'common': common, 'official': official};
}
