"""Refresh generated marimo notes without replacing the hand-translated example."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent


def metadata(source: str) -> tuple[str | None, str, str | None]:
    dataset_match = re.search(r'Stat2Table\([^,]+,\s*["\']([^"\']+)', source)
    formula_match = re.search(r"@formula\(([^)]+)", source)
    lowered = source.lower()
    if "arima" in lowered or "timeseries" in lowered:
        kind = "time series / ARIMA"
    elif re.search(r"\bglm\s*\(", source) or "logistic" in lowered or "binomial" in lowered:
        kind = "logistic/generalized linear model"
    elif "anova" in lowered or "onewayanovatest" in lowered:
        kind = "ANOVA"
    elif re.search(r"\blm\s*\(", source):
        kind = "linear regression"
    else:
        kind = "EDA only"
    return (dataset_match.group(1) if dataset_match else None, kind, formula_match.group(1).strip() if formula_match else None)


def render(path: Path, source: str) -> str:
    dataset, kind, julia_formula = metadata(source)
    depth = len(path.relative_to(ROOT).parts) - 1
    title = path.relative_to(ROOT).as_posix()
    dataset_repr = repr(dataset)
    formula_repr = repr(julia_formula)
    return f'''import marimo

__generated_with = "0.17.2"

app = marimo.App()


@app.cell
def _():
    import sys
    from pathlib import Path

    import marimo as mo

    sys.path.insert(0, str(Path(__file__).resolve().parents[{depth}]))
    from stat2_python import eda_table, load_rda

    return Path, eda_table, load_rda, mo


@app.cell
def _(Path, eda_table, load_rda, mo):
    dataset_name = {dataset_repr}
    data_dir = Path(__file__).resolve().parents[{depth}] / "Stat2Data"
    if dataset_name is None:
        data = None
        eda = None
        message = "No explicit Stat2Table dataset was found in the Julia source."
    else:
        data = load_rda(dataset_name, data_dir)
        eda = eda_table(data)
        message = None
    return data, dataset_name, eda, message


@app.cell
def _(data, dataset_name, eda, message, mo):
    if data is None:
        _output = mo.vstack([mo.md("# {title}\\n\\n**Migration:** {kind}."), mo.md(message)])
    else:
        _output = mo.vstack([mo.md("# {title}\\n\\n**Migration:** {kind}."), mo.md(f"Dataset: `{{dataset_name}}`"), data.head(), eda])
    _output
    return


@app.cell
def _(data, mo):
    model_formula = {formula_repr}
    if data is None or model_formula is None:
        _output = mo.md("Model translation remains TODO for this source note.")
    else:
        _output = mo.md(f"Detected Julia formula: `{{model_formula}}`. Classified as **{kind}**; translate with statsmodels or scipy.")
    _output
    return


if __name__ == "__main__":
    app.run()
'''


for julia_path in sorted(ROOT.rglob("*.jl")):
    if ".git" in julia_path.parts or "__pycache__" in julia_path.parts:
        continue
    python_path = julia_path.with_suffix(".py")
    if python_path.name == "p540-rat-fat.py":
        continue
    python_path.write_text(render(julia_path, julia_path.read_text(encoding="utf-8")), encoding="utf-8")
