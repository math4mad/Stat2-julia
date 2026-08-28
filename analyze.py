import os
import subprocess
import re

# Get tracked files
tracked_files = set(subprocess.check_output(["git", "ls-files"]).decode('utf-8').splitlines())

# Find all files of interest
all_files = []
for root, dirs, files in os.walk('.'):
    # Skip dot directories
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for file in files:
        path = os.path.join(root, file)
        # Normalize path
        path = os.path.relpath(path, '.')
        if path.startswith('.'):
            continue
        all_files.append(path)

# Filter by extensions
jl_files = sorted([f for f in all_files if f.endswith('.jl')])
py_files = sorted([f for f in all_files if f.endswith('.py')])
md_files = sorted([f for f in all_files if f.endswith('.md')])
toml_files = sorted([f for f in all_files if f.endswith('.toml')])
notebook_files = sorted([f for f in all_files if f.endswith('.ipynb')])

def get_top_level(path):
    parts = path.split(os.sep)
    if not parts or parts[0] == '.':
        return 'root'
    if len(parts) == 1:
        return 'root'
    # UnitA-LinearRegression -> UnitA etc.
    top = parts[0]
    if top.startswith('UnitA'): return 'UnitA'
    if top.startswith('UnitB'): return 'UnitB'
    if top.startswith('UnitC'): return 'UnitC'
    if top.startswith('UnitD'): return 'UnitD'
    if top == 'ch00': return 'ch00'
    if top == 'temp': return 'temp'
    return 'root'

# Print groupings
print("--- .jl FILES BY TOP-LEVEL DIRECTORY ---")
grouped_jl = {}
for f in jl_files:
    cat = get_top_level(f)
    grouped_jl.setdefault(cat, []).append(f)

for cat in sorted(grouped_jl.keys()):
    print(f"\n[{cat}]")
    for f in grouped_jl[cat]:
        status = "tracked" if f in tracked_files else "untracked"
        print(f"  - {f} ({status})")

print("\n--- OTHER RELEVANT FILES ---")
print("\n[.py files]")
for f in py_files:
    status = "tracked" if f in tracked_files else "untracked"
    print(f"  - {f} ({status})")

print("\n[.md files]")
for f in md_files:
    status = "tracked" if f in tracked_files else "untracked"
    print(f"  - {f} ({status})")

print("\n[.toml files]")
for f in toml_files:
    status = "tracked" if f in tracked_files else "untracked"
    print(f"  - {f} ({status})")

print("\n[notebook files]")
for f in notebook_files:
    status = "tracked" if f in tracked_files else "untracked"
    print(f"  - {f} ({status})")

# Print first 12 nonblank lines of every .jl file
print("\n--- FIRST 12 NONBLANK LINES OF EACH .jl FILE ---")
for f in jl_files:
    print(f"\n========================================")
    status = "tracked" if f in tracked_files else "untracked"
    print(f"FILE: {f} ({status})")
    print(f"========================================")
    try:
        with open(f, 'r', encoding='utf-8') as file_obj:
            lines = file_obj.readlines()
        nonblank = []
        for line in lines:
            line_str = line.strip()
            if line_str:
                nonblank.append(line)
                if len(nonblank) == 12:
                    break
        for line in nonblank:
            print(line, end='')
    except Exception as e:
        print(f"Error reading file: {e}")

