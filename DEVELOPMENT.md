# Varnamala development guide

This repository contains the Flutter learner app and the Next.js administration
app in `admin/`. Use a development Firebase project for ordinary local work.
Production access is exceptional and must be approved by Rishi.

## Request these details from Rishi

Send Rishi the Google account you will use and the languages you are working
on. Ask for:

1. The development Firebase project ID and browser configuration:
   `apiKey`, `authDomain`, `storageBucket`, `messagingSenderId`, and `appId`.
2. The generated Flutter configuration (`lib/firebase_options.dart`) and the
   platform file needed for your target: `android/app/google-services.json` or
   `ios/Runner/GoogleService-Info.plist`. These files remain ignored locally.
3. An ignored `admin/.env.local` file delivered directly. Never paste it into an
   issue, pull request, public chat, or commit.
4. Firebase IAM access to the development project if your work needs server-side
   reads or writes. Use the minimum role needed; normal contributors should not
   receive a production service-account key.
5. A Varnamala staff role and assigned language list if you need to test the
   moderator workspace. Sign in once, then ask Rishi to activate that account.
6. Access to Vercel or DNS only when your task explicitly includes deployment.

Rishi should never send a Firebase private key, Firebase CLI refresh token,
Vercel token, AWS secret, signing certificate, or Patreon credential through an
ordinary message. Use the team password manager or the hosting provider's
encrypted environment settings.

## Flutter app

Prerequisites: Flutter, Dart, Chrome, and a Firebase-enabled Google account.

```bash
flutter pub get
flutter test test/course_repository_test.dart
flutter run -d chrome
```

Flutter first loads the active per-language course release from Firestore and
falls back to `assets/courses/<language>/` if remote content is unavailable.
Never edit generated Firebase configuration to add an Admin private key.

## Admin app

Prerequisites: Bun, Node 22 or newer, Google Cloud CLI, and an approved Google
account.

```bash
cd admin
cp env.example .env.local
# Fill .env.local with the development values received securely from Rishi.
gcloud auth application-default login
bun install
bun run dev
```

Rishi must grant that Google account access to the development Firebase project
before the Application Default Credentials login can access Firestore. The
Firebase CLI bridge in `env.example` is an optional fallback; do not request or
use a production service-account key for ordinary development.

Before opening a pull request:

```bash
cd admin
bun run typecheck
bun run lint
bun test
bun run build --webpack
```

`bun run seed:courses` publishes every repository JSON file as an active,
independent language release. Confirm `FIREBASE_PROJECT_ID` before running it;
do not seed production casually.

## Files that must stay private

- `admin/.env.local` and every other `.env*` file except `env.example`
- Firebase service-account JSON and private keys
- Firebase CLI and Google Application Default Credential files
- Vercel, AWS, Patreon, signing, and CI tokens
- downloaded moderator proof files

Firebase browser configuration is visible in compiled web/mobile applications
and is not an authorization secret. Security comes from Firebase Authentication,
Firestore rules, API-key restrictions, server credentials, and staff claims.
