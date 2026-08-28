"""Generate same-path marimo migration notes for the Julia source tree."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
EXCLUDED = {".git", "__pycache__"}


def dataset_name(source: str) -> str | None:
    match = re.search(r'Stat2Table\([^,]+,\s*["\']([^"\']+)', source)
    return match.group(1) if match else None


def model_kind(source: str) -> str:
    lowered = source.lower()
    if "sarima" in lowered or "arima" in lowered or "timeseries" in lowered:
        return "time series / ARIMA"
    if re.search(r"\bglm\s*\(", source) or "logistic" in lowered or "binomial" in lowered:
        return "logistic/generalized linear model"
    if "anova" in lowered or "onewayanovatest" in lowered:
        return "ANOVA"
    if re.search(r"\blm\s*\(", source):
        return "linear regression"
    return "EDA only"


def formula(source: str) -> str | None:
    match = re.search(r"@formula\(([^)]+)", source)
    return match.group(1).strip() if match else None


def render(julia_path: Path, source: str) -> str:
    dataset = dataset_name(source)
    kind = model_kind(source)
    model_formula = formula(source)
    dataset_literal = repr(dataset)
    formula_literal = repr(model_formula)
    return f'''import marimo\n\n__generated_with = "0.17.2"\n\napp = marimo.App()\n\n\n@app.cell\ndef _():\n    import sys\n    from pathlib import Path\n\n    import marimo as mo\n\n    sys.path.insert(0, str(Path(__file__).resolve().parents[{len(julia_path.relative_to(ROOT).parts) - 1}]))\n    from stat2_python import eda_table, load_rda\n\n    return Path, eda_table, load_rda, mo\n\n\n@app.cell\ndef _(mo):\n    mo.md("""# {julia_path.relative_to(ROOT).as_posix()}\\n\\n**Migration:** {kind}.""")\n    return\n\n\n@app.cell\ndef _(Path, eda_table, load_rda, mo):\n    dataset_name = {dataset_literal}\n    if dataset_name is None:\n        mo.md("No explicit `Stat2Table` dataset was found in the Julia source; this note is ready for a manual translation.")\n        data = None\n        eda = None\n    else:\n        data = load_rda(dataset_name, Path(__file__).resolve().parents[{len(julia_path.relative_to(ROOT).parts) - 1}] / "Stat2Data")\n        eda = eda_table(data)\n    return data, dataset_name, eda\n\n\n@app.cell\ndef _(data, dataset_name, eda, mo):\n    if data is None:\n        mo.md("EDA unavailable until the source dataset is identified.")\n    else:\n        mo.vstack([mo.md(f"Dataset: `{{dataset_name}}`"), data.head(), eda])\n    return\n\n\n@app.cell\ndef _(data, mo):\n    model_formula = {formula_literal}\n    if data is None or model_formula is None:\n        mo.md("Model translation remains TODO for this source note.")\n    else:\n        mo.md(f"Detected Julia formula: `{{model_formula}}`. The statistical operation is classified as **{kind}** and should be translated here with statsmodels/scipy.")\n    return\n\n\nif __name__ == "__main__":\n    app.run()\n'''


def main() -> None:
    for julia_path in sorted(ROOT.rglob("*.jl")):
        if any(part in EXCLUDED for part in julia_path.parts):
            continue
        python_path = julia_path.with_suffix(".py")
        if python_path.exists() and python_path.name == "p540-rat-fat.py":
            continue
        source = julia_path.read_text(encoding="utf-8")
        python_path.write_text(render(julia_path, source), encoding="utf-8")


if __name__ == "__main__":
    main()
