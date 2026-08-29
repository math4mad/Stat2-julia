# Project Instructions

migrate julia version to python  in git  python-deepseek branch 
if refactor sucessful , you can delete julia files

code as  marimo note 
## Environment

conda env :  lock5stat-env , if does'nt exist, then create it 


## Data

- ./Stat2Data

## Phase
  phase1:  refactor(ch00 and UnitA/ch01): restructure for testability
  phase2:  refactor(UnitA/ch02): restructure for testability 
  phase3:  refactor(UnitA/ch03): restructure for testability 
  phase4:  refactor(UnitA/ch04): restructure for testability 
  phase5:  refactor(UnitB): restructure for testability 
  phase6:  refactor(UnitC): restructure for testability 
  phase7:  refactor(UnitD): restructure for testability 

##  workflow
 1. read data as polars dataframe
 1. dataset eda  table usiing great_tables package 
 3. follow julia code refactor to python code 



##  test  
 using  pytest


### Rules
1. every phase complete , testing and summarize it and submit
2. **import**  if you don't recieve command to do next phase, don't do it
3. if `ch00` refactor  affect other  Unit,please update。
4.  as marimo note 
5.   plot as publish standard 

## Marimo Notebook Conventions

1. **Format**: Use `@app.cell` decorator format (not `# %%` py:percent).
2. **Title cell**: `desc = Stat2Table(...)` + `mo.md(f"# {desc.question}")` as the first cell after imports. For same-dataset variants, use `## {desc.question} (variant)` as second-level title.
3. **Private names**: `_`-prefixed names are cell-private and cannot be shared across cells. Alias `_`-prefixed imports to public names: `from stat2lib.plotting import _add_border as add_border`.
4. **Plotting locals**: All matplotlib local variables (`ax`, `fig`, `ax1`, etc.) must be `_`-prefixed and not returned from cells (they are cell-private).
5. **No duplicate public names**: Each public name (non-`_`-prefixed) can only be defined in one cell.
6. **Folder structure**:  `notebooks/ch00/` for ch00, `notebooks/UnitA/chXX/` for UnitA chapters, `notebooks/UnitB/`, etc.
7. **Path convention**: `sys.path.insert(0, str(Path(__file__).resolve().parents[2]))` for `ch00/` level; `parents[3]` for `UnitA/chXX/` level; `parents[4]` for `UnitB/chXX/` level.
8. **Only public data**: Only return variables that are actually used by downstream cells. Plotting-only cells should `return` with nothing. 



