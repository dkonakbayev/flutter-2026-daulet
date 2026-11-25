import '../../core/api/json_read.dart';

/// One entry of the nested `currencies` list: `{code, name, symbol}`.
class Currency {
  const Currency({required this.code, required this.name, this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    code: json.read<String>('code'),
    name: json.read<String>('name'),
    symbol: json.read<String?>('symbol'),
  );

  final String code;
  final String name;
  final String? symbol;

  Currency copyWith({String? code, String? name, String? symbol}) => Currency(
    code: code ?? this.code,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (symbol != null) 'symbol': symbol,
  };

  @override
  String toString() => symbol == null ? '$name ($code)' : '$name, $symbol';
}
