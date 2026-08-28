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
for source in note_paths():
    rendered = (Path("notes") / source.relative_to(ROOT).with_suffix(".html")).as_posix()
    source_url = f"https://github.com/math4mad/Stat2-julia/blob/python/{source.relative_to(ROOT).as_posix()}"
    unit = source.parts[0] if len(source.parts) > 1 else "Root utilities"
    library.append(f"- **{unit}**: [{source.stem.replace('-', ' ').title()}]({rendered}) · [Python source]({source_url})")
(ROOT / "notes.qmd").write_text("\n".join(library) + "\n", encoding="utf-8")

print(f"Exported {len(note_paths()) - len(failures)} of {len(note_paths())} marimo notes")
for source, message in failures:
    print(f"FAILED {source}: {message.splitlines()[-1] if message else 'unknown error'}")
if failures:
    raise SystemExit(1)
