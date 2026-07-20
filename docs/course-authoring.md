# Course authoring guide

All lesson content lives in `assets/courses/<language>/` as JSON. Nothing about a
course is written in Dart — add a level, fix a translation, or reword a prompt by
editing these files and hot-restarting the app.

```
assets/courses/tamil/
  manifest.json      course order, tree layout, icon + colour for each course
  dictionary.json    romanized word -> English gloss (powers the tap-a-word hint)
  notes.json         Mala's aside beside each course on the map (optional)
  basics.json        one file per course, holding all of its levels
  greetings.json
  ...
```

Loading and validation live in [`lib/courses/course_repository.dart`](../lib/courses/course_repository.dart)
and [`tool/validate_courses.rb`](../tool/validate_courses.rb).

## manifest.json

```jsonc
{
  "language": "tamil",
  "nativeName": "தமிழ்",
  "romanization": "Tanglish",
  // Rows of the course map. A row of one draws a single node, two draw side by
  // side, three draw as a row — that alternation is what makes the path wind.
  "tree": [["basics"], ["greetings"], ["introductions", "family"]],
  "courses": [
    { "id": "basics", "title": "Basics", "icon": "egg", "color": "0xff1D998D" }
  ]
}
```

`icon` names a file in `assets/images/<icon>.png`. Every id in `tree` must have a
matching entry in `courses`, and vice versa.

Colours are **computed**, not chosen — `tool/generate_manifests.rb` solves each
course's lightness so all fifteen sit at the same relative luminance. Regenerate
rather than hand-editing them, or one node will start shouting over the others.

## notes.json

Optional. Each entry pins a short fact about the language beside one course on
the map, shown when the learner taps Mala:

```json
{
  "notes": [
    { "after": "family", "mood": "cute",
      "text": "Tamil ranks siblings before it names them: anna is older brother, thambi younger." }
  ]
}
```

`mood` picks the mascot pose (`cute`, `excited`, `wave`, `asking`). Keep notes
under 24 words and make them *teach* — generic encouragement is worse than an
empty space.

## `<course>.json`

```jsonc
{
  "course": "basics",
  "title": "Basics",
  "description": "Say who you are and ask someone the same.",
  "levels": [
    {
      "level": 1,
      "title": "Naming things",
      "questions": [ /* 8-10 questions */ ]
    }
  ]
}
```

Each course has **5-6 levels**; each level has **8-10 questions**.

## Question types

**`multiple_choice`** — the learner reads a target-language prompt and picks the
target-language reply that fits.

```json
{
  "type": "multiple_choice",
  "prompt": "Choose an appropriate response",
  "sentence": "Un peyar enna?",
  "sentenceIsTargetLanguage": true,
  "options": ["En peyar {name}.", "Enakku pasikkirathu.", "Naan veettil irukkiren."],
  "correctAnswer": "En peyar {name}.",
  "translatedSentence": "My name is {name}."
}
```

**`translate`** — the learner reads a target-language sentence and picks its
English meaning. No `translatedSentence` (the answer *is* the translation).

```json
{
  "type": "translate",
  "prompt": "Translate the sentence",
  "sentence": "Naan naalai varuven.",
  "sentenceIsTargetLanguage": true,
  "options": ["I will come tomorrow.", "I came yesterday.", "I am not coming."],
  "correctAnswer": "I will come tomorrow."
}
```

## Rules

1. **Sentences, not flashcards.** Every question teaches a whole utterance a
   learner could actually say. Teach a word by using it (`"Enakku moonu kaapi
   venum."`), never by asking "choose the word for coffee".
2. **Romanized, ASCII only.** No native script, no accented characters — the
   romanization column in `manifest.json` names the convention each language
   follows (Tanglish, Manglish, Hinglish, …).
3. `correctAnswer` must be a **verbatim** copy of one of `options`. This is the
   single most common way to break a lesson.
4. **Three options**, all plausible. Distractors should be real sentences a
   learner might confuse with the answer, not nonsense.
5. `sentenceIsTargetLanguage: true` whenever `sentence` is in the target
   language — it is what turns each word into a tappable dictionary hint.
6. `{name}` is replaced with the learner's first name at load time. Use it only
   in `basics` and `introductions`, and at most a couple of times.
7. **Difficulty ramps within a course.** Level 1 is 3-5 word sentences; the last
   level uses tense, negation, and connectors in longer sentences.
8. **No repeats.** A sentence appears once per course; distractors are reused
   only when the confusion is deliberate.
9. **Level titles are sentence case** — "Asking the shopkeeper", not "Asking The
   Shopkeeper". Titles made of target-language words keep their own
   capitalisation ("Amma, appa, anna, akka").

## dictionary.json

A flat map of every romanized word that appears in a target-language `sentence`
or `options` entry, to a short English gloss:

```json
{
  "peyar": "name",
  "enna": "what",
  "varuven": "I will come"
}
```

Keys are lowercased and stripped of punctuation on load, so `"enna?"` in a
sentence finds the `"enna"` entry. Glosses should be short enough to read in a
tooltip — for an inflected form, gloss the form ("I will come"), not the root.

Run `ruby tool/validate_courses.rb` after editing anything here; it checks the
schema, the counts, answer/option agreement, ASCII-ness, and dictionary coverage.
