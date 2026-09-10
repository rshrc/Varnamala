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
- [x] Leaderboard (top 30, per language)
- [x] Character/alphabet practice
- [x] Practice tab (flashcards, Match Madness, streak repair, outfits)
- [x] Multi-language support (13 languages x 16 courses)
- [x] Tap-a-word dictionary hints inside lesson sentences
- [x] First words: a 60-word picture course before the sentences, all 13 languages
- [x] Typed answers judged on the word, not its spelling

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

### Colour Themes

Six themes, each shipping a light and a dark build. Palette and light/dark are
**independent** axes: picking "Marigold" does not also decide day or night.
Five are taste (Peacock, Marigold, Emerald, Amethyst, Crimson); "High contrast"
is a functional option for low vision, glare and cheap screens.

`lib/views/theme_palette.dart` holds the whole system:

- `AppPalette` describes a theme as **hue relationships** (primary, secondary,
  neutral, plus semantic hues) rather than a list of hex codes. Adding a palette
  is a handful of numbers appended to `appPalettes`.
- `buildAppTheme(palette, brightness)` derives every colour at fixed lightness
  targets and returns the `ThemeData`.
- `VarnamalaColors` is a `ThemeExtension` carrying the roles Material has no
  slot for (`info`, `success`, `warning`, `danger`, `violet`, `shadowTint`,
  `pathGradient`). `context.appSuccess` and friends read from it, so widgets
  never name a palette.

Rules when touching colour:

- **Never** hardcode a colour in a widget. Use `context.app*` or
  `Theme.of(context).colorScheme`. A `CustomPainter` has no context, so pass
  colours into its constructor (see `SplashBackgroundPainter`).
- `success` stays green and `danger` stays red in every palette, and the two are
  kept apart in *lightness* as well as hue, so "right" and "wrong" survive both
  a theme change and colour blindness.
- Warm hues (roughly 25-100 degrees) stay bright and take dark text; dragged
  dark enough for white text they just turn brown. `_isLuminousHue` handles it.
- **Course node colours come from the theme, not the course JSON.** The
  `"color"` field in each manifest is legacy and no longer drawn: nodes take
  their colour from `VarnamalaColors.courseColor(pathIndex)`, which fans hues
  around the palette's own hue. Anything that colours the course path must go
  through the palette, or changing theme leaves the main screen unchanged.
- Light-mode accents sit darker than the palette's headline colours: they are
  small marks on a near-white card, and amber and green have to come a long way
  down to clear 3:1 there. The large surfaces carry the brightness instead.
- `test/theme_contrast_test.dart` checks **every palette in both modes** for
  WCAG contrast. A new palette that fails it does not ship.

### Responsive Layout

The app is drawn as a phone-width column; wider windows get *space around* that
column, never a stretched version of it. `lib/core/responsive.dart` owns the
breakpoints (`Breakpoint.compact/medium/expanded/large`), the content-width caps
(`ContentWidth.column/path/feed/grid`), and `ContentBounds`, which centres a
screen's content and is a no-op on a phone.

- Wrap any new full-screen content in `ContentBounds` rather than letting it
  fill the window.
- Navigation is a bottom bar up to `medium` and a `NavigationRail` from
  `expanded` up; both read the same `homeDestinations` list.
- Prefer `SliverGridDelegateWithMaxCrossAxisExtent` over a fixed
  `crossAxisCount`, so grids gain columns instead of inflating tiles.
- Snackbars are floating, and `SnackBarWidthCap` (wired in under
  `MaterialApp.builder`) caps them at the reading column on anything wider than
  a phone — otherwise four words stretch across a desktop. Don't set `width` or
  `behavior` at a call site; the cap is global so new call sites inherit it.

### Leagues are per language

A league is a board of people learning **the same language**. Before that, one
global board ranked everybody on XP earned in any language, so a Hindi learner's
grind outranked the people actually learning Tamil.

- `users/{uid}` carries `leagueByLanguage` and `leagueXpByLanguage` maps
  alongside the original account-wide `league` and `leagueXp`, which stay as the
  fallback and the migration source.
- `LeaderboardEntry.leagueFor` / `.leagueXpFor` read the map and fall back to
  the account-wide values, so an account that has not opened the app since the
  split still shows its real tier rather than looking demoted to Bronze.
- The board query filters `where('languages', arrayContains: language)`
  **server-side**. Filtering a global top-300 slice afterwards would leave a
  small language's board nearly empty while excluding its active learners.
  That needs the composite index in `firestore.indexes.json` - deploy it with
  `firebase deploy --only firestore:indexes` or the leaderboard throws.
- `GameProvider.languageLeagueMigration` runs once per account on launch. It
  carries the **tier to every language** the learner already has, and the
  **XP to exactly one** - the language they were studying. Crediting XP
  everywhere would put a Hindi learner's total on the Tamil board. It also
  backfills `languages` from `preferredLanguage`, because an account with an
  empty array would vanish from every board.
- **Maintainers are kept off the boards.** `excludedFromLeagues` on the user
  document, set with `bun run admin/scripts/exclude-from-leagues.ts <email>`
  (`--list` to see who, `--include` to undo). A flag rather than a list of
  addresses in the app, because the web bundle is public and hardcoding staff
  emails there would publish them.
- XP writes carry their language: `awardXP(..., language: course.language)`.
  Anything new that awards XP must pass one, or it falls back to the learner's
  stored `preferredLanguage`.

### Speech: why the accent is wrong, and what fixes it

`SpeechService` picks a voice **per language, per utterance**, and every
`SpeakButton` offers normal and slow playback. It used to pick one Indian
English voice once for the whole app, so Kannada, Tamil and Hindi were read by
the same English reader.

That is only half the problem, and the remaining half is content, not code:

**Lesson text is romanized.** `akki`, `neeru`, `vanakkam` are Latin letters. An
English voice applies English vowels to them, which is the accent you hear. A
native voice does not automatically fix it - a `kn-IN` engine handed Latin text
will usually read it as English too, or refuse.

Genuinely fixing pronunciation needs the **native script** to reach the engine.
Three ways, in increasing order of cost:

1. **Author it.** Add a `script` field beside `word` in `words.json` - 60 words
   x 13 languages. Cheap, exact, and needs a native-speaker pass. It would also
   let the course *show* the real script, which learners want.
2. **Transliterate at runtime.** Brahmic scripts are code-point aligned
   (Devanagari U+0900, Bengali U+0980, Kannada U+0C80 ...), so one
   romanization-to-Devanagari mapping plus an offset covers eight of the nine
   script families. Tamil has a smaller consonant inventory and Urdu is
   Perso-Arabic, so both need their own path.
3. **Bundle recordings.** Perfect, and the only option that fixes prosody, but
   it is 780 audio files before a single sentence is covered.

Whichever lands, keep the fallback: `SpeechService.hasNativeVoice` reports
whether the device can actually read the language, because Kannada and Odia
voices are common on Android and rare in desktop browsers. Native script sent
to a device with no matching voice is worse than romanization, not better.

### Answer feedback sounds

The strike lands instantly and the ring is gone inside half a second - a miss
in under 300ms, a hit in about 500 - against originals that ran one to three
and a half seconds and varied by seven LUFS, so a verdict was still playing
while the learner answered the next exercise.

Correct **rises and is bright** (~1400Hz), wrong **falls and is dark**
(~170Hz). The contour carries the verdict, not the timbre, so it survives a
cheap phone speaker. The miss also peaks 3dB lower: a mistake sends you back
for practice, it does not tell you off.

They are synthesised, not sampled - `ruby tool/generate_sounds.rb` (needs
ffmpeg). What keeps them from sounding like a beep is written up at the top of
that file: inharmonic partials, per-partial decay rates, a noise transient for
the mallet, and a short tail.

### Answer feedback

Checking an answer has to *land*. Three channels fire together, and all three
matter — a learner who has one of them switched off (silent phone, colour
blindness, no haptics) still gets the verdict:

- **Sound and haptics.** `lib/views/lesson/lesson_screen.dart` calls
  `AudioController` and `HapticFeedback` the moment `submit()` returns. This
  was wired only into the legacy renderer and Match Madness for a long time,
  so the lessons everyone actually plays checked answers in silence.
- **The answer itself.** Exercise views take an `ExerciseEvaluation?`
  (`lib/views/lesson/exercises/exercise_evaluation.dart`) — null while
  answering, set once checked — and paint the verdict onto the thing the
  learner touched: the chosen tile goes green or red, and on a miss the right
  answer lights up too. **Any new exercise view must accept it.** Fading the
  whole exercise out is not feedback; it reads as "disabled".
- **The band.** `InteractiveFeedbackPanel` grows in under an `AnimatedSize` so
  the footer does not jump under a thumb, carries Mala, and rotates its wording
  off a hash of the exercise id rather than a `Random`, so it does not reshuffle
  between rebuilds of the same frame.

The CHECK/CONTINUE button is a `ChicletAnimatedButton`, not a flat one. The
press is part of the feel.

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
assets/courses/
  concepts.json      the 60 shared word-course ideas: English label + picture
  tamil/
    manifest.json    course order, tree layout, icon + colour per course
    dictionary.json  romanized word -> English gloss (tap-a-word hints)
    notes.json       Mala's roadside asides, one per course
    words.json       "schema": 2 - 5 levels, 12 words each, no sentences
    basics.json      5-6 levels, 8-10 questions each
    greetings.json
    ...              16 courses per language
```

**Two schemas.** `words.json` is the First words course: bare vocabulary
against pictures, marked `"schema": 2`. The other fifteen teach sentences and
carry no `schema` field. They are built by different factories
(`VocabularyExerciseFactory` and `CourseExerciseFactory`) and validated by
different branches of `tool/validate_courses.rb`.

**First words comes first, and is unlocked alongside Basics.** Learners were
being asked to assemble sentences out of vocabulary nobody had taught them.
`kFreeCourseCount` in `lib/views/courses/course_tree.dart` opens both from the
first launch.

**Firestore is the live source; bundled JSON is the fallback.** All 13
languages are on an active release (`courseConfig/<language>.activeReleaseId`),
so `_remoteContent` wins and **editing this repo does not reach users until the
release is republished**:

```bash
cd admin
bun run scripts/show-releases.ts                 # what every language serves
bun run scripts/publish-release.ts --dry-run     # print, write nothing
bun run scripts/publish-release.ts               # publish + activate all 13
bun run scripts/publish-release.ts tamil         # one language
```

A course in the manifest with no file yet is skipped by the publisher and
dropped by the app, which is how First words rolls out one language at a time.
Both loaders tolerate a missing course file; neither tolerates a release with
no courses at all, which falls back to bundled JSON.

**Deploying the web build.** `index.html` and `flutter_service_worker.js` are
served `no-cache` (`firebase.json`). Without that, `index.html` inherits
Firebase's default `max-age=3600` and returning browsers boot the previous app
shell for an hour after a deploy - new content against old code, which locks
courses that should be open.

**Inserting a course ahead of existing progress.** `pathUnlockedThrough` reads
the watermark off the *last completed* course, never the first unfinished one.
Reading it the other way means a new course at the head of the path re-locks
every course a learner has already finished — and because a node checks its
lock before its completion, their finished nodes stop opening at all.

**Full schema, content rules and examples: [`docs/course-authoring.md`](docs/course-authoring.md).**

Loaded by `lib/courses/course_repository.dart`, which caches per language and
splices the learner's first name into the `{name}` placeholder at read time.

### Loanwords, names, and what can become a question

Roughly 7% of every dictionary is entries that gloss to themselves — English
loanwords (`filter -> filter (coffee)`, `bus -> bus`), proper names, months and
place names. They **belong** in the dictionary, because a learner reading a
sentence still wants the tap-a-word hint.

They must never become questions. Asking a Kannada learner to type "filter", or
to match "bus" with "bus", tests nothing about Kannada. `glossTeachesNothing`
in `lib/courses/word_dictionary.dart` is the single gate for this, and both the
exercise factory and Match Madness consult it. Anything new that generates
questions from the dictionary must consult it too.

Run `ruby tool/find_untranslated_glosses.rb` to see the share per language.

### Question types

Course JSON authors two, and the factories turn them into varied interactions
at load time rather than the JSON naming each one:

| type | learner sees | learner picks |
|---|---|---|
| `multiple_choice` | a target-language prompt | the target-language reply that fits |
| `translate` | a target-language sentence | its English meaning |

`CourseExerciseFactory` derives choice, word bank, sentence order, fill-blank
choice and fill-blank text from those. `VocabularyExerciseFactory` derives
picture-to-word, word-to-picture, listen-to-picture and type-the-word from
`words.json`.

**No character arranging.** Dragging graphemes into a word was generated with
exactly the answer's letters and no decoys, so it was a jigsaw rather than
recall. It was removed; arranging *words* into a sentence does the real job.

Not yet implemented: word matching, speaking.

### Typed answers are judged on the word, not the spelling

Romanized Indian languages have no single correct spelling — *dhanyavaad*,
*danyavad* and *dhanyavad* are one word written by three people — so an exact
match tests typing rather than language. `lib/core/answer_similarity.dart` is
the single gate, in two layers:

1. `romanizationKey` folds the spellings that stand for one sound (aspirates,
   doubled letters, vowel length, `v`/`w`, Tamil's `zh`). Equal keys mean the
   same answer, and the learner is told nothing — they did not misspell it.
2. Anything left is measured: bigram cosine **and** a length-scaled edit
   budget, both of which must pass. A key under five characters gets no
   budget at all, because in a short word one substitution is usually a
   different word.

The dictionary argument is the safety gate and matters more than the
thresholds: a typed word the language actually teaches, with a meaning of its
own, is never accepted as a misspelling of another. *mane* (house) must not
swallow *mana* (mind). Anything that judges typed input must go through
`judgeTypedAnswer`, and `test/answer_similarity_test.dart` is where minimal
pairs go — over-accepting is worse than being strict.

### Tooling

```bash
ruby tool/validate_courses.rb             # schema, counts, answers, dictionary coverage
ruby tool/validate_courses.rb tamil       # one language
ruby tool/extract_vocabulary.rb tamil     # words used in lessons with no gloss yet
ruby tool/normalize_titles.rb --apply     # level titles to sentence case
ruby tool/generate_manifests.rb           # regenerate every manifest.json (and the palette)
ruby tool/generate_emblems.rb             # regenerate the language-picker emblems
ruby tool/find_untranslated_glosses.rb    # entries whose gloss is just the word again
ruby tool/fetch_vocab_art.rb              # download the 60 First words pictures
flutter test test/course_repository_test.dart
```

`PILOT_COURSES` in `tool/validate_courses.rb` lists courses still rolling out
language by language — a missing one warns instead of failing the build. Empty
it once every language has a `words.json`.

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
| `lib/core/responsive.dart` | Breakpoints, content-width caps, `ContentBounds` |
| `lib/views/theme_palette.dart` | The ten palettes, `VarnamalaColors`, `buildAppTheme` |
| `lib/application/game_provider.dart` | Score/streak logic |
| `lib/domain/course/course.dart` | Course/Level/Question models |
| `lib/courses/course_repository.dart` | Loads course JSON from assets, caches per language |
| `lib/courses/word_dictionary.dart` | Word-tap gloss lookup |
| `lib/courses/concept_catalogue.dart` | The 60 shared word-course concepts and their pictures |
| `lib/core/answer_similarity.dart` | Judges a typed answer on the word, not its spelling |
| `lib/application/lesson/course_exercise_factory.dart` | Sentence courses -> interactions |
| `lib/application/lesson/vocabulary_exercise_factory.dart` | `words.json` -> picture interactions |
| `lib/views/courses/course_tree.dart` | The path, and which courses are unlocked |
| `lib/views/lesson/exercises/exercise_evaluation.dart` | The verdict an exercise view paints onto its own answer |
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

