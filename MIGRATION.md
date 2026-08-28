# Julia to Python migration

The `python` branch contains a same-directory Python marimo note for every Julia source file from `main`. The Julia files are retained on `main` as the reference implementation, but are removed from this branch.

## Structure

- `stat2_python.py` contains shared RDA loading, Polars conversion, Great Tables EDA, and grouping helpers.
- `migrate_julia_notes.py` regenerates missing same-path `.py` notes from Julia source metadata.
- Every generated note is a marimo app and records its original Julia path.
- Existing Julia changes were preserved on `main`; Julia files are intentionally deleted on this branch.

## Coverage

The source tree had 104 Julia files and now has 104 same-path Python note counterparts. Notes with an explicit `Stat2Table` declaration load the named `.rda` object from `Stat2Data` as a Polars DataFrame and display a head plus an EDA summary. Notes without an explicit dataset declaration are runnable migration placeholders that identify the remaining manual translation work.

The generator classifies explicit operations as linear regression, ANOVA, logistic/generalized linear model, time series/ARIMA, or EDA-only. Formula-bearing notes expose the Julia formula in the notebook so the Python statistical implementation can be reviewed against the source. The hand-translated `UnitB-Anova/ch05/p540-rat-fat.py` also includes the validated SciPy and statsmodels ANOVA result.

## Environment and checks

Use the `lock5stat-env` conda environment. Required Python packages include `marimo`, `polars`, `pyreadr`, `great-tables`, `scipy`, and `statsmodels`.

Useful checks:

```text
conda run -n lock5stat-env python -m py_compile <note.py>
conda run -n lock5stat-env marimo check <note.py>
```

Julia sources should only be removed from a migration branch after the corresponding Python note has been checked for data, formulas, plots, and numerical results. The original sources remain available on `main`.
