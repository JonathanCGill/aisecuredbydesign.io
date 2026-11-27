#!/usr/bin/env python3
"""Check docs pages against the writing rules in CLAUDE.md.

Usage: python3 scripts/lint_docs.py [files...]
With no arguments, checks every Markdown file under docs/.
Exits non-zero if any rule is broken.
"""
import pathlib
import re
import sys

DOCS = pathlib.Path("docs")
FENCE = re.compile(r"^\s*(```|~~~)(.*)$")


def check(path: pathlib.Path) -> list[str]:
    errors = []
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    if not text.startswith("---\n") or "\ndescription:" not in text.split("\n---", 1)[0]:
        errors.append("missing YAML front matter with a description field")

    in_code = False
    h1 = 0
    for n, line in enumerate(lines, 1):
        m = FENCE.match(line)
        if m:
            if not in_code and not m.group(2).strip():
                errors.append(f"{n}: code fence without a language identifier")
            in_code = not in_code
            continue
        if in_code:
            continue
        if "—" in line:
            errors.append(f"{n}: em dash")
        if re.search(r"(?<![-|:])\s--\s(?![-|])", line):
            errors.append(f"{n}: double hyphen used as a dash")
        if re.match(r"^# \S", line):
            h1 += 1

    if h1 != 1:
        errors.append(f"expected exactly one H1, found {h1}")
    if '!!! info "References"' not in text:
        errors.append('missing !!! info "References" section')
    return errors


def main(argv: list[str]) -> int:
    files = [pathlib.Path(a) for a in argv] or sorted(DOCS.rglob("*.md"))
    files = [f for f in files if f.suffix == ".md" and f.exists()]
    failed = 0
    for f in files:
        for e in check(f):
            print(f"{f}: {e}")
            failed += 1
    print(f"{len(files)} files checked, {failed} problems")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
