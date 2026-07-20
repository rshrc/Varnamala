#!/usr/bin/env python3
"""List the romanized words a language's lessons use but its dictionary lacks.

Every target-language word a learner can tap needs a gloss, so coverage is
derived from the lessons rather than maintained by hand.

Usage:
    python3 tool/extract_vocabulary.py tamil              # missing words, one per line
    python3 tool/extract_vocabulary.py tamil --all        # every word used
    python3 tool/extract_vocabulary.py tamil --json out.json
"""
import argparse
import json
import pathlib
import sys
from collections import Counter

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from validate_courses import COURSES_DIR, normalize_word, words_in  # noqa: E402


def vocabulary(language):
    """Word -> number of times it appears, across every lesson of a language."""
    directory = COURSES_DIR / language
    counts = Counter()
    for path in sorted(directory.glob("*.json")):
        if path.name in ("manifest.json", "dictionary.json"):
            continue
        data = json.loads(path.read_text())
        for level in data.get("levels", []):
            for question in level.get("questions", []):
                counts.update(words_in(question.get("sentence", "")))
                if question.get("type") == "multiple_choice":
                    for option in question.get("options", []):
                        counts.update(words_in(option))
    counts.pop("name", None)  # the {name} placeholder
    return counts


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("language")
    parser.add_argument("--all", action="store_true",
                        help="list every word, not just the unglossed ones")
    parser.add_argument("--json", metavar="PATH",
                        help="write {word: occurrences} to PATH instead of stdout")
    args = parser.parse_args()

    counts = vocabulary(args.language)
    if not args.all:
        dictionary_path = COURSES_DIR / args.language / "dictionary.json"
        known = set()
        if dictionary_path.exists():
            known = {normalize_word(w) for w in json.loads(dictionary_path.read_text())}
        counts = Counter({w: n for w, n in counts.items() if w not in known})

    # Most frequent first: the words worth getting right.
    ordered = dict(counts.most_common())
    if args.json:
        pathlib.Path(args.json).write_text(json.dumps(ordered, indent=2) + "\n")
        print(f"{len(ordered)} words -> {args.json}")
    else:
        for word in ordered:
            print(word)


if __name__ == "__main__":
    main()
