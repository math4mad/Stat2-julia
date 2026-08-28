"""Build browser-readable Quarto pages for each marimo Python note."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "notes"
SKIP = {"analyze.py", "parse_data.py", "migrate_julia_notes.py", "refresh_migration_notes.py", "stat2_python.py", "build_quarto_notes.py"}


def title(path: Path) -> str:
    return path.stem.replace("-", " ").replace("_", " ").title()


def make_page(source_path: Path) -> str:
    relative = source_path.relative_to(ROOT).as_posix()
    output_path = OUTPUT / source_path.relative_to(ROOT).with_suffix(".qmd")
    browser_source = Path(*([".."] * len(output_path.relative_to(OUTPUT).parts[:-1]))) / source_path.relative_to(ROOT)
    source = source_path.read_text(encoding="utf-8")
    return f'''---
title: "{title(source_path)}"
description: "Browser view of the {relative} marimo note."
---

[Open the Python source]({browser_source.as_posix()}) · [View on GitHub](https://github.com/math4mad/Stat2-julia/blob/gh-pages/{relative})

This page presents the marimo note as a browser-readable Quarto document. Run the `.py` file locally with marimo to execute its cells.

```{{.python}}
{source}
```
'''


notes = []
for source_path in sorted(ROOT.rglob("*.py")):
    if any(part in {".git", ".venv", "_site", "notes", "__pycache__"} for part in source_path.parts):
        continue
    if source_path.name in SKIP:
        continue
    output_path = OUTPUT / source_path.relative_to(ROOT).with_suffix(".qmd")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(make_page(source_path), encoding="utf-8")
    notes.append((source_path, output_path))

index_lines = ["---", 'title: "All marimo notes"', 'toc: true', "---", "", "Every Python note has a browser-readable Quarto page. Select a note below to inspect its source, then run the `.py` file locally with marimo.", ""]
for source_path, output_path in notes:
    unit = source_path.parts[0] if len(source_path.parts) > 1 else "Root utilities"
    link = output_path.relative_to(ROOT).with_suffix(".html").as_posix()
    index_lines.append(f"- **{unit}**: [{title(source_path)}]({link})")
(OUTPUT / "index.qmd").write_text("\n".join(index_lines) + "\n", encoding="utf-8")
print(f"Generated {len(notes)} browser note pages")
