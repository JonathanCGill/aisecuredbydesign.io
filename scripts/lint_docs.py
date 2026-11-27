#!/usr/bin/env python3
"""Check docs pages against the writing rules in CLAUDE.md.

Usage:
  python3 scripts/lint_docs.py [files...]     check whole files (default: all docs)
  python3 scripts/lint_docs.py --base REF     check only what changed since REF

With --base, line rules (em dashes, double hyphens, code fence languages)
apply to added lines only, and whole-file rules (front matter description,
one H1, References section) apply to new pages only. This stops new
problems without failing every PR on older pages. Exits non-zero on any
problem.
"""
import pathlib
import re
import subprocess
import sys

DOCS = pathlib.Path("docs")
FENCE = re.compile(r"^\s*(```|~~~)(.*)$")
DOUBLE_HYPHEN = re.compile(r"(?<![-|:<!])\s--\s(?![-|>])")


def line_problems(lines: list[str], only: set[int] | None = None) -> list[str]:
    errors = []
    in_code = False
    for n, line in enumerate(lines, 1):
        m = FENCE.match(line)
        if m:
            opening = not in_code
            in_code = not in_code
            if opening and not m.group(2).strip() and (only is None or n in only):
                errors.append(f"{n}: code fence without a language identifier")
            continue
        if in_code or (only is not None and n not in only):
            continue
        if "—" in line:
            errors.append(f"{n}: em dash")
        if DOUBLE_HYPHEN.search(line):
            errors.append(f"{n}: double hyphen used as a dash")
    return errors


def file_problems(text: str) -> list[str]:
    errors = []
    if not text.startswith("---\n") or "\ndescription:" not in text.split("\n---", 1)[0]:
        errors.append("missing YAML front matter with a description field")
    body = re.sub(r"^(```|~~~).*?^\1", "", text, flags=re.S | re.M)
    h1 = len(re.findall(r"^# \S", body, re.M))
    if h1 != 1:
        errors.append(f"expected exactly one H1, found {h1}")
    if '!!! info "References"' not in text:
        errors.append('missing !!! info "References" section')
    return errors


def git(*args: str) -> str:
    return subprocess.run(["git", *args], check=True, capture_output=True, text=True).stdout


def changed(base: str) -> list[tuple[pathlib.Path, bool, set[int]]]:
    """Return (path, is_new, added_line_numbers) for changed Markdown in docs/."""
    out = []
    status = git("diff", "--name-status", "--diff-filter=AMR", f"{base}...HEAD", "--", "docs/*.md", "docs/**/*.md")
    for row in status.splitlines():
        parts = row.split("\t")
        flag, path = parts[0], parts[-1]
        diff = git("diff", "-U0", f"{base}...HEAD", "--", path)
        added = set()
        for m in re.finditer(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@", diff, re.M):
            start, count = int(m.group(1)), int(m.group(2) or "1")
            added.update(range(start, start + count))
        out.append((pathlib.Path(path), flag.startswith("A"), added))
    return out


def main(argv: list[str]) -> int:
    problems = 0
    checked = 0
    if argv[:1] == ["--base"]:
        for path, is_new, added in changed(argv[1]):
            text = path.read_text(encoding="utf-8")
            errors = line_problems(text.splitlines(), None if is_new else added)
            if is_new:
                errors += file_problems(text)
            for e in errors:
                print(f"{path}: {e}")
            problems += len(errors)
            checked += 1
    else:
        files = [pathlib.Path(a) for a in argv] or sorted(DOCS.rglob("*.md"))
        for path in (f for f in files if f.suffix == ".md" and f.exists()):
            text = path.read_text(encoding="utf-8")
            errors = line_problems(text.splitlines()) + file_problems(text)
            for e in errors:
                print(f"{path}: {e}")
            problems += len(errors)
            checked += 1
    print(f"{checked} files checked, {problems} problems")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
