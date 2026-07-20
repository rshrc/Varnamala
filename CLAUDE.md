# Varnamala - Duolingo-Style Language Learning App

## Project Overview

**Varnamala** is a Flutter-based language learning app for thirteen Indian languages (Assamese, Bengali, Gujarati, Hindi, Kannada, Malayalam, Marathi, Nepali, Odia, Sanskrit, Tamil, Telugu, Urdu) inspired by Duolingo. The app uses Firebase for backend services and follows a clean architecture pattern.

---

## Architecture

### Layer Structure
```
lib/
├── application/       # State management (Providers)
├── core/              # Enums, extensions, utilities
├── courses/           # Loading + lookup for course content (the content
│   └── alphabets/     #   itself lives in assets/courses/, not in Dart)
├── di/                # Dependency injection (GetIt + Injectable)
├── domain/            # Domain models (Course, User, etc.)
├── routing/           # Auto Route configuration
├── service/           # App services (Preferences, locator)
└── views/             # UI layer organized by feature
```

### Key Patterns
- **State Management**: Provider + ChangeNotifier
- **Dependency Injection**: GetIt with Injectable annotations
- **Routing**: Auto Route with code generation
- **Models**: Freezed for immutable data classes with JSON serialization

---

## Firebase Services

| Service | Purpose | Status |
|---------|---------|--------|
| **Authentication** | Google Sign-In, user management | ✅ Implemented |
| **Firestore** | User data, scores, leaderboards | ✅ Implemented |
| **Analytics** | User behavior tracking | ✅ Implemented |
| **Crashlytics** | Error reporting | ✅ Implemented |
| **Messaging** | Push notifications | 🔧 Setup Done |
| **Storage** | Asset storage | 🔧 Setup Done |

### Firestore Collections
```
users/
├── {userId}/
│   ├── name: string
│   ├── email: string
│   ├── profileImage: string
│   ├── score: number (XP)
│   ├── streak: number
│   ├── lastStreakDate: timestamp
│   └── languages: array<string>
```

---

## Duolingo Features - Implementation Status

### ✅ Currently Implemented
- [x] Google Authentication
- [x] Course tree with progressive levels
- [x] Multiple choice questions
- [x] Translation exercises  
- [x] XP scoring system
- [x] Basic streak tracking
- [x] Leaderboard (top 30 users)
- [x] Character/alphabet practice
- [x] Shop UI (streak freeze, power-ups, outfits)
- [x] Multi-language support (13 languages x 15 courses x 6 levels x 9 questions)
- [x] Tap-a-word dictionary hints inside lesson sentences

### 🔴 Features Needed (Firebase-Based)

#### Gamification System
- [ ] **Leagues/Tiers** - Amethyst, Pearl, Ruby, Emerald, Diamond, etc.
  - Weekly league progression
  - Top 10 promotion, bottom 5 demotion
  - League-specific leaderboards
  
- [ ] **XP System Enhancement**
  - XP boost multipliers
  - Daily XP goals
  - XP for completing lessons, streaks, challenges

- [ ] **Streak System**
  - Streak freeze purchase/activation
  - Weekend amulet
  - Streak repair with gems
  - Streak milestone rewards (7, 30, 100, 365 days)

- [ ] **Hearts/Lives System**
  - Limited hearts for mistakes
  - Heart refill timers
  - Unlimited hearts (premium)

- [ ] **Gems/Lingots Currency**
  - Earn from achievements
  - Purchase power-ups
  - Streak freezes

#### Notifications & Reminders
- [ ] **Daily Practice Reminders**
  - Customizable reminder times
  - Smart notifications based on user patterns
  - Streak-at-risk warnings

- [ ] **Push Notification Types**
  - Lesson reminders
  - Streak maintenance
  - Friend activity
  - Achievement unlocks
  - League updates

#### Social Features
- [ ] **Friends System**
  - Add friends by username/email
  - Friend activity feed
  - Challenge friends

- [ ] **Achievements/Badges**
  - Lesson milestones
  - Streak achievements
  - Social achievements
  - Language-specific badges

#### Course Features
- [ ] **Skill Levels**
  - Crown levels (0-5 per skill)
  - Legendary skill unlock
  - Skill degradation over time

- [ ] **Learning Modes**
  - Stories mode
  - Speaking exercises (using flutter_tts)
  - Listening exercises
  - Fill-in-the-blank
  - Word matching (partially done)

---

## UI Theming Guidelines

### Color Palette (Differentiate from Duolingo)
```dart
// Primary: Teal/Cyan instead of Duolingo's green
const primaryColor = Color(0xff25D5C8);     // Current - Keep this
const primaryDark = Color(0xff1AB3A8);
const primaryLight = Color(0xff5DE8DC);

// Accent: Coral/Salmon for actions
const accentColor = Color(0xffFF6B6B);

// Success: Gold/Amber instead of green checkmarks
const successColor = Color(0xffFFD93D);

// League Colors - Use jewel tones
const amethystLeague = Color(0xff9B59B6);
const pearlLeague = Color(0xffF5F5F5);
const rubyLeague = Color(0xffE74C3C);
const emeraldLeague = Color(0xff27AE60);
const diamondLeague = Color(0xff3498DB);
```

### Design Principles
- Use rounded corners (16-24dp radius)
- Subtle shadows instead of heavy borders
- Gradient backgrounds for league cards
- Custom mascot "Mala" (peacock) as guide character

---

## Course Data Structure

Lesson content is **data, not code**. It lives in `assets/courses/<language>/` as
JSON — one directory per language, one file per course, plus a manifest and a
dictionary. Editing a lesson never means touching Dart.

```
assets/courses/tamil/
  manifest.json      course order, tree layout, icon + colour per course
  dictionary.json    romanized word -> English gloss (tap-a-word hints)
  notes.json         Mala's roadside asides, one per course
  basics.json        5-6 levels, 8-10 questions each
  greetings.json
  ...                15 courses per language
```

**Full schema, content rules and examples: [`docs/course-authoring.md`](docs/course-authoring.md).**

Loaded by `lib/courses/course_repository.dart`, which caches per language and
splices the learner's first name into the `{name}` placeholder at read time.

### Question types

Two are implemented and rendered by `lib/views/lesson/components/list_lesson.dart`:

| type | learner sees | learner picks |
|---|---|---|
| `multiple_choice` | a target-language prompt | the target-language reply that fits |
| `translate` | a target-language sentence | its English meaning |

Not yet implemented: fill-in-the-blank, word matching, listening, speaking.

### Tooling

```bash
ruby tool/validate_courses.rb             # schema, counts, answers, dictionary coverage
ruby tool/validate_courses.rb tamil       # one language
ruby tool/extract_vocabulary.rb tamil     # words used in lessons with no gloss yet
ruby tool/normalize_titles.rb --apply     # level titles to sentence case
ruby tool/generate_manifests.rb           # regenerate every manifest.json (and the palette)
ruby tool/generate_emblems.rb             # regenerate the language-picker emblems
flutter test test/course_repository_test.dart
```

---

## Development Commands

```bash
# Install dependencies
flutter pub get

# Generate code (routes, freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run on specific device
flutter run -d chrome
flutter run -d ios
flutter run -d android

# Clean build
flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point, Firebase init |
| `lib/views/app.dart` | Root widget with providers |
| `lib/routing/routing.dart` | Auto Route configuration |
| `lib/di/injection.dart` | GetIt DI setup |
| `lib/service/locator.dart` | AppPrefs, preferences |
| `lib/application/game_provider.dart` | Score/streak logic |
| `lib/domain/course/course.dart` | Course/Level/Question models |
| `lib/courses/course_repository.dart` | Loads course JSON from assets, caches per language |
| `lib/courses/word_dictionary.dart` | Word-tap gloss lookup |
| `assets/courses/<language>/` | Lesson content (see `docs/course-authoring.md`) |

---

## Firebase Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Leaderboard - all authenticated users can read
    match /users/{userId} {
      allow read: if request.auth != null;
    }
    
    // Leagues collection
    match /leagues/{leagueId} {
      allow read: if request.auth != null;
      allow write: if false; // Only cloud functions
    }
  }
}
```

---

## Agents Available

### Flutter/Firebase Expert
Location: `.claude/agents/FLUTTER_FIREBASE_EXPERT.md`
- Architecture guidance
- Firebase implementation
- State management patterns
- Performance optimization

### Course Generator Agent
Location: `.claude/agents/COURSE_GENERATOR_AGENT.md`
- Generate new language courses
- Create question sets
- Validate course structure
- Subject matter expertise for languages

---

## Contributing

1. Follow existing code patterns
2. Run `build_runner` after model changes
3. Test on both iOS and Android
4. Ensure Firebase rules are considered
5. Use the theming guidelines for UI consistency

