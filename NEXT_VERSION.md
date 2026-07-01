# Varnamala - Next Version Enhancements 🚀

This document outlines the planned features, new question types, mini-games, and architectural changes for the next major version of Varnamala to make it a more engaging, all-rounder language learning application.

## 1. Diverse Question Types (Polymorphic Lessons)

Currently, the app relies heavily on a standard multiple-choice format. We will introduce new interactive formats based on the `question.type` field.

### A. Sentence Builder (Word Bank)
*   **Description:** Instead of providing the full translated sentence as an option, present a scrambled list of word blocks (chips). The user must tap them in the correct order to form the translation.
*   **Implementation Details:**
    *   **Data Model:** Add a new question type `"sentence_builder"`. The `Question` model will need a list of words (e.g., `wordBank`) or we can dynamically split the `correctAnswer` and add distractors.
    *   **UI Component:** Create a `SentenceBuilderLesson` widget.
    *   **Logic:** Maintain two lists in state: `availableWords` and `selectedWords`. Tapping an available word moves it to selected. Tapping a selected word moves it back. The check button validates if `selectedWords.join(' ') == correctAnswer`.

### B. Matching Pairs (Tap Pairs)
*   **Description:** A grid of 6-8 tiles containing words in English and the target language. The user must tap the matching pairs to eliminate them.
*   **Implementation Details:**
    *   **Data Model:** Add a question type `"matching_pairs"`. The `Question` model requires a map or list of pairs (e.g., `[{"en": "Apple", "target": "ಸೇಬು"}, ...]`).
    *   **UI Component:** Create a `MatchPairsLesson` widget using a `GridView`.
    *   **Logic:** State needs to track `selectedTile`. If a second tile is tapped, check if they belong to the same pair. If yes, mark both as 'solved' (hide or gray out). If no, shake animation and deselect both. Lesson is complete when all pairs are solved.

### C. Fill-in-the-Blanks
*   **Description:** Provide a sentence with a missing word and a list of options (easy) or text input (hard).
*   **Implementation Details:**
    *   **Data Model:** Add type `"fill_in_blanks"`. Needs a `promptSentence` with a placeholder (e.g., "I eat an ___") and `options`.
    *   **UI Component:** Create `FillInBlanksLesson`. Use `RichText` to render the sentence with an interactive blank space or inline `TextField`.

### D. Listening / Dictation
*   **Description:** Play the TTS audio without showing the text, requiring the user to type out or build the sentence they just heard.
*   **Implementation Details:**
    *   **Data Model:** Add type `"listening"`.
    *   **UI Component:** A large Audio play button, and either a word bank or text input below it.

### E. Character Tracing (Improvement)
*   **Description:** Enhance `character_drawing.dart` into a strict stroke-order game for learning scripts like Kannada, Tamil, Malayalam, or Devanagari.
*   **Implementation Details:**
    *   Use a path-matching algorithm or predefined touch checkpoints to ensure the user draws the character in the correct direction and order.

---

## 2. Mini-Games & Puzzles

Introduce a new "Arcade" or "Practice" tab that utilizes learned vocabulary in time-constrained puzzles.

### A. Lightning Round (Time Attack)
*   **Description:** Answer as many flashcard-style questions as possible in 60 seconds to build quick recall.
*   **Implementation Details:**
    *   Create a separate game loop outside of standard courses. Pull random questions from completed levels. Use a `Timer` to countdown from 60.

### B. Memory Match
*   **Description:** Classic card-flipping memory game using words struggled with in previous lessons.
*   **Implementation Details:**
    *   Grid of face-down cards. Track `flippedCards`. Check for matches. Integrate with SRS (Spaced Repetition System) to pick words.

### C. Word Search / Crosswords
*   **Description:** Procedurally generate a small word search grid using the localized characters.
*   **Implementation Details:**
    *   Implement a grid generation algorithm that places target words horizontally and vertically, filling empty spaces with random characters from the specific language's alphabet.

### D. Survival Mode
*   **Description:** Answer questions continuously. The game ends as soon as you make 3 mistakes.
*   **Implementation Details:**
    *   Infinite list of questions. Track `lives = 3`.

---

## 3. Deeper Learning Mechanics

### A. Spaced Repetition System (SRS)
*   **Description:** Track mistakes and force periodic reviews.
*   **Implementation Details:**
    *   Update Firestore user profile to include a `weakWords` map (word ID -> mistake count/last review date).
    *   Create a daily "Review" module that prioritizes these words based on an SRS algorithm (like SM-2).

### B. Grammar & Context Tips
*   **Description:** Interstitial screens explaining *why* sentences are structured a certain way.
*   **Implementation Details:**
    *   Add a `Tip` model. Course definitions can include `preLessonTips`.
    *   UI: A swipable card interface shown before the level starts.

### C. Interactive Stories
*   **Description:** Short, dialogue-based reading exercises with comprehension questions.
*   **Implementation Details:**
    *   New JSON structure for stories (List of dialogue lines with speaker tags).
    *   UI: A chat-like interface that reveals one line at a time as the user taps, followed by standard comprehension questions at the end.

---

## Architectural Implementation Plan

To support these changes seamlessly:

1.  **Refactor `Question` Model (`lib/domain/course/course.dart`):**
    *   Ensure the model can handle flexible payloads. Consider using `freezed` unions if question types become very distinct, or keep it generic with flexible fields (e.g., `Map<String, dynamic> metadata`).
    *   Explicitly define constants for `question.type` (e.g., `const String qTypeWordBank = 'wordBank';`).

2.  **Refactor `LessonPage` & `LessonProvider`:**
    *   Update `generateQuestions` and `LessonPage` UI builder to act as a router based on `question.type`.
    *   *Example:*
        ```dart
        Widget buildLesson(Question question) {
           switch(question.type) {
               case 'wordBank': return WordBankLesson(question);
               case 'matchPairs': return MatchPairsLesson(question);
               default: return ListLesson(question);
           }
        }
        ```
    *   Update `LessonProvider` so `checkAnswer` and state management (like `selectedAnswer`) can accommodate non-string answers (e.g., list of words, or pairs).

3.  **Data Structure Updates (`assets/course_data.json` or dart files):**
    *   Begin migrating existing course structures to specify `"type": "multiple_choice"` explicitly and add mock data for new types to begin UI development.
