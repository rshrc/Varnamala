# Interactive lesson engine specification

**Status:** Proposed  
**Target:** Varnamala lesson engine v2  
**Primary goal:** Replace question-and-answer-only levels with short, varied,
interactive learning sessions that move from recognition to independent recall.

## 1. Scope

This specification covers:

- the exercise types available inside a level;
- the JSON structure used to author them;
- how a level mixes and sequences exercise types;
- answer validation and feedback;
- mistake replay and basic mastery tracking;
- the Flutter architecture required to render different interactions;
- migration of the existing course files; and
- accessibility, testing, and beta exit criteria.

It does **not** require paid AI, video calls, subscriptions, additional
currencies, avatar outfits, tournaments, or a large visual course creator.
Human-authored JSON, bundled assets, on-device TTS, and the existing Firebase
backend are enough for this work.

## 2. Current limitation

Course JSON already declares `multiple_choice` and `translate`, but both are
rendered by `ListLesson` as the same three-option choice screen. `Question` is a
single nullable model, and `LessonProvider` assumes every response is one
`String` selected from `options`.

Consequently:

- changing `type` does not meaningfully change the interaction;
- a learner can finish every course through recognition alone;
- lesson mistakes do not directly create a personalized review queue;
- the UI cannot represent an ordered token list, matching progress, typed
  response, or multi-step interaction; and
- adding types to the current widget would create a fragile collection of
  special cases.

## 3. Product principles

1. **Recognition must lead to recall.** A concept is introduced through an easy
   interaction and later tested through construction or typing.
2. **Every interaction must teach.** Distractors represent plausible mistakes;
   random arcade actions do not replace language practice.
3. **Mistakes create practice, not punishment.** A wrong answer is explained and
   queued again. It does not consume a heart or block learning.
4. **Tap and keyboard are first-class.** Drag-and-drop must always have a tap or
   keyboard alternative.
5. **Content stays portable.** Courses remain human-readable JSON and work
   without a paid service.
6. **Language rules live in content.** Accepted alternatives and explanations
   are authored explicitly rather than guessed by generic code.
7. **Native scripts are grapheme-based.** Never split an Indic character by Dart
   code-unit or assume that one visible character is one Unicode scalar.

## 4. Terminology

- **Course:** A path node such as Basics, Food, or Travel.
- **Level:** An 8-10 exercise session inside a course.
- **Exercise:** One learner interaction inside a level.
- **Skill:** A stable concept identifier, such as `pronoun.first_person` or
  `food.ordering`.
- **Token:** One movable unit. It can be a word, punctuation mark, or authored
  grapheme cluster.
- **Attempt:** A submitted response and its outcome.
- **Mastery:** The learner's evolving familiarity with a skill or vocabulary
  item.

## 5. Required exercise catalogue

The first release must implement the first ten types below. Image choice,
speaking, and tracing can use the same engine later.

| Type | Learner interaction | Answer shape | Completion |
|---|---|---|---|
| `choice_response` | Pick the reply that fits a prompt | option ID | Check button |
| `choice_translation` | Pick the correct translation | option ID | Check button |
| `word_bank` | Build a sentence from a bank containing distractors | ordered token IDs | Check button |
| `sentence_order` | Reorder all shuffled words using tap or drag | ordered token IDs | Check button |
| `fill_blank_choice` | Select the missing word or phrase | option ID | Check button |
| `fill_blank_text` | Type the missing word or phrase | text | Check button or Enter |
| `match_pairs` | Match target-language and learner-language tiles | pair IDs | Automatic after all pairs |
| `listen_choice` | Hear audio and select what was said or what it means | option ID | Check button |
| `listen_text` | Hear audio and type what was said | text | Check button or Enter |
| `guess_word` | Use a clue and letter/grapheme bank to construct a word | ordered token IDs | Check button |
| `image_choice` | Pick the image matching a word or sentence | option ID | Check button |
| `speak` | Repeat a phrase using device speech recognition | transcript + confidence | Automatic or Skip |
| `character_trace` | Trace authored strokes in order | stroke samples | Automatic or Check |

### 5.1 Choice response

This is the current `multiple_choice` behavior. Options must be plausible spoken
responses, not unrelated sentences.

### 5.2 Choice translation

This is the current `translate` behavior. It remains useful for introducing new
material but must not dominate later levels.

### 5.3 Word bank

The learner builds a target sentence by selecting tokens. The bank may contain
distractors, so not every token must be used.

- Tapping a bank token moves it to the answer area.
- Tapping an answer token returns it to its original bank position.
- Dragging can move and reorder tokens.
- Duplicate words have distinct IDs.
- Punctuation is attached to the preceding word for the initial release.
- More than one order can be accepted when the language permits it.

### 5.4 Sentence order

The learner puts every supplied token into the correct sequence. Unlike a word
bank, this exercise has no distractors.

- Tokens start in a stable, seeded shuffle that is not already correct.
- Dragging reorders tokens in the answer area.
- Tapping tokens remains available as a non-drag alternative.
- Screen readers expose `Move left`, `Move right`, and position information.

### 5.5 Fill in the blank

The displayed sentence contains exactly one authored blank in v2. Choice mode
introduces a form; text mode tests recall later.

- The blank can represent one word or a short phrase.
- The translation can be shown below as an optional clue.
- Text mode accepts explicitly authored alternatives.
- The answer is not inferred from underscores in an arbitrary string; the
  sentence is stored as `beforeBlank` and `afterBlank`.

### 5.6 Matching pairs

The learner matches 3-5 pairs of words, phrases, audio clips, or meanings.

- A tile can be selected with tap, keyboard, or assistive technology.
- Correct pairs disappear or enter a solved state.
- An incorrect pair gives brief feedback and remains available.
- Tiles from the same side cannot match each other.
- A level cannot contain two visually identical unsolved tiles.

### 5.7 Listening

Listening exercises use a bundled human recording when `asset` is present and
fall back to the existing on-device TTS using `text` and `locale`.

- Normal and slow playback are available.
- Audio never auto-plays when the learner has disabled sound.
- A `Can't listen now` action substitutes an equivalent non-listening exercise
  without marking the answer wrong.
- Text dictation uses authored accepted variants.

### 5.8 Guess the word

The learner sees a meaning, definition, sentence clue, or optional image and
constructs the target word from an authored token bank.

- For romanization, tokens may be letters or useful chunks such as `kh`.
- For native script, authors provide grapheme tokens explicitly.
- Distractor tokens should model likely confusion.
- An optional hint reveals one token but records `hintUsed: true`.
- Guessing is for vocabulary recall; it must not become an unrelated hangman
  game.

## 6. Exercise JSON v2

Every exercise has a shared envelope and a type-specific `content` payload.
This avoids adding dozens of nullable fields to `Question`.

```json
{
  "id": "basics-l2-q04",
  "type": "sentence_order",
  "prompt": "Put the words in order",
  "skillIds": ["identity.introduction", "grammar.word_order"],
  "vocabularyIds": ["naanu", "ravi"],
  "difficulty": 2,
  "content": {},
  "feedback": {
    "translation": "I am Ravi.",
    "explanation": "Naanu is the first-person pronoun and comes before the name here."
  }
}
```

### Shared fields

| Field | Required | Rule |
|---|---|---|
| `id` | Yes | Stable and unique within the language; never use list position as identity |
| `type` | Yes | One supported discriminator from the catalogue |
| `prompt` | Yes | Short action instruction, localized later |
| `skillIds` | Yes | At least one stable concept ID |
| `vocabularyIds` | No | Dictionary IDs directly tested by the exercise |
| `difficulty` | Yes | Integer 1-5; affects sequencing, not scoring multipliers |
| `content` | Yes | Payload validated according to `type` |
| `feedback` | Yes | Correct translation and a useful explanation where applicable |

### Choice example

```json
{
  "id": "basics-l1-q01",
  "type": "choice_response",
  "prompt": "Choose an appropriate response",
  "skillIds": ["identity.ask_name"],
  "vocabularyIds": ["hesaru"],
  "difficulty": 1,
  "content": {
    "sentence": "Nimma hesaru enu?",
    "sentenceLanguage": "target",
    "options": [
      {"id": "a", "text": "Nanna hesaru {name}."},
      {"id": "b", "text": "Nanage gottilla."},
      {"id": "c", "text": "Naanu chennagiddene."}
    ],
    "correctOptionId": "a"
  },
  "feedback": {
    "translation": "What is your name?",
    "explanation": "Nanna hesaru means my name."
  }
}
```

### Word bank example

```json
{
  "id": "basics-l2-q03",
  "type": "word_bank",
  "prompt": "Build the Kannada sentence",
  "skillIds": ["identity.introduction"],
  "vocabularyIds": ["nanna", "hesaru"],
  "difficulty": 2,
  "content": {
    "sourceText": "My name is Ravi.",
    "sourceLanguage": "learner",
    "tokens": [
      {"id": "t1", "text": "Nanna"},
      {"id": "t2", "text": "hesaru"},
      {"id": "t3", "text": "Ravi."},
      {"id": "d1", "text": "nimma"}
    ],
    "acceptedOrders": [["t1", "t2", "t3"]]
  },
  "feedback": {
    "translation": "My name is Ravi.",
    "explanation": "Nanna means my; nimma means your."
  }
}
```

### Sentence order example

```json
{
  "id": "basics-l2-q06",
  "type": "sentence_order",
  "prompt": "Put the words in order",
  "skillIds": ["grammar.word_order"],
  "difficulty": 2,
  "content": {
    "translation": "This is my house.",
    "tokens": [
      {"id": "t1", "text": "Idu"},
      {"id": "t2", "text": "nanna"},
      {"id": "t3", "text": "mane."}
    ],
    "acceptedOrders": [["t1", "t2", "t3"]]
  },
  "feedback": {
    "translation": "This is my house.",
    "explanation": "The possessor nanna comes before mane."
  }
}
```

### Fill-blank examples

```json
{
  "id": "basics-l3-q02",
  "type": "fill_blank_choice",
  "prompt": "Choose the missing word",
  "skillIds": ["demonstratives.this"],
  "difficulty": 2,
  "content": {
    "beforeBlank": "Idu nanna",
    "afterBlank": ".",
    "options": [
      {"id": "a", "text": "mane"},
      {"id": "b", "text": "hesaru"},
      {"id": "c", "text": "chaha"}
    ],
    "correctOptionId": "a",
    "clue": "This is my house."
  },
  "feedback": {
    "translation": "This is my house.",
    "explanation": "Mane means house."
  }
}
```

```json
{
  "id": "basics-l4-q05",
  "type": "fill_blank_text",
  "prompt": "Type the missing word",
  "skillIds": ["demonstratives.this"],
  "difficulty": 4,
  "content": {
    "beforeBlank": "Idu nanna",
    "afterBlank": ".",
    "acceptedAnswers": ["mane"],
    "clue": "This is my house."
  },
  "feedback": {
    "translation": "This is my house.",
    "explanation": "Mane means house."
  }
}
```

### Matching example

```json
{
  "id": "basics-l2-q08",
  "type": "match_pairs",
  "prompt": "Match the pairs",
  "skillIds": ["basics.core_vocabulary"],
  "difficulty": 2,
  "content": {
    "pairs": [
      {"id": "p1", "left": {"text": "mane"}, "right": {"text": "house"}},
      {"id": "p2", "left": {"text": "hesaru"}, "right": {"text": "name"}},
      {"id": "p3", "left": {"text": "pustaka"}, "right": {"text": "book"}}
    ]
  },
  "feedback": {
    "translation": "",
    "explanation": "These words will return later in complete sentences."
  }
}
```

### Listening example

```json
{
  "id": "basics-l3-q07",
  "type": "listen_text",
  "prompt": "Type what you hear",
  "skillIds": ["listening.identity"],
  "difficulty": 4,
  "content": {
    "audio": {
      "text": "Nanna hesaru Ravi.",
      "locale": "kn-IN",
      "asset": null,
      "slowRate": 0.65
    },
    "acceptedAnswers": ["Nanna hesaru Ravi", "Nanna hesaru Ravi."]
  },
  "feedback": {
    "translation": "My name is Ravi.",
    "explanation": "Listen for hesaru, meaning name."
  }
}
```

### Guess-word example

```json
{
  "id": "basics-l3-q09",
  "type": "guess_word",
  "prompt": "Guess the Kannada word",
  "skillIds": ["vocabulary.house"],
  "vocabularyIds": ["mane"],
  "difficulty": 3,
  "content": {
    "clue": "house",
    "tokens": [
      {"id": "t1", "text": "m"},
      {"id": "t2", "text": "a"},
      {"id": "t3", "text": "n"},
      {"id": "t4", "text": "e"},
      {"id": "d1", "text": "i"}
    ],
    "acceptedOrders": [["t1", "t2", "t3", "t4"]],
    "maxHints": 1
  },
  "feedback": {
    "translation": "mane — house",
    "explanation": "You saw mane in Idu nanna mane."
  }
}
```

## 7. Level composition and difficulty

A level is a designed session, not ten randomly selected questions. Each level
must use at least four exercise types once v2 content is available.

### Standard ten-exercise rhythm

1. Recognition warm-up: choice response or translation.
2. Recognition with audio: listen choice.
3. Vocabulary association: match pairs.
4. Guided grammar: fill-blank choice.
5. Sentence construction: word bank.
6. Sentence construction: sentence order.
7. Vocabulary recall: guess word.
8. Less-guided recall: fill-blank text.
9. Listening recall: listen text.
10. Mastery check or replay of an earlier mistake.

The exact order may vary, but two exercises testing the same skill should not be
adjacent unless the second is an adaptive retry.

### Course ramp

| Course level | Main cognitive demand | Recommended mix |
|---|---|---|
| 1 | Recognize new language | 50% choice, 20% matching, 20% fill choice, 10% ordering |
| 2 | Associate and reconstruct | 30% choice, 20% matching, 30% word bank/order, 20% listening |
| 3 | Recall with support | 20% choice, 30% construction, 20% fill, 20% listening, 10% guess word |
| 4 | Produce independently | 10% choice, 30% typed/fill, 30% construction, 20% listening, 10% matching |
| 5-6 | Mixed mastery | At least 50% typed, listening recall, ordering, or other productive work |

Percentages are content checks, not runtime randomization.

## 8. Adaptive mistake replay

When an answer is wrong:

1. Show the correct answer and authored explanation.
2. Record the attempt against its skills and vocabulary IDs.
3. Insert one equivalent retry two or three exercises later.
4. Change the interaction when possible. For example, retry a wrong choice as a
   word bank or fill blank rather than repeating the same choices.
5. Do not award a perfect-level bonus if any first attempt was wrong.
6. Complete the level only after every required skill has at least one correct
   response, including retries.

Retries do not consume hearts and do not create an infinite loop. After two
failed retries, show a guided answer, mark the skill for review, and let the
learner finish the session.

## 9. Answer normalization

Choice, order, and matching answers compare stable IDs, never visible text.

Typed answers are normalized by:

1. trimming leading and trailing whitespace;
2. collapsing repeated internal whitespace;
3. applying Unicode normalization;
4. optionally ignoring terminal `.`, `?`, or `!` when the exercise allows it;
5. applying locale-aware case handling where the script has case; and
6. comparing against every authored `acceptedAnswer`.

The engine must not silently remove accents, change transliteration, or invent
synonyms. Authors add legitimate alternatives explicitly. A near miss may be
shown as `Check spelling`, but it is not automatically correct in v2.

## 10. Lesson session state

The shared session controller owns navigation, scoring, attempts, retries, and
progress. Individual exercise widgets own only temporary interaction state.

```text
loading -> presenting -> answerReady -> checking
checking -> correct -> presenting next exercise
checking -> incorrect -> showingFeedback -> presenting retry/next exercise
presenting final exercise -> completing -> summary
```

Every renderer implements the equivalent of:

```dart
abstract interface class ExerciseController {
  bool get canSubmit;
  ExerciseResponse get response;
  void reset();
}

class AttemptResult {
  final String exerciseId;
  final ExerciseResponse response;
  final bool correct;
  final int elapsedMilliseconds;
  final bool hintUsed;
  final int attemptNumber;
}
```

The global Check button asks the active renderer for a response. Automatic
exercises such as matching emit completion through the same session API.

## 11. Flutter architecture

Do not expand `ListLesson` with a large `switch` and more nullable state.

Recommended structure:

```text
lib/domain/exercise/
  exercise.dart                 sealed Freezed union
  exercise_response.dart        choice, text, ordered, pairs, trace
  attempt_result.dart

lib/application/lesson/
  lesson_session_provider.dart  navigation, retries, mastery events
  answer_validator.dart
  exercise_adapter.dart         legacy JSON -> v2 exercise

lib/views/lesson/
  lesson_screen.dart
  exercise_host.dart            selects renderer by sealed type
  feedback_panel.dart
  exercises/
    choice_exercise.dart
    word_bank_exercise.dart
    sentence_order_exercise.dart
    fill_blank_exercise.dart
    match_pairs_exercise.dart
    listening_exercise.dart
    guess_word_exercise.dart
```

Use a Freezed sealed union or equivalent typed classes for payloads. Unsupported
types must produce a content error with the exercise ID; they must not silently
fall back to multiple choice.

The initial shuffle is created once per exercise from `sessionSeed + exerciseId`
and stored in renderer state. Rebuilding a widget must not reshuffle tokens or
options. Course model lists must remain immutable.

## 12. Progress and mastery data

Store a compact lesson summary rather than writing to Firestore after every tap.

```text
users/{uid}/courseProgress/{language_course}
  currentLevel
  completedLevels
  updatedAt

users/{uid}/mastery/{skillId}
  correctFirstTry
  incorrectAttempts
  lastPracticedAt
  nextReviewAt
  strength

users/{uid}/lessonHistory/{sessionId}
  courseId
  levelId
  startedAt
  completedAt
  exerciseCount
  firstTryCorrect
  mistakeExerciseIds
```

Keep unsynced summaries locally and retry them when connectivity returns. The
lesson must remain playable when Firebase is temporarily unavailable.

## 13. Accessibility and interaction requirements

All exercise types must:

- work at 320 logical pixels without horizontal overflow;
- support text scaling to 200%;
- expose prompt, selection, correctness, and position through semantics;
- have a non-drag alternative to every drag action;
- support keyboard focus, Space/Enter activation, and arrow-key reordering on
  web and desktop;
- avoid using color as the only correct/incorrect indicator;
- preserve a minimum 44x44 logical-pixel interactive target;
- respect reduced-motion preferences; and
- offer a non-audio substitute for listening exercises.

## 14. Content validation

`tool/validate_courses.rb` must become schema-version aware and validate each
type independently.

Common checks:

- IDs are unique and stable.
- Every type is recognized.
- Every skill ID is defined.
- Difficulty is in 1-5.
- Required payload fields are present and unknown fields are rejected.
- A level contains 8-10 authored exercises and at least four types.
- The later half of a course meets the productive-exercise minimum.

Type-specific checks include:

- Correct option IDs exist exactly once.
- Accepted token orders reference existing, unique token IDs.
- Sentence-order answers use every non-distractor token exactly once.
- Matching pairs contain 3-5 unique pairs.
- Fill blanks are non-empty and have accepted answers.
- Listening exercises supply `text`, `locale`, and/or an existing asset.
- Guess-word answers can be built from their token bank.
- Target-language text has dictionary coverage.

## 15. Migration plan

The executable, compatibility-first rollout is detailed in
`docs/specs/interactive-course-integration-plan.md`. It derives only safe
interaction changes from verified v1 answers, keeps the Admin schema unchanged,
and treats fully authored exercise JSON as a later enhancement rather than a
prerequisite for all-course rollout.

### Milestone A: Engine foundation

- Add the sealed exercise model and response types.
- Add `ExerciseHost` and `LessonSessionProvider`.
- Adapt existing `multiple_choice` to `choice_response` and existing `translate`
  to `choice_translation` at load time.
- Preserve all current course progress.

### Milestone B: Construction interactions

- Implement `word_bank`, `sentence_order`, and `fill_blank_choice`.
- Implement tap and drag behavior together.
- Extend the Ruby validator and authoring guide.

### Milestone C: Recall interactions

- Implement `fill_blank_text`, `listen_choice`, `listen_text`, and
  `guess_word`.
- Add typed-answer normalization and the listening substitute flow.

### Milestone D: Multi-item interaction

- Implement `match_pairs`.
- Add adaptive mistake replay and the session summary.
- Feed mistakes into the existing flashcard/practice scheduling system.

### Milestone E: Pilot course

- Convert one language's `basics` course completely.
- Run it with a small beta group.
- Fix engine and schema problems before mass conversion.
- Convert the next course only after the pilot meets the exit criteria.

Do not mechanically generate all new exercises from the existing three options.
Word order, accepted variants, distractors, audio, and explanations require a
speaker or maintainer to review them.

## 16. Testing requirements

### Unit tests

- Every JSON subtype parses and rejects malformed payloads.
- Every response subtype validates correctly.
- Accepted word orders and typed alternatives work.
- Seeded shuffle is stable and never begins solved where avoidable.
- Retry scheduling terminates after its configured limit.
- Mastery updates distinguish first-try success from corrected success.

### Widget tests

- Tap-to-build and tap-to-remove tokens.
- Drag-to-reorder tokens.
- Keyboard reordering.
- Duplicate visible tokens remain independently selectable.
- Matching solves valid pairs and rejects same-side selections.
- Listening can replay slowly and switch to a non-audio substitute.
- Text fields submit with Enter and retain input across harmless rebuilds.
- Feedback exposes correct and incorrect states through semantics.

### Integration tests

- Complete a mixed level from start to summary.
- Make a mistake, receive a different-form retry, and complete it.
- Background and resume midway without losing the session.
- Complete a level offline and synchronize later.
- Existing v1 courses still play through the compatibility adapter.

## 17. Beta rollout and exit criteria

Show one `INTERACTIVE LESSONS · BETA` notice on the pilot course and a compact
badge in its lesson header. Do not place a beta badge on every individual
exercise.

The engine exits beta when:

- all required exercise types meet this specification;
- no supported course can crash because of malformed content;
- completion, resume, and offline flows pass integration tests;
- accessibility requirements pass on Android, iOS Safari/PWA, and desktop web;
- at least one complete course uses four or more exercise types per level;
- mistakes reliably appear in later review; and
- the old choice-only renderer is no longer the default lesson architecture.

## 18. Definition of done

The work is complete when a learner cannot finish the pilot course by repeatedly
selecting one of three answers. They must listen, recognize, match, construct,
order, type, and recall language, with mistakes returning as useful practice.
