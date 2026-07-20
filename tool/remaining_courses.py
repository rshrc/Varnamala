#!/usr/bin/env python3
"""Print the "<language>/<course>" jobs that still need authoring.

A course counts as done only if its file exists and passes validation, so an
interrupted generation run can be resumed without redoing good work.

Usage:
    python3 tool/remaining_courses.py                 # every language
    python3 tool/remaining_courses.py tamil kannada   # only these
    python3 tool/remaining_courses.py --json          # as a JSON array
"""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from validate_courses import COURSES_DIR, Report, check_single_file  # noqa: E402


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    as_json = "--json" in sys.argv[1:]

    languages = args or sorted(p.name for p in COURSES_DIR.iterdir() if p.is_dir())
    remaining = []
    for language in languages:
        manifest = json.loads((COURSES_DIR / language / "manifest.json").read_text())
        for course in manifest["courses"]:
            path = COURSES_DIR / language / f"{course['id']}.json"
            report = Report()
            if path.exists():
                # check_single_file prints a summary line; silence it here.
                stdout, sys.stdout = sys.stdout, open("/dev/null", "w")
                try:
                    check_single_file(path, report)
                finally:
                    sys.stdout.close()
                    sys.stdout = stdout
                if not report.errors:
                    continue
            remaining.append(f"{language}/{course['id']}")

    if as_json:
        print(json.dumps(remaining))
    else:
        for job in remaining:
            print(job)
        print(f"\n{len(remaining)} course files remaining", file=sys.stderr)


if __name__ == "__main__":
    main()
