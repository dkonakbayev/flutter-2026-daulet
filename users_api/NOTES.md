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