# PennyPal

**A student finance companion for budgeting, savings goals, and financial learning.**

PennyPal helps students take control of their money. It lets them track income and expenses, set monthly budgets with per-category limits, create savings goals, read curated financial content, and get personalised guidance from an AI assistant — all from a single mobile app.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Environment Setup](#2-environment-setup)
3. [Firebase Setup](#3-firebase-setup)
4. [Installation](#4-installation)
5. [Running the App](#5-running-the-app)
6. [Project Structure](#6-project-structure)
7. [Key Features](#7-key-features)
8. [App Routes](#8-app-routes)
9. [Assumptions Made During Development](#9-assumptions-made-during-development)
10. [Deployment](#10-deployment)

---

## 1. Prerequisites

Make sure the following are installed before you begin.

| Tool | Minimum Version | Notes |
|---|---|---|
| Flutter SDK | 3.32.x | `sdk: ^3.12.1` in `pubspec.yaml` |
| Dart SDK | 3.12.1 | Bundled with Flutter |
| Android Studio / Xcode | Latest stable | For emulators / iOS simulator |
| Firebase CLI | 13.x+ | `npm install -g firebase-tools` |
| Node.js | 18 LTS+ | Required by Firebase CLI |
| Git | Any | Source control |

Verify your Flutter installation:

```bash
flutter doctor
```

All items should be ticked. Pay special attention to the Android toolchain and connected devices entries.

---

## 2. Environment Setup

PennyPal reads runtime configuration from a `.env` file bundled as a Flutter asset.

1. Copy the example file in the project root:

   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your values:

   ```env
   API_BASE_URL=http://10.0.2.2:3000
   GROQ_API_KEY=your_groq_api_key_here
   ```

   | Variable | Description |
   |---|---|
   | `API_BASE_URL` | Base URL for any REST calls. The default `10.0.2.2:3000` routes from the Android emulator to `localhost` on your development machine. Change to your server address for physical devices or production. |
   | `GROQ_API_KEY` | API key for the Groq AI assistant feature. Obtain one from [console.groq.com](https://console.groq.com). |

   > **Important:** Never commit your `.env` file. It is listed in `.gitignore`. Only `.env.example` (with placeholder values) should be tracked.

---

## 3. Firebase Setup

PennyPal uses Firebase as its primary backend. You need your own Firebase project to run the app.

### 3.1 Create a Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a new project.
2. Enable the following services:
   - **Authentication** — Email/Password provider
   - **Cloud Firestore** — in production mode
   - **Firebase Storage** — default bucket
   - **Firebase Cloud Messaging** (FCM) — for push notifications

### 3.2 Register Your App

Register both an **Android** and an **iOS** app inside your Firebase project.

- Android package name: `com.pennypal.app` (or whatever is in `android/app/build.gradle`)
- iOS bundle ID: match the value in `ios/Runner.xcodeproj`

### 3.3 Download Config Files

| File | Destination |
|---|---|
| `google-services.json` | `android/app/google-services.json` |
| `GoogleService-Info.plist` | `ios/Runner/GoogleService-Info.plist` |

The project already contains `lib/firebase_options.dart` generated via the FlutterFire CLI. If you are connecting to a **different** Firebase project, regenerate it:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### 3.4 Deploy Firestore Rules and Indexes

```bash
firebase login
firebase use --add          # select your project
firebase deploy --only firestore
firebase deploy --only storage
```

The security rules are in `firestore.rules` and `storage.rules`. Composite indexes are in `firestore.indexes.json`.

### 3.5 Firestore Collections

The app expects these top-level collections to exist (Firestore creates them on first write):

| Collection | Purpose |
|---|---|
| `users` | Basic user record created at registration |
| `userProfiles` | Extended profile with role, bio, institution |
| `transactions` | Income and expense entries |
| `budgets` | Monthly budget documents with category limits |
| `savingsGoals` | Savings goal tracking documents |
| `notifications` | In-app notifications per user |
| `feedback` | User-submitted feedback |
| `supportQueries` | Help/support ticket submissions |
| `learningContent` | Articles and learning materials (admin-managed) |

### 3.6 Admin Accounts

To promote a user to admin, update their Firestore documents directly in the Firebase console:

- `users/{uid}` → set `role` to `"admin"`
- `userProfiles/{uid}` → set `role` to `"admin"`

The app reads `role` from `userProfiles` first, then falls back to `users`.

---

## 4. Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd bootstrap_flutter

# 2. Install Flutter dependencies
flutter pub get

# 3. Set up your .env file (see Section 2)
cp .env.example .env
# then edit .env with your values

# 4. Confirm devices are available
flutter devices
```

---

## 5. Running the App

### Android

```bash
flutter run -d android
```

For the Android emulator, the default `API_BASE_URL=http://10.0.2.2:3000` maps correctly to your machine's localhost.

### iOS

```bash
flutter run -d ios
```

Make sure you have opened `ios/Runner.xcworkspace` in Xcode at least once to configure signing.

### Release build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 6. Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase & provider init
├── firebase_options.dart        # FlutterFire generated config
│
├── core/
│   ├── errors/                  # AppException and error handling
│   ├── notifications/           # NotificationService (FCM + local)
│   ├── router/                  # GoRouter configuration (app_router.dart)
│   ├── storage/                 # AuthStorage (secure) + PreferencesStorage
│   ├── theme/                   # AppTheme, PennyPalColors
│   └── widgets/                 # Shared widgets (AppIcon, etc.)
│
├── data/
│   ├── models/                  # FinanceTransaction, Budget, SavingsGoal
│   ├── repositories/            # FinanceRepository (Firestore + Storage)
│   └── finance_providers.dart   # Riverpod StreamProviders for financial data
│
└── features/
    ├── auth/                    # Login, register, password, profile
    ├── dashboard/               # Main student shell + Home/Money/Plan/Learn
    ├── more/                    # Profile, Settings, Reports, AI, Notifications
    ├── admin/                   # Admin dashboard (analytics, students, content)
    └── onboarding/              # First-launch onboarding screens
```

---

## 7. Key Features

| Feature | Description |
|---|---|
| Authentication | Email/password login and registration via Firebase Auth. Email verification required. |
| Transaction Tracking | Log income and expenses with category, payment mode, and optional receipt photo. |
| Monthly Budgets | Set an overall monthly limit and per-category sub-limits with configurable alert thresholds. |
| Savings Goals | Create goals with a target amount, monthly contribution, and deadline. Visual progress tracking. |
| Financial Learning | Browse curated articles and learning materials. Content is managed by admins. |
| AI Assistant | Chat with a Groq-powered AI for personalised financial guidance. |
| Push Notifications | FCM push notifications with a daily spending reminder. |
| Reports | Visual charts summarising spending patterns across categories and time periods. |
| Admin Console | Separate dashboard for admins covering usage analytics, student management, and learning content. |
| Offline Awareness | `connectivity_plus` detects network state; transactions carry a `syncStatus` field for future offline queue support. |
| Role-based Routing | `student` users land on `/home`; `admin` users are redirected to `/admin` automatically. |

---

## 8. App Routes

| Route | Access | Screen |
|---|---|---|
| `/splash` | Public | Splash / initialisation |
| `/onboarding` | Public | First-launch onboarding |
| `/login` | Public | Login |
| `/register` | Public | Registration |
| `/forgot-password` | Public | Forgot password |
| `/reset-password` | Public | Reset password |
| `/verify-email` | Authenticated | Email verification prompt |
| `/home` | Authenticated (student) | Main shell (Home, Money, Plan, AI, More) |
| `/add-income` | Authenticated | Add income form |
| `/add-expense` | Authenticated | Add expense form |
| `/transaction-detail` | Authenticated | Transaction detail view |
| `/learn` | Authenticated | Learning content feed |
| `/learn/:slug` | Authenticated | Article detail |
| `/goals` | Authenticated | Savings goals (alias for Plan) |
| `/reports` | Authenticated | Spending reports |
| `/ai-assistant` | Authenticated | AI chat assistant |
| `/notifications` | Authenticated | In-app notifications |
| `/profile` | Authenticated | Edit profile |
| `/settings` | Authenticated | App settings (currency, etc.) |
| `/change-password` | Authenticated | Change password |
| `/help` | Authenticated | Help screen |
| `/feedback` | Authenticated | Submit feedback |
| `/support` | Authenticated | Submit support request |
| `/about` | Authenticated | About screen |
| `/admin` | Admin only | Admin dashboard |

---

## 9. Assumptions Made During Development

### Architecture and State Management

- **Riverpod** was chosen as the state management solution. All providers are scoped at the root `ProviderScope`. The `sharedPreferencesProvider` is the only provider that requires an override at startup (injected in `main()`).
- The UI layer never calls Firestore or Firebase Storage directly. All data access goes through `FinanceRepository` or `FirebaseAuthDataSource`. This boundary is enforced by convention and noted with a comment in `finance_repository.dart`.
- Feature-first clean architecture is used: each feature module contains its own `data/`, `providers/`, and `presentation/` layers.

### Authentication and Roles

- Two roles are supported: `student` (default) and `admin`. No intermediate roles are planned.
- Role is stored as a lowercase string (`"student"` or `"admin"`) in both the `users` and `userProfiles` Firestore documents. The auth data source normalises it with `.trim().toLowerCase()` on every read to tolerate console edits.
- Email verification is required for full access. Users who register but do not verify are held at the verify-email screen.
- Account deactivation (soft-delete via `isDeactivated: true`) is handled at login time. A deactivated user is signed out immediately with an explanatory message.

### Financial Data Model

- Monetary values are stored as `double` in Firestore. No rounding to integer cents is performed. This is acceptable for the current student-use scale but would need revisiting for financial-grade precision at scale.
- `categoryId` is stored as a plain string (e.g., `"Food"`, `"Transport"`). There is a `categories` Firestore collection for admin-managed categories, but the student UI also allows free-text entry. The two are not strictly linked by a foreign key.
- The `month` field on a `Budget` document is a formatted string (`"YYYY-MM"`). Sorting and range queries rely on this lexicographic format.
- `syncStatus` on `FinanceTransaction` is present in the data model and Firestore schema to support a future offline-first queue, but the offline sync logic is not yet implemented. All transactions are currently written online only.

### Notifications

- Push notifications are delivered via Firebase Cloud Messaging. The device token is registered in Firestore under the user's profile on sign-in and removed on sign-out.
- A daily budget reminder is scheduled using `flutter_local_notifications` with timezone-aware scheduling (`flutter_timezone` + `timezone`). The reminder fires at a fixed time and does not adapt to user spending patterns.
- In-app notifications are stored in the `notifications` Firestore collection and consumed via a `StreamProvider`. They are not paginated; the full list is streamed. This is acceptable for typical student usage volumes.

### AI Assistant

- The AI assistant calls the **Groq API** (`groq_chat_service.dart`) directly from the Flutter client using `dio`. The API key is loaded from `.env` at runtime.
- No conversation history is persisted to Firestore. Each app session starts a fresh conversation context. Persisting chat history was considered out of scope for the initial release.
- The assistant is not rate-limited on the client side beyond what the Groq API enforces.

### Storage

- Receipt images are uploaded to Firebase Storage under `receipts/{userId}/{timestamp}_{filename}`. Only the download URL is stored in Firestore — the file itself is not cached locally.
- Profile pictures are stored at `profile_pictures/{userId}/`. Uploading a new picture does not delete the previous one from Storage (storage cost was not a concern for the project scope).
- Sensitive data (auth tokens) is stored with `flutter_secure_storage`. Non-sensitive preferences (currency symbol and code) use `shared_preferences`.

### Currency

- The default currency is Nigerian Naira (₦ / NGN). The user can change it in Settings. The selected currency is persisted to `shared_preferences` and applied globally via `AppCurrencyNotifier`.
- Currency conversion between currencies is not implemented. The app stores and displays raw amounts with the user-chosen symbol only.

### Platform Targets

- The primary target platforms are **Android** and **iOS**.
- Web is not a supported target, though `dartpad/web_plugin_registrant.dart` is present from the Flutter tool. No web-specific code or responsive layouts have been built.
- macOS and Windows targets have not been tested or configured beyond Flutter's default scaffold.

### Testing

- Automated tests were not part of the initial project scope. The `flutter_test` dev dependency is present for future use.
- The Firebase emulator suite was not integrated. Development was done against a live Firebase project with test data.

---

## 10. Deployment

### Firestore Rules and Indexes

```bash
firebase deploy --only firestore
```

### Storage Rules

```bash
firebase deploy --only storage
```

### Android Play Store

1. Create a keystore and configure `android/app/build.gradle` signing config.
2. Run `flutter build appbundle --release`.
3. Upload the `.aab` in Google Play Console.

### Apple App Store

1. Configure signing in Xcode (`ios/Runner.xcworkspace`).
2. Run `flutter build ios --release`.
3. Archive and distribute via Xcode Organizer or `xcrun altool`.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State management |
| `go_router` | ^14.2.0 | Declarative navigation |
| `firebase_core` | ^3.15.2 | Firebase initialisation |
| `firebase_auth` | ^5.7.0 | Authentication |
| `cloud_firestore` | ^5.6.12 | Primary database |
| `firebase_storage` | ^12.4.10 | File storage |
| `firebase_messaging` | ^15.2.10 | Push notifications |
| `flutter_local_notifications` | ^22.3.1 | Local / scheduled notifications |
| `flutter_secure_storage` | ^9.2.2 | Secure token storage |
| `shared_preferences` | ^2.3.2 | User preference storage |
| `flutter_dotenv` | ^5.1.0 | `.env` file loading |
| `dio` | ^5.4.3 | HTTP client (Groq API) |
| `fl_chart` | ^0.69.2 | Charts for reports and analytics |
| `image_picker` | ^1.1.2 | Receipt and profile photo selection |
| `lottie` | ^3.3.1 | Lottie animation support |
| `connectivity_plus` | ^6.1.4 | Network connectivity detection |
| `intl` | ^0.20.3 | Date and currency formatting |
| `hugeicons` | ^1.2.0 | Icon library |
| `timezone` | ^0.11.1 | Timezone-aware notification scheduling |
| `flutter_timezone` | ^5.1.0 | Device timezone detection |
