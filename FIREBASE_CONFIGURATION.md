# Firebase configuration

Start with the repository [development guide](DEVELOPMENT.md). It lists the
exact details and access a contributor should request from Rishi.

## Use the development project

Ordinary development must use Varnamala's development Firebase project, not
production. After Rishi grants your Google account the minimum required access,
obtain these ignored client configuration files directly from him:

- `lib/firebase_options.dart` for every Flutter target
- `android/app/google-services.json` for Android
- `ios/Runner/GoogleService-Info.plist` for iOS
- `admin/.env.local` for the Next.js admin app

Alternatively, a maintainer with Firebase project access can regenerate the
Flutter files with the FlutterFire CLI. Do not change application IDs or bundle
IDs while doing so.

Firebase client configuration is included in compiled applications and is not a
private Admin credential. It stays outside Git so local and production projects
cannot be mixed accidentally. Access is enforced by Firebase Authentication,
Firestore rules, API-key restrictions, IAM, and server-only credentials.

## Never request or commit

- Firebase service-account JSON or private keys
- Google or Firebase CLI refresh tokens
- Vercel, AWS, Patreon, signing, or CI credentials
- production `.env` files

Server-side local development should use your own approved Google identity:

```bash
gcloud auth application-default login
```

Vercel receives its Firebase Admin credentials only through encrypted project
environment variables.
