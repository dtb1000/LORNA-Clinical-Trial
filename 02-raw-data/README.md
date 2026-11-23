# Stage 2: Raw data

These are the 10 CSV files produced by the generator in [`01-data-generation/`](../01-data-generation/) with seed 1345 at SEVERE quality. They are kept exactly as generated, so every SDTM record can be traced back to them. The variables are described in [`data_dictionary.md`](../01-data-generation/data_dictionary.md).

| File | Records | One record per | Feeds |
|---|---|---|---|
| `subjects.csv` | 300 | Subject | DM |
| `exposure.csv` | 300 | Subject | DM, EX, SE |
| `visits.csv` | 1,750 | Visit attended | SE, EX, DM, LB, VS |
| `deviations.csv` | 50 | Missed visit | DV |
| `labs.csv` | 7,000 | Test per visit attended | LB |
| `vitals.csv` | 10,500 | Parameter per visit attended | VS |
| `adverse.csv` | 83 | Adverse event | AE |
| `medical_history.csv` | 100 | Condition | MH |
| `concom_med.csv` | 100 | Medication | CM |
| `study_metadata.csv` | 1 | Study | Study-level details and the seed |

**File name:** the generator writes adverse events to `ae.csv`. The file is stored here as `adverse.csv`, the name the SAS import program uses, so it is not confused with the SDTM AE dataset.

## Data quality at a glance

| Issue | Count in this data |
|---|---|
| Missing age, sex, race, ethnicity | 36, 34, 35, 29 subjects |
| Invalid ages | 4 subjects |
| Spellings of sex, race, ethnicity | 11, 10, 5 |
| Missed visits | 50 (Week 4: 13, Week 8: 11, Week 12: 12, Follow-up: 14) |
| Missing laboratory results | 669 |
| Missing vital sign results | 1,110 |

How each issue is resolved is described in [`03-sdtm/README.md`](../03-sdtm/README.md).
