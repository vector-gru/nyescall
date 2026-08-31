# NYESCALL — Flutter Project Setup

## Prerequisites

- Flutter 3.44+ (`flutter --version`)
- Dart 3.12+
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

---

## 1. Clone & install dependencies

```bash
git clone <your-repo-url>
cd nyescall
flutter pub get
```

---

## 2. Create a Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and create a new project named **nyescall**.
2. Enable the following services:
   - **Authentication** → Email/Password + Google Sign-In
   - **Firestore Database** → Start in production mode
   - **Firebase Storage**
   - **Firebase Cloud Messaging** (optional, for push notifications)

---

## 3. Connect Firebase to the app

```bash
flutterfire configure
```

This generates `lib/firebase_options.dart` with your real credentials.  
**Do not commit this file** — it is in `.gitignore`.

---

## 4. Deploy Firestore rules & indexes

```bash
firebase login
firebase use --add   # select your project
firebase deploy --only firestore
firebase deploy --only storage
```

---

## 5. Configure Bland AI API key

The API key is stored securely on-device via `flutter_secure_storage`.  
Add a Settings screen (or use the debug method below) to write it once:

```dart
// In a settings screen or debug view:
final blandService = BlandAiService();
await blandService.saveBlandApiKey('YOUR_BLAND_API_KEY');
```

---

## 6. Run the app

```bash
# iOS Simulator
flutter run -d iphone

# Android Emulator
flutter run -d android

# Release build (iOS)
flutter build ipa

# Release build (Android)
flutter build appbundle
```

---

## Project structure

```
lib/
├── core/
│   ├── constants/      # AppConstants, AppStrings
│   ├── errors/         # AppException, Failure
│   ├── router/         # GoRouter + MainShell
│   ├── theme/          # AppColors, AppTextStyles, AppTheme
│   └── utils/          # Extensions, Validators, Logger
├── features/
│   ├── auth/           # Landing, SignIn, SignUp, EmailConfirmation
│   ├── home/           # Dashboard + Subscription
│   ├── call/           # Place AI Call
│   ├── voices/         # Voice management
│   ├── billing/        # Plans + Payment
│   ├── organization/   # Institution profile + Team
│   └── staff/          # Staff registration
└── shared/
    ├── data/services/  # FirestoreService, BlandAiService, StorageService
    └── presentation/
        ├── providers/  # Service providers (Riverpod)
        └── widgets/    # Reusable UI components
```

---

## Code generation

If you modify any `@riverpod` / `@freezed` annotated files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## AI / API integrations

| Service | Purpose | Docs |
|---|---|---|
| **Bland AI** | Outbound AI calling engine | https://docs.bland.ai |
| **Firebase Auth** | Authentication (email + Google) | https://firebase.google.com/docs/auth |
| **Firestore** | Realtime database | https://firebase.google.com/docs/firestore |
| **Firebase Storage** | Voice samples, logos, staff photos | https://firebase.google.com/docs/storage |
| **FCM** | Push notifications (call status, renewals) | https://firebase.google.com/docs/cloud-messaging |

---

## Recommended next steps

1. Set up a **Cloud Function** webhook to receive Bland AI call status updates and write them back to Firestore.
2. Add a **Settings screen** for entering/updating the Bland AI API key.
3. Implement the **call history** tab under the Call screen.
4. Build the **voice recording** flow using the `record` package.
5. Add **push notifications** via FCM for call completion and subscription expiry alerts.
