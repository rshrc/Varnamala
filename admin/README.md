# Varnamala Admin

Next.js 16 administration workspace for editing and independently releasing
Varnamala language courses. It is designed for Vercel at
`admin.varnamala.org`, with Firebase Authentication and Firestore.

## Run locally

```bash
bun install
bun run dev
```

Copy `env.example` to the ignored `.env.local` file and obtain the development
values from the project owner. For local server access, use your approved Google
account with `gcloud auth application-default login`. The Next.js server uses
that local identity or a service account on Vercel.

## Firebase setup

1. Register a web app in Firebase project `words625-22704`.
2. Enable Google sign-in and authorize `admin.varnamala.org`.
3. Create a service account and put its values in Vercel's encrypted environment
   variables. Preserve private-key newlines as `\n`.
4. Deploy the root `firestore.rules` and indexes.
5. Sign in once as `rishieric91@gmail.com`, then bootstrap the account:

```bash
bun run bootstrap:admin
```

6. Seed all repository course JSON as one independent release per language:

```bash
bun run seed:courses
```

The bootstrap script, course seeding, and local Next.js server require the
ignored `.env.local` values plus approved Application Default Credentials.
Vercel requires the
server-only service-account variables from `env.example`; a private Admin key
must never be added to either the Flutter or browser app.

See the repository [development guide](../DEVELOPMENT.md) before requesting
access or working against Firebase.

## Verification

```bash
bun run typecheck
bun run lint
bun test
bun run build
```

## Architecture

- `app/`: routes and server-rendered surfaces
- `features/`: interactive product features
- `logic/`: pure typed domain rules and Zod schemas
- `services/firebase/`: browser auth and server-only Firestore boundaries
- `store/`: narrowly scoped Redux editor state

Each language is activated through `courseConfig/{language}` and has its own
history under `courseReleases/{language}/versions/{releaseId}`. A release can
never contain or activate more than one language.
