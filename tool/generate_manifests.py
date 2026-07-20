#!/usr/bin/env python3
"""Write assets/courses/<language>/manifest.json for every supported language.

The course set, icons, colours and tree layout are identical across languages —
only the language's own name and romanization convention differ — so they are
generated from one table rather than kept in sync by hand.
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
COURSES_DIR = ROOT / "assets" / "courses"

# id, title, icon (assets/images/<icon>.png), colour
COURSES = [
    ("basics", "Basics", "egg", "0xff2b70c9"),
    ("greetings", "Greetings", "hand", "0xffFFD700"),
    ("introductions", "Introductions", "pen", "0xffCE82FF"),
    ("family", "Family", "family", "0xffFF69B4"),
    ("food", "Food & Drink", "food", "0xffFFA500"),
    ("numbers", "Numbers", "hammer", "0xff808080"),
    ("colours", "Colours", "bucket", "0xffFF0000"),
    ("travel", "Travel", "airplane", "0xff00BCD4"),
    ("time", "Time & Days", "calendar", "0xff9B59B6"),
    ("shopping", "Shopping", "chest", "0xffF39C12"),
    ("health", "Health", "bandages", "0xffE74C3C"),
    ("home", "At Home", "book", "0xff795548"),
    ("work", "Work & School", "student", "0xff2b70c9"),
    ("emotions", "Feelings", "emotion", "0xff0000FF"),
    ("festivals", "Festivals", "celebrate", "0xffC0392B"),
]

# Row sizes for the winding course map: singles, pairs and triples alternating.
TREE_SHAPE = [1, 1, 2, 3, 1, 2, 3, 1, 1]

# language -> (native name, romanization convention)
LANGUAGES = {
    "tamil": ("தமிழ்", "Tanglish"),
    "kannada": ("ಕನ್ನಡ", "Kanglish"),
    "telugu": ("తెలుగు", "Tenglish"),
    "malayalam": ("മലയാളം", "Manglish"),
    "hindi": ("हिन्दी", "Hinglish"),
    "bengali": ("বাংলা", "Banglish"),
    "odia": ("ଓଡ଼ିଆ", "Romanized Odia"),
    "nepali": ("नेपाली", "Romanized Nepali"),
    "assamese": ("অসমীয়া", "Romanized Assamese"),
}


def tree():
    ids = [c[0] for c in COURSES]
    assert sum(TREE_SHAPE) == len(ids), "tree shape must cover every course"
    rows, i = [], 0
    for size in TREE_SHAPE:
        rows.append(ids[i:i + size])
        i += size
    return rows


def main():
    for language, (native, romanization) in LANGUAGES.items():
        directory = COURSES_DIR / language
        directory.mkdir(parents=True, exist_ok=True)
        manifest = {
            "language": language,
            "nativeName": native,
            "romanization": romanization,
            "tree": tree(),
            "courses": [
                {"id": i, "title": t, "icon": ic, "color": c}
                for i, t, ic, c in COURSES
            ],
        }
        path = directory / "manifest.json"
        path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
        print(f"wrote {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
