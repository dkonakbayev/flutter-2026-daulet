# Practice 13 — Where Things Go

## Project Overview

This project demonstrates how to organize a Flutter application using a feature-first structure, separate application layers, and testable architecture.

The application loads users from a remote API, displays user information, and handles loading, error, and offline states.

## 1. Project Structure

The project is organized by features and responsibilities:

- `lib/core/` — shared application functionality, including API and storage.
- `lib/features/` — application features such as authentication, users, settings, and profile.
- `lib/features/users/widgets/` — reusable UI components for user screens.
- `test/` — unit and widget tests organized to mirror the `lib/` structure.
- `test/fakes/` — fake implementations used in tests.
- `tool/` — scripts for checking project layer rules.

## 2. Repository Pattern

The application uses the Repository Pattern to separate data access from business logic.

- `UserRepository` is an abstract interface.
- `HttpUserRepository` implements the interface and communicates with the remote API.
- `UsersModel` depends on the repository interface instead of a concrete implementation.
- `FakeUserRepository` provides test data without making real network requests.

This makes the application easier to test and maintain.

## 3. Dependency Injection

Dependencies are created in `main.dart`, which acts as the composition root.

The application creates the API client, storage, and HTTP repository, then injects the repository into `UsersModel`.

This keeps object creation separate from application logic.

## 4. Error Handling

The application handles different API errors:

- `NoConnectionException` — network connection problems.
- `NotFoundException` — requested resource was not found.
- `ServerException` — server-side errors.
- `BadResponseException` — invalid or unexpected response data.

Parsing errors such as `TypeError` and `FormatException` are converted into `BadResponseException` at the repository level.

Logging is used for debugging and cache-related errors.

## 5. Testing

Tests are written using Flutter Test and MockClient.

The test suite covers:

- JSON parsing of user data.
- Successful user loading.
- Network failure handling.
- HTTP 404 responses.
- HTTP 500 responses.
- Socket exceptions.
- Retry button behavior in the offline widget.

Tests use fake repositories and mocked HTTP responses, so they do not require a real API connection.

## 6. How to Run

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

Run all tests:

```bash
flutter test
```

Check code quality:

```bash
flutter analyze
```

Format the code:

```bash
dart format lib test
```

## 7. Conclusion

In this practice, the application was reorganized using a feature-first structure. The Repository Pattern and dependency injection were introduced to separate responsibilities and make the code easier to test.

Fake repositories, mocked HTTP requests, and widget tests were used to verify application behavior without relying on a real network connection.

## 8. Testing Results

The project was successfully tested.

**Test results:**
- Flutter tests: 8 tests passed.
- Static analysis: No issues found.
- All tests passed successfully.

**Commands used:**

```bash
flutter test
flutter analyze
```

**Final result:** The application passed all tests and static analysis checks.