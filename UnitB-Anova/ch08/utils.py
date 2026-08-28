import marimo

__generated_with = "0.17.2"

app = marimo.App()


@app.cell
def _():
    import sys
    from pathlib import Path

    import marimo as mo

    sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
    from stat2_python import eda_table, load_rda

    return Path, eda_table, load_rda, mo


@app.cell
def _(Path, eda_table, load_rda, mo):
    dataset_name = None
    data_dir = Path(__file__).resolve().parents[2] / "Stat2Data"
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
        _output = mo.vstack([mo.md("# UnitB-Anova/ch08/utils.jl\n\n**Migration:** linear regression."), mo.md(message)])
    else:
        _output = mo.vstack([mo.md("# UnitB-Anova/ch08/utils.jl\n\n**Migration:** linear regression."), mo.md(f"Dataset: `{dataset_name}`"), data.head(), eda])
    _output
    return


@app.cell
def _(data, mo):
    model_formula = None
    if data is None or model_formula is None:
        _output = mo.md("Model translation remains TODO for this source note.")
    else:
        _output = mo.md(f"Detected Julia formula: `{model_formula}`. Classified as **linear regression**; translate with statsmodels or scipy.")
    _output
    return


if __name__ == "__main__":
    app.run()
