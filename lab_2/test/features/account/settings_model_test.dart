import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:trip_planner/features/account/settings_model.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('defaults when nothing is stored', () async {
    final s = await SettingsModel.load(SharedPreferencesAsync());
    expect(s.dark, isFalse);
    expect(s.defaultRegion, isNull);
  });

  test('dark mode and region survive a restart', () async {
    final prefs = SharedPreferencesAsync();
    final s = await SettingsModel.load(prefs);
    await s.setDark(true);
    await s.setDefaultRegion('Asia');

    final again = await SettingsModel.load(SharedPreferencesAsync());
    expect(again.dark, isTrue);
    expect(again.defaultRegion, 'Asia');
  });

  test('a photo path whose file is gone is dropped', () async {
    final s = await SettingsModel.load(SharedPreferencesAsync());
    await s.setPhoto('/nowhere/avatar.jpg');
    final again = await SettingsModel.load(SharedPreferencesAsync());
    expect(again.photoPath, isNull);
  });
}
