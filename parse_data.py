import re

# We will read analysis_output.txt and extract referenced RDA dataset names and Julia statistical operations.
# Let's search all .jl files directly for referenced datasets and statistical operations.
# Let's construct a list of .jl files first.
import os

all_files = []
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for file in files:
        path = os.path.join(root, file)
        path = os.path.relpath(path, '.')
        if path.startswith('.') or path == 'analyze.py' or path == 'parse_data.py':
            continue
        all_files.append(path)

jl_files = sorted([f for f in all_files if f.endswith('.jl')])

# RDA datasets: normally we load them using RData, or URL, or string with .rda, or via get_dataset("DatasetName") or load("DatasetName") etc.
# Python py_files, etc. let's just inspect all files.
rda_datasets = set()
statistical_ops = set()

# Compile some common statistical operations tools we want to identify:
# lm, anova, glm, logistic, t.test, t-test, etc.
# Julia statistical operations: lm, glm, anova, ttest, ttest2, etc. or package APIs
# Let's read all .jl files and find patterns:
# - Strings with .rda or similar
# - RDA dataset names (e.g. from RDatasets, or load_data/get_dataset("Name"))
# Let's search for patterns in .jl files.

for f in jl_files:
    try:
        with open(f, 'r', encoding='utf-8') as file_obj:
            content = file_obj.read()
            
            # Find RDA datasets: look for strings or names. Also, RDatasets often load datasets, e.g. dataset("package", "dataset")
            # Or get_dataset("DatasetName"), or "DatasetName.rda"
            # Let's find dataset(...) or get_dataset(...) or load_data(...)
            for match in re.findall(r'dataset\s*\(\s*["\']([^"\']+)["\']\s*,\s*["\']([^"\']+)["\']\s*\)', content):
                rda_datasets.add(match[1])
            for match in re.findall(r'get_dataset\s*\(\s*["\']([^"\']+)["\']\s*\)', content):
                rda_datasets.add(match)
            for match in re.findall(r'load_data_from_r\s*\(\s*["\']([^"\']+)["\']\s*\)', content):
                rda_datasets.add(match)
            for match in re.findall(r'["\']([^"\']+)\.rda["\']', content, re.IGNORECASE):
                rda_datasets.add(match)
            for match in re.findall(r'load_rda\s*\(\s*["\']([^"\']+)["\']\s*\)', content):
                rda_datasets.add(match)
                
            # Statistical operations/functions used in Julia code:
            # Let's search for functions like lm, glm, anova, OneWayANOVA, TwoWayANOVA, ttest, etc.
            # Also package imports like GLM, HypothesisTests, etc.
            # Let's extract any words matching stat patterns.
            # lm, glm, anova, LogisticRegression, fit(..., LinearModel), etc.
            stat_functions = ['lm', 'glm', 'anova', 'ttest', 'OneWayANOVA', 'TwoWayANOVA', 'fit', 'predict', 'confint', 'coeftable', 'residuals', 'predict', 'r2', 'adjr2', 'AIC', 'BIC', 'crosscor', 'autocor', 'pacf', 'acf', 'arima', 'SARIMA']
            for func in stat_functions:
                if re.search(r'\b' + re.escape(func) + r'\s*\(', content):
                    statistical_ops.add(func)
                    
            # Let's also look for logistic occurrences
            if 'logistic' in content.lower():
                statistical_ops.add('logistic')
            if 'time-series' in content.lower() or 'timeseries' in content.lower() or 'time series' in content.lower():
                statistical_ops.add('time-series')
            if 'anova' in content.lower():
                statistical_ops.add('anova')
            if 'lm' in content.lower() or 'linearmodel' in content.lower():
                statistical_ops.add('lm')
                
    except Exception as e:
        pass

print("Detected RDA Datasets (approx):", sorted(list(rda_datasets)))
print("Detected Statistical Ops/Concepts (approx):", sorted(list(statistical_ops)))

