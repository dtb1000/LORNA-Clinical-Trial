# Stage 1: Data generation

The Python script [`random_CT_data_generator_v3.py`](random_CT_data_generator_v3.py) simulates the LORNA trial and writes the raw data as 10 CSV files. Those files, kept unchanged, are in [`02-raw-data/`](../02-raw-data/).

## Files

| File | Content |
|---|---|
| [`random_CT_data_generator_v3.py`](random_CT_data_generator_v3.py) | The generator |
| [`tutorial.md`](tutorial.md) | How to run the generator, how each step works, and which settings to change |
| [`data_dictionary.md`](data_dictionary.md) | Every variable in every raw file |

## Running the generator

Requirements: Python 3 and pandas (`pip install pandas`).

```
python random_CT_data_generator_v3.py
```

The script asks for two inputs:

1. **A seed.** The same seed reproduces the same study.
2. **A data quality setting:** CLEAN, MODERATE or SEVERE. This sets the proportion of missing values: 0%, 5% or 10%.

The files are written to a `raw_data/` folder in the folder the script is run from.

The data in this repository were generated with **seed 1345** at **SEVERE** quality.

## What the generator simulates

| Area | How it is simulated |
|---|---|
| Subjects | 300 subjects at 4 sites, enrolled from January 2023, each assigned at random to Drug A, Drug B or placebo |
| Medical history | About 30% of subjects have hypertension, type 2 diabetes, hyperlipidemia or a prior stroke, each with a matching background medication |
| Visits | Screening, Baseline, Weeks 4, 8 and 12, and Follow-up; each post-baseline visit has a 5% chance of being missed |
| Laboratory tests | ALT, AST, CRP and haemoglobin. Each subject has a personal rate of change; Drug A lowers ALT, AST and CRP most, Drug B less, and placebo barely |
| Vital signs | Six parameters generated independently at each visit, with about 10% mildly abnormal and 1% extreme values |
| Adverse events | Each arm has its own events and incidence rates. Drug A has the widest profile, and placebo causes only headache |

## Intentional data quality issues

| Issue | Where it appears | How often |
|---|---|---|
| Missing values | Age, sex, race, ethnicity, laboratory and vital sign results | Set by the quality setting |
| Invalid ages (-5, 150 or 999) | `subjects.csv` | About 1% of subjects |
| Inconsistent coding | Sex, race and ethnicity, for example "Male", "male" and "Man" | Every quality setting |
| Missed visits | `deviations.csv`, with no visit, laboratory or vital sign records | About 5% of each post-baseline visit |
| Out-of-range laboratory values | `labs.csv` | Arise naturally from the simulated values |
| Abnormal and implausible vital signs | `vitals.csv`, for example a systolic blood pressure of 300 mmHg | About 10% abnormal, 1% extreme |

The quality setting controls only the missing values. The other issues appear at every setting, including CLEAN.

## Reproducibility note

The generator stores each subject's conditions in a Python set, whose order can change between runs. For subjects with more than one condition, the dose, form and frequency of each medication can therefore differ from one run to the next, even with the same seed. Everything else is reproducible. The files in [`02-raw-data/`](../02-raw-data/) are the reference copy used for all later stages.
