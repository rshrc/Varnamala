# Interactive exercises across all courses: implementation plan

**Branch:** `experiments`  
**Status:** Ready for implementation  
**Companion spec:** `docs/interactive-lessons-spec.md`  
**Primary constraint:** Keep the existing Flutter app, course releases, and admin
editor working while interactive lessons are introduced.

## 1. Decision

The first rollout will **not rewrite the course JSON** and will not use AI to
regenerate course content.

Instead, Flutter will add a deterministic compatibility adapter between the
existing `Question` model and the new `InteractiveExercise` model. The adapter
will transform only mechanically safe material that already exists in each
question:

- the target-language sentence;
- the verified correct answer;
- the existing translation;
- the three reviewed answer options; and
- the active language dictionary.

The adapter changes the interaction, not the linguistic claim. It must never
invent a translation, accepted answer, synonym, grammar explanation, or
linguistically unreviewed distractor.

This gives every existing course access to varied exercises without changing a
single bundled or Firestore course document. Carefully authored overrides can
be added later, after both Flutter and Admin understand the new optional schema.

## 2. Why this is the safe route

The current catalogue contains 10,530 questions in 13 languages. A corpus scan
shows that 10,478 questions contain an answer long enough for ordering and
10,412 contain a sentence long enough for a fill exercise. The raw material is
already present.

The Admin app currently parses course files through a strict Zod-shaped model.
Unknown properties are not represented in its `CourseQuestion` type and can be
lost when a parsed course is edited and saved. Therefore:

1. phase one adds no fields to course JSON;
2. Admin continues reading, editing, validating, drafting, and publishing the
   exact current schema;
3. optional exercise overrides are a separate, atomic schema change later; and
4. no v2 field may be placed in production JSON until the Admin preservation
   tests pass.

## 3. Compatibility contract

These rules are release blockers, not preferences.

### Course content

- Existing `multiple_choice` and `translate` JSON remains valid.
- Bundled assets and remote Firestore releases produce identical exercises.
- Missing dictionary data reduces the available exercise mix but never blocks a
  lesson from opening.
- An ineligible question falls back to its existing choice interaction.
- The adapter never mutates `Question.options` or cached repository maps.
- `{name}` personalization happens before exercise generation.

### Learner progress

- Current course and level preference keys remain unchanged.
- Each authored JSON level becomes one content unit containing three playable
  lesson stages: Discover, Build, and Recall.
- A source question may return in more than one stage through a different
  interaction, but it appears at most once inside a single stage.
- Adaptive retries are extra session steps and do not unlock extra levels.
- Stage completion, content-unit completion, and course completion are tracked
  separately so extra lessons do not accidentally triple gems or achievements.
- XP, gems, achievements, perfect-lesson state, and completion are never
  awarded for adaptive retries.
- A mistake in either a base exercise or its retry makes the level non-perfect.
- Backing out of an incomplete lesson must not award progress.

### Admin and publishing

- Phase one makes no Admin schema, editor payload, draft, or release changes.
- Existing releases remain playable without republishing.
- Saving an ordinary course in Admin must produce the same JSON shape as today.
- A Flutter rollback must require only switching the lesson renderer, not
  rolling back Firestore content.

## 4. Runtime architecture

```text
bundled JSON or Firestore release
              |
       CourseRepository
  parse + personalise + dictionary
              |
     CourseExerciseFactory
 safe eligibility + deterministic mix
              |
   InteractiveLessonEngine
 response + feedback + retry queue
              |
     InteractiveExerciseHost
 choice / word bank / order / fill / guess
              |
      lesson completion bridge
 XP + gems + achievements + saved progress
```

### 4.1 Course identity and generation context

Generation needs stable identity and must not depend on visible course titles.
Add runtime-only identity to the Flutter course model or pass an explicit
context alongside it:

```dart
class CourseExerciseContext {
  final TargetLanguage language;
  final String courseId;
  final int levelNumber;
  final Map<String, String> dictionary;
  final int generationVersion;
}
```

`CourseRepository` already knows the language and manifest course ID, so it is
the correct place to create this context. Do not use the repository's mutable
`activeDictionary` as implicit adapter input; pass the dictionary snapshot for
the course being opened.

### 4.2 Stable exercise IDs

Existing questions have no IDs. Generate a stable ID from:

```text
language + courseId + normalized question type + sentence + correctAnswer
```

Use a deterministic hash implemented by the app. Do not use `Object.hash`, list
position, or a runtime-random hash. Moving a question inside a level should not
change its identity. Editing its actual content may intentionally create a new
identity.

Generated retry IDs must be derived from the base ID, for example
`<base-id>:retry:fill-text`.

### 4.3 Factory result

The factory should explain its decision so tests and future Admin previews can
inspect it:

```dart
class GeneratedExercise {
  final InteractiveExercise exercise;
  final String sourceQuestionId;
  final GeneratedExerciseKind kind;
  final bool usedFallback;
  final String? fallbackReason;
}
```

The factory is pure: identical question, context, and generation version must
always return the same output.

## 5. Safe exercise derivation rules

### 5.1 Determine the target answer and learner clue

For `translate` questions:

- target answer: `sentence`;
- learner clue: `correctAnswer`.

For `multiple_choice` questions:

- target answer: `correctAnswer`;
- learner clue: `translatedSentence`;
- conversational `sentence` may be shown as additional context.

This prevents the construction exercises from accidentally training English
production when their purpose is target-language production.

### 5.2 Legacy choice

Always eligible. Preserve the current option texts and correct answer. Internally
assign stable option IDs so validation compares IDs instead of visible text.

This is both a valid recognition exercise and the universal fallback.

### 5.3 Word bank

Eligible when the target answer contains 2-18 usable word tokens. Longer
advanced-course sentences wrap across rows in the answer area.

- Tokenize a copied target answer without changing its displayed text.
- Give duplicate words distinct IDs.
- Attach terminal punctuation consistently.
- Use only the answer tokens initially; do not invent distractor words.
- Show the learner clue and, for conversations, the preceding sentence.
- Seed the initial bank order from the exercise ID.
- If the shuffle is already correct, rotate or swap two tokens.

### 5.4 Sentence sequencing

Eligible when the target answer contains 3-18 usable word tokens.

- Use every token exactly once.
- Preserve duplicate tokens by identity.
- Use the same stable shuffle guarantees as the word bank.
- Do not generate sequencing for strings whose tokenization is ambiguous.

### 5.5 Typed fill in the blank

Eligible when a target-answer word:

- has an exact entry in the active language dictionary;
- is not `{name}`;
- is not punctuation-only;
- has a non-empty clue;
- occurs at an unambiguous token boundary; and
- is short enough for an inline response.

Select the blank deterministically, preferring a meaningful dictionary word
over particles and repeated words. The exact original token is the accepted
answer. No synonym is accepted unless it is later authored explicitly.

If no safe word exists, use ordering or legacy choice instead.

### 5.6 Choice fill in the blank

This type needs particular care because random dictionary entries make poor
distractors. Generate it only when a safe contrast set can be derived from
already reviewed content, for example three existing answers with a shared
sentence frame and one differing token at the same position.

All of these conditions must hold:

- the common before/after frame is identical;
- all three candidate tokens are distinct;
- the correct candidate reconstructs the verified answer exactly; and
- no candidate is an empty or punctuation-only token.

Otherwise do not generate choice fill. Typed fill, sequencing, word bank, or
legacy choice is safer than a linguistically misleading distractor.

### 5.7 Guess the word

Eligible when the target answer contains a dictionary-covered word with a clean
gloss and 2-12 user-perceived characters.

- The clue is the existing dictionary gloss.
- The answer is the exact dictionary-covered word from the course sentence.
- Split with Unicode grapheme clusters, never Dart code units.
- Duplicate graphemes receive distinct IDs.
- The initial release needs no invented distractor characters.
- Skip name placeholders, multi-word dictionary keys, parenthetical-only
  glosses, and entries that normalize to an empty value.

### 5.8 Adaptive retry

Every non-choice generated exercise should have a safe retry variant. Prefer a
more guided form after a mistake:

```text
typed fill -> word bank -> legacy choice
guess word -> word bank -> legacy choice
sentence order -> word bank -> legacy choice
word bank -> legacy choice
choice fill -> typed fill when safe, otherwise legacy choice
legacy choice -> word bank when safe, otherwise repeat choice
```

A retry may reuse the same verified answer but must have a distinct exercise
ID. The existing visible `MISTAKE REVIEW` indicator is mandatory.

## 6. Lesson and level expansion policy

### 6.1 Three playable stages per authored level

An existing JSON `level` becomes a **content unit**, not a single learner
session. Flutter derives three sequential playable lessons from it:

| Stage | Purpose | Typical length | Interaction emphasis |
|---|---|---:|---|
| Discover | Introduce and recognize the unit's material | 6 exercises | choice, guided fill, easy word bank |
| Build | Reconstruct the same language with support | 6-8 exercises | word bank, sequencing, choice fill |
| Recall | Produce vocabulary and sentences with less support | 6 exercises | typed fill, guess word, sequencing |

This expands a five-level JSON course to 15 playable lessons and a six-level
course to 18 playable lessons without changing or duplicating JSON. Across the
three stages, each source question should normally appear twice in different
forms. This is spaced practice, not three identical copies of the old quiz.

Stage IDs are stable and versioned:

```text
<language>:<courseId>:unit-<number>:discover:v1
<language>:<courseId>:unit-<number>:build:v1
<language>:<courseId>:unit-<number>:recall:v1
```

The learner must complete the stages sequentially. Completing Recall completes
the authored content unit and unlocks the next unit.

### 6.2 Progress migration

Keep the existing preference value as the record of completed authored units
and add a versioned stage-progress value for the current unit. On first launch
of the expanded engine:

- old progress `0` maps to unit 1, Discover;
- old progress `n` maps to unit `n + 1`, Discover, with the first `n` units and
  all their stages treated as complete; and
- a previously completed course remains completed.

Never map an existing learner backward into generated stages for content they
already completed. Store generation version with stage progress so a later mix
change does not corrupt unlock state.

### 6.3 Rewards and counters

The expanded stages must not silently triple the existing economy:

- every completed stage counts as one `lessonCompleted` and can maintain the
  streak;
- XP is allocated explicitly across Discover, Build, and Recall, with the
  total target per content unit agreed before rollout;
- `levelsCompleted`, unit gems, and the unit perfect bonus are awarded only
  after Recall;
- `coursesCompleted` is awarded only after the final unit's Recall stage; and
- a stage retry never awards XP, gems, progress, or achievement counters.

If product decides that all three stages should award the current full lesson
XP, that must be an explicit economy change with updated achievement thresholds,
not an accidental side effect of calling the old completion method three times.

### 6.4 Exercise selection within a stage

Exercise selection is done once when the level session is created, never during
widget rebuilds. A source question is represented no more than once per stage.

The selector walks a desired pattern for the level and asks the factory for the
first safe type. It must not randomly choose a type from all eligible types.

| Level | Desired mix before eligibility fallback |
|---|---|
| 1 | 40% choice, 25% word bank, 20% order, 15% fill choice |
| 2 | 30% choice, 25% word bank, 20% order, 15% fill choice, 10% guess |
| 3 | 20% choice, 25% word bank, 20% order, 15% fill choice, 10% typed fill, 10% guess |
| 4 | 15% choice, 25% word bank, 20% order, 10% fill choice, 20% typed fill, 10% guess |
| 5-6 | 10% choice, 25% word bank, 20% order, 10% fill choice, 25% typed fill, 10% guess |

Use a deterministic position pattern approximating these percentages while
respecting the stage's purpose. Avoid placing the same interaction three times
in a row or showing the same source question in adjacent stages at the same
position.

Initial quality target:

- every level remains playable;
- every level uses at least three interaction types;
- at least 60% of eligible exercises in levels 3-6 require construction or
  recall rather than choice recognition; and
- no generated question introduces new language content.

If the corpus audit cannot meet the mix safely, report the gap. Do not weaken
eligibility rules to make the numbers look better.

### 6.5 Completed course nodes and unlimited practice

After the final Recall stage, the course node becomes gold rather than merely
showing a completed ring:

- use a gold face, darker physical lip, complete ring, and premium mark;
- add a subtle orbiting shine that respects reduced-motion preferences;
- expose `Course complete. Tap to practise any lesson` through semantics;
- replace the `START` state with completed styling; and
- keep the node enabled permanently.

Tapping a completed node opens a practice picker containing all 15 or 18
generated lessons. Learners may replay any lesson any number of times. Practice
attempts still show feedback and adaptive mistake review, but do not advance
unlock state or repeatedly grant first-completion gems, achievements, or course
completion rewards.

## 7. Flutter integration work packages

Each package should be a reviewable commit and leave the app runnable.

### Package A: Baseline and corpus audit

Deliverables:

- add `tool/audit_interactive_courses.dart`;
- load all bundled course files without altering them;
- report eligibility and fallback reasons per language, course, and level;
- capture the current totals as test fixtures; and
- add a corpus test proving all 10,530 questions still parse.

Checks:

- `ruby tool/validate_courses.rb` passes unchanged;
- existing Flutter tests pass; and
- Admin tests, lint, typecheck, and build pass before integration begins.

### Package B: Deterministic adapter

Deliverables:

- add `CourseExerciseContext`;
- add stable exercise-ID and seeded-shuffle helpers;
- implement `CourseExerciseFactory` with explicit eligibility results;
- adapt legacy choice questions;
- generate word bank, sentence order, typed fill, safe choice fill, and guess
  word exercises; and
- attach guided adaptive retry variants.

Likely files:

```text
lib/application/lesson/course_exercise_factory.dart
lib/application/lesson/exercise_generation_policy.dart
lib/domain/exercise/generated_exercise.dart
lib/core/stable_hash.dart
test/course_exercise_factory_test.dart
test/interactive_course_corpus_test.dart
```

Checks:

- no generator mutates its input;
- every generated answer reconstructs an existing verified source string;
- every shuffle is stable and avoids starting solved when possible;
- Unicode grapheme tests cover an Indic-script example even though current
  course sentences are romanized; and
- ineligible inputs return a typed fallback reason instead of throwing.

### Package C: Real lesson session bridge

Deliverables:

- create one interactive engine for the current level;
- derive Discover, Build, and Recall sessions from the current authored unit;
- add stable stage navigation and unlock state;
- replace the prebuilt list of `ListLesson` widgets with one exercise host;
- move response, check, feedback, continue, and retry state into the session;
- retain the existing speech button and tap-for-word dictionary hints where the
  exercise displays a target-language sentence;
- retain the current completion dialogs initially; and
- preserve the existing empty/loading states.

The completion bridge should extract the award/progress side effects from
`LessonProvider.next` into idempotent stage-completion and unit-completion
methods called only after the engine reaches `complete`.

Checks:

- completing a level awards XP, gems, stats, and progress exactly once;
- five-level and six-level courses expose 15 and 18 playable lessons;
- migrated learners do not lose already completed authored units;
- retry steps do not affect level indexing;
- the perfect bonus is withheld after any mistake;
- navigating away does not complete the level; and
- the next level opens using the same stored progress semantics as today.

### Package D: Feature gate and fallback renderer

Deliverables:

- add a single policy entry point such as `InteractiveLessonRollout`;
- allow `legacy`, `pilot`, and `allCourses` modes;
- enable `allCourses` in debug builds on `experiments`;
- keep the production default at `legacy` until the pilot gate passes;
- preserve the old lesson renderer during the beta; and
- log adapter fallback counts without logging learner answers or personal data.

Suggested gating order:

1. debug lab only;
2. one Hindi Basics course;
3. Hindi and Tamil Basics;
4. every course for one language;
5. all 13 languages; and
6. remove the legacy renderer only after the exit criteria pass.

Changing one policy value must be enough to return all learners to the legacy
renderer without changing content or Firestore.

### Package E: Production-quality lesson shell

Deliverables:

- integrate progress, feedback, correct answer, explanation/clue, and the
  mistake-review notice into the real lesson design;
- confirm drag animation, keyboard/tap fallback, reduced motion, and responsive
  layout outside the debug page;
- handle browser refresh/back navigation safely;
- prevent double submission; and
- add a compact `INTERACTIVE LESSONS · BETA` badge at lesson level, not on every
  generated exercise;
- show the expanded lesson count beneath each course node;
- give completed nodes their gold, reduced-motion-safe shine; and
- add the unlimited completed-course practice picker.

Checks:

- 320 px width and 200% text scale;
- touch, mouse, keyboard, and screen-reader semantics;
- Android, iOS/PWA Safari, and Chrome web smoke tests; and
- no Material text-field chrome returns in the real lesson theme.

### Package F: Catalogue rollout

Deliverables:

- run the audit against all bundled languages;
- test remote-release loading through the same adapter;
- inspect a sample from every exercise type in every language;
- record per-language fallback and interaction-mix metrics; and
- fix factory logic only when the fix is linguistically universal.

Content-specific problems become Admin tasks or future overrides; they must not
be hidden inside language-specific Dart conditionals.

## 8. Admin preservation plan

### Phase one: no Admin feature work required

Because generated interactions exist only in Flutter runtime, Admin continues
to edit source questions exactly as it does now. Still add regression coverage:

- parse every repository course with `courseFileSchema`;
- serialize the parsed value and assert that no existing fields disappear;
- run `validateCourse` for representative `multiple_choice` and `translate`
  questions;
- verify saving a draft retains `sentence`, `options`, `correctAnswer`, and
  `translatedSentence`;
- verify release creation and active/previous pointers are unaffected; and
- keep `bun test`, `bun run lint`, `bun run typecheck`, and `bun run build` in
  the merge gate.

Admin should not duplicate the Dart generation factory during phase one. Two
implementations would drift and could show moderators a preview different from
the learner app.

### Later: optional authored overrides

Only start this after the runtime rollout is stable. Introduce one optional
field instead of replacing the question schema:

```json
{
  "type": "translate",
  "sentence": "Main ghar jaata hoon.",
  "options": ["I go home.", "I am at home.", "I left home."],
  "correctAnswer": "I go home.",
  "exerciseOverride": {
    "type": "fill_blank_text",
    "blankToken": "ghar",
    "acceptedAnswers": ["ghar"]
  }
}
```

This must ship atomically across:

1. Flutter `Question` parsing;
2. Flutter override validation and fallback;
3. Admin Zod schemas and TypeScript types;
4. Admin Redux editing without field loss;
5. Admin editor controls and preview;
6. Admin server-side validation;
7. Ruby repository validation;
8. seed and release serialization tests; and
9. backward-compatibility tests for JSON without the field.

Until all nine are complete, production JSON must remain v1-only.

## 9. Test matrix and merge gates

### Flutter unit tests

- legacy question adaptation for both source types;
- stable IDs after question reordering;
- distinct IDs after material content edits;
- target-answer selection for translate versus conversation questions;
- duplicate words and repeated graphemes;
- punctuation and whitespace normalization;
- safe blank selection and explicit rejection reasons;
- safe contrast-set detection for choice fill;
- dictionary absence and partial dictionary coverage;
- stable, initially unsolved token order;
- retry scheduling and retry termination; and
- input collections remain unchanged.

### Flutter widget/integration tests

- complete a real mixed course level;
- make a mistake and see the previous-mistake indicator later;
- use drag, tap, and keyboard alternatives;
- verify correct/incorrect feedback for every response type;
- verify progress does not move backward when a retry is inserted;
- finish with and without mistakes and verify reward differences;
- leave mid-session and verify no reward;
- load from bundled JSON and a mocked remote release; and
- force the feature gate to legacy and complete the old flow.

### Catalogue tests

- every manifest course loads;
- every authored level produces Discover, Build, and Recall stages;
- every source question appears at most once in a stage;
- five-level and six-level courses produce 15 and 18 playable lessons;
- every level has a playable fallback;
- no generated accepted answer is absent from its source question/dictionary;
- report levels that miss the desired three-type minimum; and
- snapshot generation metrics so a later edit cannot silently collapse the
  catalogue back to choice-only lessons.

### Admin tests

- all repository JSON parses under the Admin schema;
- Admin edit/save round-trip preserves current content;
- validation still rejects bad option and answer relationships;
- draft authorization remains language-scoped;
- publishing preserves independent language releases; and
- release rollback state tests continue to pass.

### Required commands before each rollout gate

```text
flutter analyze
flutter test
flutter build web --wasm --release
ruby tool/validate_courses.rb

cd admin
bun test
bun run lint
bun run typecheck
bun run build
```

## 10. Observability without paid services

For beta sessions, record a compact summary through the existing analytics or
logging path when available:

- language, course ID, level number;
- generation version;
- exercise types presented;
- fallback reasons by code;
- first-try correct count;
- mistake and retry counts;
- hint use; and
- completion or abandonment.

Do not record typed learner answers, names inserted through `{name}`, or the
full lesson text. The local audit tool remains the primary catalogue diagnostic
and costs no network or AI tokens.

## 11. Rollback strategy

There are two independent rollback levels:

1. **Renderer rollback:** switch `InteractiveLessonRollout` to `legacy`. Course
   content, Admin drafts, and releases do not change.
2. **Code rollback:** revert the session bridge while leaving the exercise lab
   and factory tests in the branch. Existing progress keys remain readable.

Do not publish generated exercises into Firestore during this rollout. That
keeps rollback independent of release history.

## 12. Recommended implementation order

1. Commit the current working interactive lab as the visual baseline.
2. Implement Package A and review its corpus report.
3. Implement Package B without touching the real lesson screen.
4. Integrate one mocked real level in tests.
5. Implement Packages C and D together behind `legacy` default.
6. Pilot Hindi Basics, including 3x stage expansion and progress migration, and
   fix lifecycle/progress issues.
7. Pilot Tamil Basics to catch language-independent assumptions.
8. Finish the production lesson shell in Package E.
9. Run Package F across all languages and enable one language at a time.
10. Consider optional Admin overrides only after runtime generation is stable.

## 13. Definition of done

The all-course rollout is complete when:

- all 13 languages and every course open without JSON migration;
- every five-level course exposes 15 playable lessons and every six-level course
  exposes 18;
- every level remains completable with a deterministic fallback;
- qualifying levels present at least three interaction types;
- adaptive retries visibly identify earlier mistakes;
- progress, rewards, achievements, and perfect lessons remain correct;
- a single feature switch restores the legacy renderer;
- the entire Flutter and Admin verification matrix passes;
- Admin can still edit and publish existing course content without data loss;
- completed nodes are visibly golden and every completed lesson is replayable
  without limit or duplicated first-completion rewards;
- no AI call is required at generation time or during course migration; and
- the corpus audit reports no unsafe generated answers.
