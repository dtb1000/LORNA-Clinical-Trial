# Synthetic Clinical Trial Data Generator

## Overview
This project generates realistic synthetic clinical trial datasets for use in clinical programming, data management, SDTM mapping and SAS programming projects. The generator simulates a complete Phase II, parallel-group clinical trial and produces multiple related datasets that mimic those collected during an actual study.

## Features
The generator creates data for:
- Study metadata
- Subject demographics
- Treatment exposure
- Medical history
- Concomitant medications
- Study visits
- Protocol deviations
- Laboratory results
- Vital signs
- Adverse events

It also includes:
- Random treatment allocation
- Longitudinal laboratory trends
- A fixed visit schedule
- Missing values
- Data quality errors
- Random protocol deviations
- Subject-specific treatment responses
- Reproducible random number generation using a user-defined seed

## Requirements
- Python 3
- pandas (`pip install pandas`)

All other modules used (`pathlib`, `datetime`, `random`) are part of the Python standard library.

## Running the generator
Run the script from PyCharm, or from a terminal:

```
python random_CT_data_generator_v3.py
```

The script asks for two inputs.

**Input a random number between 1 and 10000:**

Using the same seed reproduces exactly the same clinical trial, and different seeds generate different studies. The seed is read as text and is not checked, so any text works, and "42" and "042" count as different seeds. The seed is saved in `study_metadata.csv`.

**Input the desired quality of output data:**

Type CLEAN, MODERATE or SEVERE exactly as shown, in capitals. Any other value stops the script with an error. The setting decides the proportion of missing values, as defined by `missing_rate` in `QUALITY_SETTINGS`:

| Setting | Missing values |
|---|---|
| CLEAN | 0% |
| MODERATE | 5% |
| SEVERE | 10% |

`QUALITY_SETTINGS` also defines an `error_rate`, but the script does not currently use it. The other data quality issues (invalid ages, inconsistent coding, missed visits and abnormal vital signs) appear at the same rates at every setting, including CLEAN. Running the same seed with different settings gives the same subjects, treatments, visits and adverse events; only the missing values differ.

After execution, a folder called `raw_data` is created in the folder the script is run from. Existing files in it are overwritten. It contains 10 CSV files:
1. `ae.csv`: adverse events
2. `concom_med.csv`: concomitant medications taken by subjects
3. `deviations.csv`: protocol deviations (missed visits)
4. `exposure.csv`: treatment arm and treatment start and end dates
5. `labs.csv`: laboratory test results for each subject at each visit
6. `medical_history.csv`: subjects' underlying conditions
7. `study_metadata.csv`: study details, including the seed used
8. `subjects.csv`: subject demographics and enrolment dates
9. `visits.csv`: each subject's attended visits
10. `vitals.csv`: vital signs measurements for each subject at each visit

## How the generator works

### Step 1: Study setup
Before generating any subjects, the script defines the study configuration (`STUDY_CONFIG`), treatment arms (`ARMS`), sites (`SITES`), visit schedule (`VISITS`), demographic values, medical history and medication dictionaries (`MED_HIST`, `CON_MED`), laboratory tests (`LABS`), vital signs (`VS`), treatment effects (`TREATMENT_EFFECTS`) and adverse event profiles (`AE_PROFILE`).

### Step 2: Create subjects
Each subject is assigned the following attributes:
- Subject number and subject ID (SUBJ001 to SUBJ300)
- Site ID, chosen at random
- Age, between 18 and 85
- Sex
- Race
- Ethnicity
- Enrolment date: 1 January 2023 plus the subject number plus 0 to 2 days
- Treatment arm, chosen at random with equal probability

Sex, race and ethnicity are chosen from lists that deliberately mix spellings and capitalisation. Demographic values may be missing, depending on the quality setting, and about 1% of ages are replaced with an invalid value (-5, 150 or 999).

Treatment starts on the enrolment date and ends 84 days later (Week 12). Both dates are recorded in `exposure.csv`.

### Step 3: Medical history
Approximately 30% of subjects have one or more medical conditions. Each condition has its own prevalence and generates a matching concomitant medication:

| Condition | Prevalence | Medication |
|---|---|---|
| Hypertension | 40% | Lisinopril |
| Type 2 Diabetes | 20% | Metformin |
| Hyperlipidemia | 25% | Simvastatin |
| Stroke | 5% | Losartan |

The dose, formulation and frequency of each medication are chosen using the weights in `CON_MED`. No dates are recorded for conditions or medications.

### Step 4: Visits
Each subject follows the visit schedule below. Days are counted from Baseline, which is the enrolment date and the first day of treatment.

| Visit | Day |
|---|---|
| SCREENING | -14 |
| BASELINE | 0 |
| WEEK 4 | 28 |
| WEEK 8 | 56 |
| WEEK 12 | 84 |
| FOLLOW-UP | 112 |

Every attended visit falls exactly on its scheduled day. Week 4, Week 8, Week 12 and Follow-up each have a 5% chance of being missed. A missed visit is recorded in `deviations.csv` as "Missed visit" with its scheduled date, and no visit, laboratory or vital signs records are created for it. Screening and Baseline are never missed.

### Step 5: Laboratory results
Four tests are generated at every attended visit:

| Test | Reference range | Baseline mean (SD) |
|---|---|---|
| ALT | 7–56 U/L | 40 (8) |
| AST | 8–48 U/L | 35 (6) |
| CRP | 0–10 mg/L | 5 (2) |
| HGB | 12–17.5 g/dL | 14 (1.2) |

The same reference range is used for all subjects. Each subject receives a personal rate of change for each test, drawn from their arm's range and kept for the whole trial. Each result is the subject's baseline value, minus the weeks since Baseline multiplied by that rate, plus random biological variability. Results are rounded to one decimal place and never fall below a set minimum.

- Drug A generally produces the greatest decrease in ALT, AST and CRP.
- Drug B produces a smaller decrease.
- The placebo produces little or no decrease.
- HGB stays roughly stable in all arms.

Screening also counts as week 0, so Screening and Baseline results differ only by random variability. The decrease continues to the Follow-up visit (Week 16), after treatment has ended. Some results may be missing, depending on the quality setting.

### Step 6: Vital signs
Vital signs are generated independently at every visit, so a subject's values are not linked from one visit to the next; weight, for example, can change by tens of kilograms between visits. About 1% of values are extreme outliers, about 10% are mildly abnormal, and the rest are normal. All values are rounded to whole numbers, including temperature. The parameters monitored are:
- Systolic blood pressure (mmHg)
- Diastolic blood pressure (mmHg)
- Heart rate (bpm)
- Respiratory rate (breaths/min)
- Temperature (C)
- Weight (kg)

Some results may be missing, depending on the quality setting.

### Step 7: Adverse events
Each treatment arm has its own safety profile:

| Arm | Possible events (incidence) |
|---|---|
| Drug A | Headache (18%), Dizziness (10%), Fatigue (15%), Nausea (12%), Allergy (3%) |
| Drug B | Headache (9%), Fatigue (7%), Nausea (5%) |
| Placebo | Headache (10%) |

Each event occurs at most once per subject. For every event that occurs, the script determines:
- Severity (MILD, MODERATE or SEVERE), using the arm's weights
- Seriousness (YES or NO)
- The visit at which it is reported, chosen at random from Baseline to Week 12
- Start date: 0 to 3 days after that visit's scheduled date
- End date: 0 to 2 days after the start date

The visit is chosen independently of missed visits, so an adverse event can be linked to a visit that was missed. The generator does not record the relationship to study drug, the outcome or the action taken. This produces realistic adverse event datasets suitable for SDTM AE mapping.

## Utility functions used in the script
Several helper functions keep the code modular. They can be altered to produce more, less or different data. The functions defined in the script are:
1. `maybe_missing()`: replaces a value with a missing value at the rate set by the quality setting
2. `weighted_choice()`: performs probability-weighted sampling from a dictionary
3. `maybe_invalid_age()`: replaces about 1% of ages with an impossible value
4. `random_enrolment_date()`: creates enrolment dates
5. `create_baseline_labs()`: generates baseline laboratory values
6. `create_vital_signs()`: generates one normal, mildly abnormal or extreme vital signs value
7. `create_subject_response()`: creates each subject's rate of change for each laboratory test
8. `treatment_effect()`: calculates a laboratory result at a given week
9. `generate_data()`: creates every subject's records and writes the CSV files

## Making changes

| To change | Edit |
|---|---|
| Number of subjects | `N_SUBJECTS` in `STUDY_CONFIG` |
| Number of sites | `range(1, 5)` in `SITES` (`N_SITES` in `STUDY_CONFIG` is not used to create the sites) |
| Missing value rates | `missing_rate` in `QUALITY_SETTINGS` |
| Visit schedule | `VISITS`, and `AE_VISITS` for the visits at which adverse events can be reported |
| Treatment arms | `ARMS`, with a matching entry in `TREATMENT_EFFECTS` and `AE_PROFILE` for each treatment name |
| Laboratory tests | `LABS`, `create_baseline_labs()` and each arm in `TREATMENT_EFFECTS` |
| Vital signs | `VS` and the three value dictionaries in `create_vital_signs()` |
| Adverse events | The arm's `events` in `AE_PROFILE` |

## License and disclaimer
The Python script has been made open-source for anyone to use, modify and improve. This project is intended for educational and portfolio purposes. The generated data are entirely synthetic and contain no real patient information.
