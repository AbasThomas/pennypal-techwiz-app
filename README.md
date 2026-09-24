# Flutter competition foundation

A domain-neutral Flutter foundation with authentication, secure session restoration, routing, API infrastructure, and reusable UI primitives while the competition SRS is pending.

## Run it

1. Install Flutter and run `flutter pub get`.
2. Copy `.env.example` to the local, gitignored `.env` file and set the API URL:

   ```env
   API_BASE_URL=http://10.0.2.2:3000
   ```

3. Run `flutter run`.

For CI or environment-specific builds, a Dart define takes priority: `flutter run --dart-define=API_BASE_URL=https://api.example.com`. Use `10.0.2.2` for Android emulators, a LAN address for physical devices, and HTTPS for staging/production.

## Structure

`core/` contains API/configuration, errors, secure storage, router, theme, and validators. `features/auth/` owns authentication data, UI, controller, and providers. `shared/widgets/` contains generic reusable UI. When the SRS arrives, add features alongside `auth` using the same layout.

## Authentication

The app starts on Splash, restores a secure session, fetches `/auth/me`, and routes to Home or Login. Access and refresh tokens are stored only in `flutter_secure_storage`; `SharedPreferences` is for non-sensitive preferences. Dio attaches access tokens, refreshes after a 401, retries once, and clears the session if refresh fails.

Endpoint paths are centralized in `lib/core/constants/api_endpoints.dart`. Adjust backend request/response shapes in `features/auth/data/datasources/auth_remote_data_source.dart` once the backend contract is final.

## Add a feature or endpoint

Create `lib/features/<feature>/data` and `presentation`, then register routes centrally. Add an endpoint constant, expose it from a data source and repository, and handle failures through `ApiErrorHandler`. Run `flutter analyze` and `flutter test` before committing. Do not add domain-specific functionality until the SRS is available.
