"""Export marimo Python notes as static browser pages."""
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "marimo_exports" / "notes"
SKIP = {"analyze.py", "parse_data.py", "migrate_julia_notes.py", "refresh_migration_notes.py", "stat2_python.py", "build_marimo_site.py"}


def note_paths() -> list[Path]:
    return sorted(
        path
        for path in ROOT.rglob("*.py")
        if not any(part in {".git", ".venv", "_site", "notes", "marimo_exports", "__pycache__"} for part in path.parts)
        and path.name not in SKIP
    )


failures: list[tuple[Path, str]] = []
for source in note_paths():
    target = OUTPUT / source.relative_to(ROOT).with_suffix(".html")
    target.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        ["marimo", "export", "html", "-o", str(target), str(source)],
        cwd=ROOT,
        text=True,
        capture_output=True,
    )
    if result.returncode:
        failures.append((source, (result.stderr or result.stdout).strip()))

library = [
    "---",
    'title: "Notebook library"',
    "toc: true",
    "---",
    "",
    "Rendered views of the migrated marimo notes. Each entry opens the notebook directly in the browser.",
    "",
]
categories: dict[str, list[Path]] = {}
for source in note_paths():
    category_path = source.relative_to(ROOT).parent
    category = category_path.as_posix() if category_path.as_posix() != "." else "Root utilities"
    categories.setdefault(category, []).append(source)
for category, sources in sorted(categories.items()):
    library.append(f"## {category}")
    library.append("")
    for source in sources:
        rendered = (Path("notes") / source.relative_to(ROOT).with_suffix(".html")).as_posix()
        source_url = f"https://github.com/math4mad/Stat2-julia/blob/python/{source.relative_to(ROOT).as_posix()}"
        library.append(f"- [{source.stem.replace('-', ' ').title()}]({rendered}) · [Python source]({source_url})")
    library.append("")
(ROOT / "notes.qmd").write_text("\n".join(library) + "\n", encoding="utf-8")

print(f"Exported {len(note_paths()) - len(failures)} of {len(note_paths())} marimo notes")
for source, message in failures:
    print(f"FAILED {source}: {message.splitlines()[-1] if message else 'unknown error'}")
if failures:
    raise SystemExit(1)
