import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}${Platform.pathSeparator}users.json');
  }

  Future<void> save(List<User> list) async {
    final f = await _file();
    await f.writeAsString(jsonEncode([for (final u in list) u.toJson()]));
  }

  Future<List<User>?> load() async {
    final f = await _file();
    if (!await f.exists()) return null;
    try {
      final data = jsonDecode(await f.readAsString()) as List<dynamic>;
      return [for (final j in data) User.fromJson(j as Map<String, dynamic>)];
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }
}
