# Packages

Checked on pub.dev on 2026-11-25. Points are pub points (out of 160).

| Package | Publisher | Version · released | Platforms | Points | Dependencies | Verdict |
| --- | --- | --- | --- | --- | --- | --- |
| `http` | dart.dev | 1.6.0 · 2025-11-10 | all six | 160 | async, http_parser, meta, web | The Dart team's own client with `MockClient` for tests — the obvious choice for `ApiClient`. |
| `provider` | dash-overflow.net | 6.1.5+1 · 2025-08-19 | all six | 150 | collection, nested | The course's state tool: `watch` / `read` / `select` over `ChangeNotifier`, small and stable. |
| `shared_preferences` | flutter.dev | 2.5.6 · 2026-10-05 | all six | 160 | its platform implementations | Official key–value store for non-secret settings (dark mode, region, photo path). |
| `flutter_secure_storage` | steenbakker.dev | 11.2.0 · 2026-09-16 | all six | 160 | its platform implementations, meta | Keychain / Keystore-backed storage, the only place the token lives. |
| `path_provider` | flutter.dev | 2.1.6 · 2026-06-15 | Android, iOS, desktop | 160 | its platform implementations | Official way to find the documents directory for the offline cache and the photo. |
| `image_picker` | flutter.dev | 1.2.4 · 2026-10-06 | all six | 160 | its platform implementations | Official camera / gallery picker; returns `null` on Cancel, which we handle. |
| `permission_handler` | baseflow.com | 13.0.2 · 2026-09-04 | Android, iOS, Windows, web | 160 | its platform implementations, meta | Gives every camera status incl. `permanentlyDenied` and `openAppSettings()`. |
| `url_launcher` | flutter.dev | 6.3.3 · 2026-10-02 | all six | 160 | its platform implementations | Official way to open the Google Maps `https:` link; `launchUrl` returns the `bool` we check. |
| `package_info_plus` | fluttercommunity.dev | 10.2.2 · 2026-10-01 | all six | 150 | clock, ffi, http, meta, path, web, win32, … | Reads version and build number for the About screen; Flutter Community maintained. |
| `flutter_lints` (dev) | flutter.dev | 6.0.0 · 2025-05-27 | all six | 160 | lints | The recommended lint set; `flutter analyze` must report 0 issues with it. |
| `flutter_launcher_icons` (dev) | fluttercommunity.dev | 0.14.4 · 2025-06-10 | Android, iOS, desktop | 150 | args, image, yaml, … | Generates the adaptive Android icon and the iOS icons from one PNG; build-time only. |
| `flutter_native_splash` (dev) | jonhanson.net | 2.4.8 · 2026-05-29 | Android, iOS, web | 150 | image, xml, yaml, … | Generates the Android 12 splash and the iOS launch screen; build-time only. |
| `shared_preferences_platform_interface` (dev) | flutter.dev | 2.4.2 · 2026-03-25 | all six | 150 | plugin_platform_interface | Only for `InMemorySharedPreferencesAsync` in the settings tests. |

`pubspec.lock` is committed, so every build uses exactly these versions.
