"""Export marimo Python notes as static browser pages for the Quarto site."""
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "marimo_exports" / "notes"
SKIP = {"analyze.py", "parse_data.py", "migrate_julia_notes.py", "refresh_migration_notes.py", "stat2_python.py", "build_quarto_notes.py", "build_marimo_site.py"}


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

index_lines = [
    "---",
    'title: "Notebook library"',
    "toc: true",
    "---",
    "",
    "Rendered views of the current marimo notes, organized by the original course units. Use a source link when you want to run or edit a notebook locally.",
    "",
]
for source in note_paths():
    link = (Path("notes") / source.relative_to(ROOT).with_suffix(".html")).as_posix()
    unit = source.parts[0] if len(source.parts) > 1 else "Root utilities"
    index_lines.append(f"- **{unit}**: [{source.stem.replace('-', ' ').title()}]({link}) · [Python source]({source.relative_to(ROOT).as_posix()})")
(ROOT / "notes.qmd").write_text("\n".join(index_lines) + "\n", encoding="utf-8")

print(f"Exported {len(note_paths()) - len(failures)} of {len(note_paths())} marimo notes")
for source, message in failures:
    print(f"FAILED {source}: {message.splitlines()[-1] if message else 'unknown error'}")
if failures:
    raise SystemExit(1)
