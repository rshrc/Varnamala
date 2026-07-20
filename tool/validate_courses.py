#!/usr/bin/env python3
"""Validate every language's course JSON under assets/courses/.

Checks the manifest wiring, per-course structure, question schema, and
dictionary coverage of every romanized word a learner can tap. Exits non-zero if
anything fails, so it can gate a commit.

Usage:
    python3 tool/validate_courses.py            # all languages
    python3 tool/validate_courses.py tamil      # one language
"""
import json
import pathlib
import re
import sys
from collections import Counter

ROOT = pathlib.Path(__file__).resolve().parent.parent
COURSES_DIR = ROOT / "assets" / "courses"
IMAGES_DIR = ROOT / "assets" / "images"

MIN_LEVELS, MAX_LEVELS = 5, 6
MIN_QUESTIONS, MAX_QUESTIONS = 8, 10
OPTION_COUNT = 3
NAME_TOKEN = "{name}"
NAME_ALLOWED_IN = {"basics", "introductions"}

MC_PROMPT = "Choose an appropriate response"
TRANSLATE_PROMPT = "Translate the sentence"

MC_KEYS = {"type", "prompt", "sentence", "sentenceIsTargetLanguage",
           "options", "correctAnswer", "translatedSentence"}
TRANSLATE_KEYS = MC_KEYS - {"translatedSentence"}


def normalize_word(word):
    """Mirror of normalizeWord() in lib/courses/course_repository.dart."""
    return re.sub(r"[^a-z0-9]+$", "", re.sub(r"^[^a-z0-9]+", "", word.lower()))


def words_in(sentence):
    return [w for w in (normalize_word(p) for p in sentence.split()) if w]


class Report:
    def __init__(self):
        self.errors = []
        self.warnings = []

    def error(self, where, message):
        self.errors.append(f"{where}: {message}")

    def warn(self, where, message):
        self.warnings.append(f"{where}: {message}")


def check_question(q, where, report, course_id, vocabulary):
    kind = q.get("type")
    if kind not in ("multiple_choice", "translate"):
        report.error(where, f"unknown type {kind!r}")
        return

    expected_keys = MC_KEYS if kind == "multiple_choice" else TRANSLATE_KEYS
    missing = expected_keys - q.keys()
    extra = q.keys() - expected_keys
    if missing:
        report.error(where, f"missing keys {sorted(missing)}")
    if extra:
        report.error(where, f"unexpected keys {sorted(extra)}")
    if missing:
        return

    expected_prompt = MC_PROMPT if kind == "multiple_choice" else TRANSLATE_PROMPT
    if q["prompt"] != expected_prompt:
        report.error(where, f"prompt should be {expected_prompt!r}, got {q['prompt']!r}")

    options = q["options"]
    if not isinstance(options, list) or len(options) != OPTION_COUNT:
        report.error(where, f"expected {OPTION_COUNT} options, got {len(options)}")
        return
    if len(set(options)) != len(options):
        report.error(where, "options contain a duplicate")
    if q["correctAnswer"] not in options:
        report.error(where, f"correctAnswer {q['correctAnswer']!r} is not one of the options")

    if q["sentenceIsTargetLanguage"] is not True:
        report.error(where, "sentenceIsTargetLanguage must be true")

    sentence = q["sentence"]
    if not sentence.strip():
        report.error(where, "empty sentence")
    if len(sentence.split()) < 2:
        report.warn(where, f"single-word sentence {sentence!r}")

    # The tappable dictionary only covers the target-language strings: the
    # prompt sentence always, plus the options when they are the reply.
    vocabulary.update(words_in(sentence))
    if kind == "multiple_choice":
        for option in options:
            vocabulary.update(words_in(option))
        if not q["translatedSentence"].strip():
            report.error(where, "empty translatedSentence")
        if len(q["correctAnswer"].split()) < 2:
            report.warn(where, "single-word correctAnswer reads like a flashcard")
    else:
        # translate options are English meanings.
        if any(not o.strip().endswith(("?", ".", "!")) for o in options):
            report.warn(where, "an English option is missing end punctuation")

    for field, value in q.items():
        text = value if isinstance(value, str) else ""
        if NAME_TOKEN in text and course_id not in NAME_ALLOWED_IN:
            report.error(where, f"{NAME_TOKEN} used outside {sorted(NAME_ALLOWED_IN)}")
        if "$" in text:
            report.error(where, f"stray '$' in {field}")


def check_course(path, course_id, report, vocabulary):
    data = json.loads(path.read_text())
    where = f"{path.parent.name}/{path.name}"

    if data.get("course") != course_id:
        report.error(where, f"course field is {data.get('course')!r}, expected {course_id!r}")
    if not data.get("description", "").strip():
        report.error(where, "missing description")

    levels = data.get("levels") or []
    if not MIN_LEVELS <= len(levels) <= MAX_LEVELS:
        report.error(where, f"{len(levels)} levels, expected {MIN_LEVELS}-{MAX_LEVELS}")

    sentences = Counter()
    for index, level in enumerate(levels, start=1):
        level_where = f"{where} L{level.get('level', '?')}"
        if level.get("level") != index:
            report.error(level_where, f"levels must be numbered 1..n, found {level.get('level')!r} at position {index}")
        if not (level.get("title") or "").strip():
            report.error(level_where, "missing title")

        questions = level.get("questions") or []
        if not MIN_QUESTIONS <= len(questions) <= MAX_QUESTIONS:
            report.error(level_where, f"{len(questions)} questions, expected {MIN_QUESTIONS}-{MAX_QUESTIONS}")

        kinds = Counter(q.get("type") for q in questions)
        if questions and (kinds["multiple_choice"] == 0 or kinds["translate"] == 0):
            report.warn(level_where, f"level uses only one question type ({dict(kinds)})")

        for position, question in enumerate(questions, start=1):
            check_question(question, f"{level_where} Q{position}", report,
                           course_id, vocabulary)
            sentences[question.get("sentence", "")] += 1

    for sentence, count in sentences.items():
        if count > 1:
            report.error(where, f"sentence repeated {count}x: {sentence!r}")

    return len(levels), sum(len(l.get("questions") or []) for l in levels)


def check_language(language, report):
    directory = COURSES_DIR / language
    manifest_path = directory / "manifest.json"
    if not manifest_path.exists():
        report.error(language, "manifest.json is missing")
        return None

    manifest = json.loads(manifest_path.read_text())
    listed = [c["id"] for c in manifest["courses"]]
    in_tree = [cid for row in manifest["tree"] for cid in row]

    for cid in set(in_tree) - set(listed):
        report.error(f"{language}/manifest.json", f"tree references unknown course {cid!r}")
    for cid in set(listed) - set(in_tree):
        report.error(f"{language}/manifest.json", f"course {cid!r} never appears in the tree")
    for row in manifest["tree"]:
        if not 1 <= len(row) <= 3:
            report.error(f"{language}/manifest.json", f"tree row of {len(row)} renders nothing (allowed: 1-3)")

    for course in manifest["courses"]:
        icon = IMAGES_DIR / f"{course['icon']}.png"
        if not icon.exists():
            report.error(f"{language}/manifest.json", f"icon {icon.name} does not exist")
        if not re.fullmatch(r"0x[0-9a-fA-F]{8}", course["color"]):
            report.error(f"{language}/manifest.json", f"bad colour {course['color']!r}")

    vocabulary = set()
    levels = questions = 0
    for cid in listed:
        path = directory / f"{cid}.json"
        if not path.exists():
            report.error(language, f"{cid}.json is missing")
            continue
        course_levels, course_questions = check_course(path, cid, report, vocabulary)
        levels += course_levels
        questions += course_questions

    # Non-ASCII would break the romanized-only rule; the manifest is exempt
    # because it carries each language's own name.
    for path in sorted(directory.glob("*.json")):
        if path.name == "manifest.json":
            continue
        for line_no, line in enumerate(path.read_text().splitlines(), start=1):
            if any(ord(ch) > 127 for ch in line):
                report.error(f"{language}/{path.name}:{line_no}", "non-ASCII character")

    dictionary_path = directory / "dictionary.json"
    covered = 0
    if not dictionary_path.exists():
        report.error(language, "dictionary.json is missing")
    else:
        entries = json.loads(dictionary_path.read_text())
        known = {normalize_word(w) for w in entries}
        for word, gloss in entries.items():
            if not gloss.strip():
                report.error(f"{language}/dictionary.json", f"empty gloss for {word!r}")
        vocabulary.discard(normalize_word(NAME_TOKEN))
        missing = sorted(vocabulary - known)
        covered = len(vocabulary) - len(missing)
        if missing:
            preview = ", ".join(missing[:12])
            report.error(
                f"{language}/dictionary.json",
                f"{len(missing)} of {len(vocabulary)} words have no gloss: {preview}"
                + (" ..." if len(missing) > 12 else ""),
            )

    return {
        "language": language,
        "courses": len(listed),
        "levels": levels,
        "questions": questions,
        "vocabulary": len(vocabulary),
        "covered": covered,
    }


def check_single_file(path, report):
    """Validate one course file on its own — used while authoring, before the
    rest of a language exists."""
    path = pathlib.Path(path)
    if not path.exists():
        report.error(str(path), "file does not exist")
        return
    if path.name in ("manifest.json", "dictionary.json"):
        return  # not a course file; checked as part of the whole language
    vocabulary = set()
    levels, questions = check_course(path, path.stem, report, vocabulary)
    for line_no, line in enumerate(path.read_text().splitlines(), start=1):
        if any(ord(ch) > 127 for ch in line):
            report.error(f"{path.name}:{line_no}", "non-ASCII character")
    print(f"{path}: {levels} levels, {questions} questions, "
          f"{len(vocabulary)} distinct words")


def main():
    args = sys.argv[1:]
    if args and args[0].endswith(".json"):
        report = Report()
        for arg in args:
            check_single_file(arg, report)
        for warning in report.warnings:
            print(f"warning  {warning}")
        for error in report.errors:
            print(f"ERROR    {error}")
        print("FAILED" if report.errors else "OK")
        return 1 if report.errors else 0

    languages = args or sorted(
        p.name for p in COURSES_DIR.iterdir() if p.is_dir()
    )
    report = Report()
    rows = []
    for language in languages:
        stats = check_language(language, report)
        if stats:
            rows.append(stats)

    width = max((len(r["language"]) for r in rows), default=8)
    print(f"{'language':<{width}}  courses  levels  questions  vocabulary")
    for r in rows:
        print(f"{r['language']:<{width}}  {r['courses']:>7}  {r['levels']:>6}  "
              f"{r['questions']:>9}  {r['covered']:>5}/{r['vocabulary']}")
    total = sum(r["questions"] for r in rows)
    print(f"\n{total} questions across {len(rows)} languages")

    for warning in report.warnings:
        print(f"warning  {warning}")
    for error in report.errors:
        print(f"ERROR    {error}")

    if report.errors:
        print(f"\n{len(report.errors)} error(s), {len(report.warnings)} warning(s)")
        return 1
    print(f"\nall checks passed ({len(report.warnings)} warning(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
