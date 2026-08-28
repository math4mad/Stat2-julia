"""Shared helpers for the Julia-to-Python marimo migration."""
from __future__ import annotations

from pathlib import Path
from typing import Any

import polars as pl
import pyreadr


def project_root() -> Path:
    return Path(__file__).resolve().parent


def load_rda(name: str, data_dir: Path | None = None) -> pl.DataFrame:
    """Load a named Stat2Data RDA object as a Polars DataFrame."""
    data_dir = data_dir or project_root() / "Stat2Data"
    result = pyreadr.read_r(str(data_dir / f"{name}.rda"))
    if name in result:
        frame = result[name]
    elif len(result) == 1:
        frame = next(iter(result.values()))
    else:
        raise KeyError(f"No unique object named {name!r} in the RDA file")
    return pl.from_pandas(frame)


def eda_table(frame: pl.DataFrame) -> Any:
    """Return a Great Tables EDA summary, falling back to Polars."""
    summary = frame.describe()
    try:
        from great_tables import GT

        return GT(summary.to_pandas())
    except ImportError:
        return summary


def source_groups(frame: pl.DataFrame, group: str, value: str) -> list[Any]:
    """Return numeric arrays in sorted group order for scipy tests."""
    return [
        frame.filter(pl.col(group) == level)[value].to_numpy()
        for level in frame.get_column(group).drop_nulls().unique().sort().to_list()
    ]
