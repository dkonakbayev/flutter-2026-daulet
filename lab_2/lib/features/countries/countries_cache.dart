import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'country.dart';

/// The last good list, in the documents directory (survives a restart;
/// the temporary directory may be wiped by the OS).
class CountriesCache {
  CountriesCache({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file() async {
    final dir = await _directory();
    return File('${dir.path}${Platform.pathSeparator}countries.json');
  }

  Future<void> save(List<Country> list) async {
    final f = await _file();
    await f.writeAsString(jsonEncode([for (final c in list) c.toJson()]));
  }

  /// null when there is no cache or it cannot be read.
  Future<List<Country>?> load() async {
    final f = await _file();
    if (!await f.exists()) return null;
    try {
      final data = jsonDecode(await f.readAsString()) as List<dynamic>;
      return [
        for (final j in data) Country.fromJson(j as Map<String, dynamic>),
      ];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
