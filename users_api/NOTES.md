# Notes

## Level 1: Postman first

### GET /users
- Status: 200 OK (check in Postman)
- Content-Type: application/json; charset=utf-8 (check Headers tab)
- Number of users: 10
- Shape: a JSON list `[ {...}, ... ]`

### GET /users/1
- A single JSON object `{ ... }`, same shape as one item of the list.
- Nested objects: `address` and `company`.
- Nested twice: `address.geo`.
- Nothing is null or absent in any of the 10 users. `website` is present
  everywhere, so treating it as `String?` is my decision, not something
  the data forces.

### GET /users/999
- Status: 404 Not Found
- Body: `{}` (an empty object, so there is nothing useful to decode)

### POST /users
- Status: 201 Created
- The server added: `"id": 11`. It echoed back name, username and email.

### GET /users?id=3
- Shape of the answer: a LIST with one user (starts with `[`), not an
  object like `/users/3`.

### Table: User

| Field    | JSON type | Dart type | Nullable? |
|----------|-----------|-----------|-----------|
| id       | number    | int       | no        |
| name     | string    | String    | no        |
| username | string    | String    | no        |
| email    | string    | String    | no        |
| phone    | string    | String    | no        |
| website  | string    | String?   | yes       |
| address  | object    | Address   | no        |
| company  | object    | record ({String name, String catchPhrase}) | no |

### Table: Address

| Field   | JSON type | Dart type | Nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### Table: Geo

| Field | JSON type | Dart type | Nullable? |
|-------|-----------|-----------|-----------|
| lat   | string    | double    | no        |
| lng   | string    | double    | no        |

### Table: Company

| Field       | JSON type | Dart type | Nullable? |
|-------------|-----------|-----------|-----------|
| name        | string    | String    | no        |
| catchPhrase | string    | String    | no        |
| bs          | string    | not stored in the model | no |


## Level 2: A model that survives bad JSON

- `as double` on `lat` throws:
  `type 'String' is not a subtype of type 'double' in type cast`.
- `"id": "1"` (a string) throws the same kind of error on `id`.
  The message names the field, which is a good failure.

## Level 3: The repository

- `grep` for `package:http` in `lib/` finds only `api_client.dart`,
  `user_repository.dart` and `main.dart` (the composition root, which
  creates `http.Client()`).
- Experiment: with the 404 line removed from `_check`, `getById(999)` gives
  `BadResponseException: users/999: type 'Null' is not a subtype of
  type 'int' in type cast`. The body `{}` decodes fine and `fromJson`
  fails on `id`. The error is still mine, but it points at the wrong
  cause. That is why the status is checked before the body.

## Level 4: The chain

- Deleting the `BadResponseException()` arm from the `switch` does not
  compile: the type `ApiException?` is not exhaustively matched. The
  sealed class makes the compiler check every error has a screen.
- A wrong host (`jsonplaceholder.typicode.co`) gives `SocketException`,
  then `NoConnectionException`, then the Offline view with Retry.

## Level 5: Two kinds of "no network"

- Airplane mode: the Offline view appeared in about N seconds.
  `SocketException` is immediate, the OS knows there is no route.
- Wi-Fi without internet: the Offline view appeared in about N seconds.
  Packets leave and never return, so the 10-second timeout fires
  (`TimeoutException`).
- Both become `NoConnectionException`, so the user sees the same
  screen. Only the waiting time differs.
- DevTools Network: the `/users` row has no status and takes about
  10 000 ms (`screenshot_timeout.png`). With the network back, the row
  shows 200 and its response body (`screenshot_200.png`).
- Double tap on Save: DevTools shows one POST with status 201. The
  button is disabled while `_saving` is true.
- (If the timeout screenshot was made on the emulator with the
  unreachable host `10.255.255.1` instead of a real dead Wi-Fi, say so
  here.)

# Notes for Practice 12

## Level 1: package verdicts

- shared_preferences: publisher flutter.dev (⟨check the verified badge⟩),
  last release ⟨month year⟩, platforms Android, iOS, web, macOS, Windows,
  Linux, ⟨N⟩ pub points, BSD-3, flutter/packages repo, no heavy dependencies.
  Verdict: the official package for small settings, use it.
- flutter_secure_storage: publisher ⟨name, verified?⟩, last release
  ⟨month year⟩, platforms Android, iOS, macOS, Windows, Linux (web is
  experimental), ⟨N⟩ pub points, BSD-3. Android minSdk is 23 since v10.
  Verdict: the standard Keychain/Keystore wrapper for tokens, use it.
- path_provider: publisher flutter.dev (⟨check the verified badge⟩), last
  release ⟨month year⟩, platforms ⟨all six⟩, ⟨N⟩ pub points, BSD-3,
  flutter/packages repo. Verdict: official, gives the Documents and
  Temporary directories.
- image_picker: publisher flutter.dev (⟨check the verified badge⟩), last
  release ⟨month year⟩, platforms ⟨Android, iOS, web, and others⟩, ⟨N⟩ pub
  points, BSD-3, flutter/packages repo. Verdict: official camera and
  gallery picker.
- permission_handler: publisher Baseflow (⟨verified?⟩), last release
  ⟨month year⟩, platforms ⟨Android, iOS, and others⟩, ⟨N⟩ pub points, MIT,
  ⟨N⟩ open issues vs ⟨recent commits⟩. Verdict: the de facto standard for
  the permission flow, third party, so I re-check it on every upgrade.
- url_launcher: publisher flutter.dev (⟨check the verified badge⟩), last
  release ⟨month year⟩, platforms ⟨all six⟩, ⟨N⟩ pub points, BSD-3,
  flutter/packages repo. Verdict: official, opens mailto:, tel: and https:.

 
 ### Carets and the lock file

- `http: ^1.6.0` accepts every version from 1.6.0 up to, but not
  including, 2.0.0 (so 1.6.1 and 1.9.0 are fine). It refuses 1.5.x
  because it is older than the floor, and 2.0.0 because a new major
  version may contain breaking changes.
- pub resolved `http` to 1.6.0 (the `http:` block in pubspec.lock).
- pubspec.lock is committed for an app so that every machine and the CI
  build with exactly the same versions. A library does not commit it,
  because its users resolve their own versions.
- `flutter pub outdated`: `cupertino_icons` is at 1.0.9 and 2.0.0 exists.
  It was not upgraded because 2.0.0 is a new major version outside the
  `^1.0.x` caret. pub reports it as "constrained to a version that is
  older than a resolvable version". Another example: `cross_file` stays
  at 0.3.5+5 although 0.4.0 exists, because the image_picker packages
  constrain it (for 0.x versions the caret treats a minor bump as breaking).
- Experiment: with `http: 1.6.0` (no caret) the lock pins exactly 1.6.0
  and `pub outdated` shows everything newer as unavailable. Caret restored.

## Level 2: A setting that survives a restart

- Dark mode and the city filter are read in main() with SharedPreferencesAsync,
after WidgetsFlutterBinding.ensureInitialized() and before runApp, 
so the first frame already has the right theme.
- Every read is nullable and defaulted with ?? (darkMode ?? false); 
the city stays a String?. No ! and no late.
- setDark and setCity call notifyListeners() first and write to disk after,
so the screen never waits for the disk.
- Experiment: when the read was moved into the model's constructor with a default of false,
the app showed one light frame and then switched to dark. 
That flash is why the read happens in main() before runApp. Restored.

## Level 3: A token that survives, safely
- `prefs.setString('token', ...)` would put the token in a plain, unencrypted
    file in the app folder (an XML file with the old API, a DataStore file with
    the async API on Android, a plist on iOS).
- Who can read it: anyone with a backup of the device (adb backup, cloud
  backup, an unencrypted iTunes backup), root or jailbreak access, or a cable
  to a device with debugging enabled.
- Secure storage puts the value in the iOS Keychain, or in encrypted storage
  whose key lives in the Android Keystore.
- Platform surprise 1 (iOS): Keychain items can survive an uninstall, so a
  reinstalled app on the same device may still find the old token.
- Platform surprise 2 (Android): Keystore keys can be invalidated when the
  lock screen is removed or changed, so the stored data may become unreadable
  and the app must cope with a missing token.
- `ApiClient` gets the `SecureStore` through its constructor and builds the
  headers with `if (await _store.readToken() case final t?)`. The repository
  never sees the token and the screens never see the header.
- Sign out calls `clear()`, then the stack is popped to the root and the login
  screen is shown. The token is never printed and never in shared_preferences.
  The debug-only "Copy token" button puts it on the clipboard without logging.
- Fake login: any password of 8+ characters returns `tok_${email.hashCode}`
  after one second; a short password returns `false` and the widget shows a
  SnackBar.

## Level 4: The offline list

- `UsersCache` writes `users.json` into `getApplicationDocumentsDirectory()`.
  The OS does not clear Documents on its own, and the path is never typed by
  hand.
- `getAll()` saves the fresh list on success and returns the saved list only on
  `NoConnectionException`. With nothing saved it rethrows, so a fresh install
  offline shows the honest Offline screen, not an empty list.
- The result is a record `({List<User> items, bool fromCache})`, so the screen
  shows the "Saved data · no connection" banner only when the data is old.
- A failed cache write is logged and does not break a successful load.
- Experiment: with the file in `getTemporaryDirectory()`, "Clear cache" in the
  emulator removed it. Offline, the list was gone and nothing threw. The OS
  kept the promise the directory name made. Documents restored.

## Level 5: A photo and a No

- Declared first: `CAMERA` in AndroidManifest.xml, `NSCameraUsageDescription`
  and `NSPhotoLibraryUsageDescription` in Info.plist. Without the plist key iOS
  kills the app the moment the camera is touched.
- The camera permission is requested at the tap on "Take photo", never in
  `initState`. All the statuses are handled in a switch with no default:
  granted, limited and provisional open the camera; denied shows a SnackBar
  that explains; permanentlyDenied and restricted show my own dialog whose
  "Open settings" button calls `openAppSettings()`.
- Android sequence observed: Don't allow, Don't allow, then the system dialog
  no longer appears and my dialog shows at once (⟨after N denials in my run⟩).
  "Open settings" lands on the app's permission page.
- iOS sequence: the system asks only once, so a single "Don't Allow" makes the
  status permanentlyDenied and only the Settings app can undo it. The fourth
  Photos state, besides granted, denied and restricted, is `limited` ("Selected
  Photos").
- `pickImage` returns null on Cancel: null check, `mounted`, then the update.
  The picked file is copied into Documents as `avatar.jpg`, the path is saved in
  shared_preferences, and the old image is evicted from the image cache because
  the path does not change. The photo survives a restart.
- `mailto:`, `tel:` (with `phoneDigits`) and `https://` go through `launchUrl`
  and the returned bool is checked: false shows "No app can open this".
  Android 11+ needs the `<queries>` block for the three schemes.
- Experiment: `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme returns
  false and nothing opens; with `https://` the browser opens.
- Nothing in the app uses `!` after a device await: a No or a Cancel simply
  returns, and the feature keeps working without the photo.

## Checks

- `flutter analyze`: No issues found!; `dart format .` run.
- `grep -r "package:http" lib/` lists `api_client.dart`, `user_repository.dart`
  and `main.dart` (the composition root that creates `http.Client()`).
- Screenshots in the repo root: `screenshot_offline_banner.png` and
  `screenshot_permission_dialog.png`.