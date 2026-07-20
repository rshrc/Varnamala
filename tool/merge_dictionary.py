#!/usr/bin/env python3
"""Merge glossed word chunks into a language's dictionary.json.

Chunks are authored separately (one agent per few hundred words), so this folds
them into the single sorted file the app ships. Existing glosses win — a hand
correction is never overwritten by a regenerated chunk.

Usage:
    python3 tool/merge_dictionary.py tamil /tmp/varnamala-dict/tamil.part*.json
"""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from validate_courses import COURSES_DIR, normalize_word  # noqa: E402


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    language, parts = sys.argv[1], sys.argv[2:]

    target = COURSES_DIR / language / "dictionary.json"
    merged = json.loads(target.read_text()) if target.exists() else {}
    before = len(merged)
    skipped = 0

    for part in parts:
        for word, gloss in json.loads(pathlib.Path(part).read_text()).items():
            key = normalize_word(word)
            if not key or not str(gloss).strip():
                skipped += 1
                continue
            merged.setdefault(key, str(gloss).strip())

    target.write_text(
        json.dumps(dict(sorted(merged.items())), indent=2, ensure_ascii=False) + "\n"
    )
    print(f"{language}: {before} -> {len(merged)} entries "
          f"({len(parts)} parts, {skipped} unusable)")


if __name__ == "__main__":
    main()
