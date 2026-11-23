# Stages 3 and 4: Data cleaning and SDTM mapping

This folder holds the SAS programs that clean the raw data and map it to CDISC SDTM, and the 14 domains they produce. The mapping follows **SDTM v2.0** and the **SDTM Implementation Guide (SDTMIG) v3.4**, and matches the annotated CRF in [`docs/LORNA-aCRF.pdf`](../docs/LORNA-aCRF.pdf).

## Contents

| Folder | Content | Status |
|---|---|---|
| [`programs/`](programs/) | 18 SAS programs, numbered in run order | Complete |
| [`datasets/csv/`](datasets/csv/) | 14 SDTM domains as CSV | Complete |
| [`datasets/xpt/`](datasets/xpt/) | 14 SDTM domains as SAS transport version 5 files | Complete |
| [`define/`](define/) | define.xml (Define-XML v2.1), its stylesheet, spec and aCRF | Complete |
| [`validation/`](validation/) | Pinnacle 21 Community validation report and issues summary | Complete: 14 messages, none blocking |

---

## Programs

| Program | Purpose | Reads | Creates |
|---|---|---|---|
| `00_libname.sas` | Defines the SAS libraries | - | `RAW`, `INPUT`, `INTER`, `FINAL`, `XPT`, `CSV` |
| `01_import.sas` | Imports one raw CSV file; run once per file | Raw CSV | `RAW.<file>` |
| `02_normalise.sas` | Cleans the raw data and splits it into normalised tables | `RAW` | `INTER` tables |
| `03_te.sas` | Trial Elements | `INTER` | `FINAL.TE` |
| `04_ta.sas` | Trial Arms | `INTER` | `FINAL.TA` |
| `05_tv.sas` | Trial Visits | `INTER` | `FINAL.TV` |
| `06_ex.sas` | Exposure | `RAW`, `INTER` | `FINAL.EX` |
| `07_dm.sas` | Demographics | `RAW`, `INTER`, EX | `FINAL.DM` |
| `08_se.sas` | Subject Elements | `RAW`, `INTER`, DM | `FINAL.SE` |
| `09_ae.sas` | Adverse Events | `INTER`, EX, SE | `FINAL.AE`, plus `INTER.SE_ELEMENTS` used by DV and DS |
| `10_dv.sas` | Protocol Deviations | `INTER`, DM | `FINAL.DV` |
| `11_cm.sas` | Concomitant/Prior Medications | `INTER` | `FINAL.CM` |
| `12_lb.sas` | Laboratory Test Results | `INTER`, DM | `FINAL.LB` |
| `13_vs.sas` | Vital Signs | `INTER`, DM | `FINAL.VS` |
| `14_mh.sas` | Medical History | `RAW`, `INTER` | `FINAL.MH` |
| `15_ds.sas` | Disposition | `INTER`, DM | `FINAL.DS` |
| `16_ts.sas` | Trial Summary | DM | `FINAL.TS` |
| `17_export.sas` | Resizes, labels and exports every domain in `FINAL` | `FINAL` | CSV and XPT files |

Run the programs in numerical order. The order matters because DM needs the dose dates from EX, SE needs the last contact date from DM, AE, DV and DS need the subject elements from SE, TS needs the study dates from DM, and the export must come last.

### Running the programs

1. Create a folder for each library in `00_libname.sas` and change the paths in `00_libname.sas`, `01_import.sas` and `17_export.sas` to your own.
2. Copy the files from [`02-raw-data/`](../02-raw-data/) into the input folder.
3. Run `00_libname.sas`.
4. Run `01_import.sas` once per raw file, setting `%let file=` to the file name without `.csv` (for example `subjects`, then `visits`).
5. Run `02_normalise.sas` to `16_ts.sas` in order.
6. Run `17_export.sas`.

---

## Cleaning and normalisation

`02_normalise.sas` resolves the data quality issues once, before mapping, and stores the results in normalised intermediate tables.

| Issue | Rule |
|---|---|
| Sex spellings | Upper case; MAN to MALE, WOMAN to FEMALE; missing to UNKNOWN |
| Race spellings | Upper case; AFRICAN AMERICAN becomes BLACK OR AFRICAN AMERICAN during DM mapping |
| Ethnicity spellings | Upper case; HISPANIC NOT LATINO to HISPANIC OR LATINO; NOT HISPANIC NOT LATINO to NOT HISPANIC OR LATINO |
| Invalid ages | Ages below 18 or above 85 set to missing |
| Visit numbers | Assigned to match TV: Screening 1 to Follow-up 6, with the planned day stored as a number |
| Medication forms | Immediate-release and extended-release tablets coded to CDISC dosage forms |
| Adverse event terms | Coded to MedDRA, from lowest level term to system organ class |

---

## Domains

### Summary

| Class | Domain | Records | Subjects | One record per |
|---|---|---|---|---|
| Trial design | TE | 5 | - | Element |
| Trial design | TA | 18 | - | Element per arm |
| Trial design | TV | 6 | - | Planned visit |
| Trial design | TS | 57 | - | Trial summary parameter value |
| Special purpose | DM | 300 | 300 | Subject |
| Special purpose | SE | 1,750 | 300 | Element a subject entered |
| Interventions | EX | 1,164 | 300 | Dose given |
| Interventions | CM | 100 | 82 | Medication |
| Events | AE | 83 | 72 | Adverse event |
| Events | DS | 900 | 300 | Disposition event |
| Events | DV | 50 | 45 | Protocol deviation |
| Events | MH | 100 | 82 | Condition |
| Findings | LB | 7,000 | 300 | Test per visit attended |
| Findings | VS | 10,500 | 300 | Parameter per visit attended |

Every domain is sorted by STUDYID, USUBJID and its sequence variable (TS by TSPARMCD and TSSEQ). USUBJID is STUDYID-SITEID-SUBJID, for example `LORNA-SITE001-SUBJ001`.

Every date has a study day (--DY): date minus RFSTDTC, plus 1 on or after RFSTDTC, so there is no Day 0. Values use CDISC SDTM controlled terminology 2025-09-26.

### Trial design: TE, TA, TV, TS

- **TE** has five elements: Screening (SCRN, 14 days), one per treatment (TRTA Drug A 200 mg, TRTB Drug B 300 mg, PLC placebo, 28 days each) and Follow-up (FU).
- **TA** gives each of the three arms six elements in order: Screening, four treatment elements (one per dose) and Follow-up. TABRANCH records the randomisation at the end of Screening; TATRANS sends a subject who stops study drug to Follow-up.
- **TV** lists the six planned visits with VISITDY -14, 1, 29, 57, 85 and 113 (numeric). ARMCD is kept as an empty variable, because SDTMIG v3.4 expects it in TV even when the schedule is the same for every arm; ARM is not included.
- **TS** holds 57 records for the trial summary parameters FDA expects: title, sponsor, registry number, design, blinding, control, population, objectives, outcome measures, treatments and the study dates. The values come from the protocol; SSTDTC (earliest informed consent), SENDTC and DCUTDTC (last subject contact) and ACTSUB (300) come from DM. Coded values give the code and its terminology: CDISC CT, SNOMED for the indication, ISO 3166 for the country, ISO 8601 for dates and durations. Drug A and Drug B are fictional, so TRT has no UNII code and PCLAS is null with TSVALNF = UNK.

### DM: Demographics

| Variable | Rule |
|---|---|
| RFSTDTC, RFXSTDTC | First dose, from EX |
| RFENDTC, RFXENDTC | Last dose, from EX |
| RFICDTC, DMDTC | Screening visit date |
| RFPENDTC | Last visit attended. SUBJ037 is set to 2023-05-05 because an adverse event ended after their last visit |
| SEX | M, F, INTERSEX and U (unknown, not specified or missing) |
| RACE, ETHNIC | CDISC terms; missing values become NOT REPORTED |
| AGE, AGEU | Invalid ages are missing, with AGEU blank |
| ARMCD, ARM, ACTARMCD, ACTARM | From the randomised arm; every subject received the treatment assigned |
| DMDY | Study day of DMDTC (-14 for every subject) |

### SE: Subject Elements

One record per element each subject entered, built from the visits attended:

- Screening runs from the screening visit to the first dose.
- Each treatment element starts at a dose and ends when the next dose starts.
- Follow-up starts when the last treatment element ends.
- The last element ends at RFPENDTC.

A subject who missed a dosing visit has no element for that dose. The 14 subjects who missed the follow-up visit have no follow-up element.

### EX: Exposure

One record per dose given (Baseline: 300, Week 4: 287, Week 8: 289, Week 12: 288). EXDOSE is 200 mg for Drug A, 300 mg for Drug B and 0 mg for placebo, given orally as one tablet every 4 weeks (EXDOSFRQ = EVERY 4 WEEKS). Each dose is a single administration, so EXENDTC = EXSTDTC and EXENDY = EXSTDY. A missed visit means a missed dose, so it has no record.

### AE: Adverse Events

| Variable | Rule |
|---|---|
| AETERM to AESOCCD | MedDRA coding of the reported term, from lowest level term to system organ class, with codes |
| AESEV, AESER | As collected; no event is serious |
| AEACN | NOT APPLICABLE if the event starts on or after the last dose, otherwise DOSE NOT CHANGED |
| AEREL | POSSIBLY RELATED for Drug A and Drug B, UNLIKELY TO BE RELATED for placebo. This is a simulation stand-in: the generator has no investigator assessment |
| AEOUT | RECOVERED/RESOLVED; every event has an end date and none is fatal |
| EPOCH, TAETORD | From SE by start date: 80 events in Treatment, 3 in Follow-up |

### CM: Concomitant/Prior Medications

All 100 records are background therapy for the conditions in MH. CMINDC follows the protocol (lisinopril for hypertension, losartan for stroke, metformin for type 2 diabetes, simvastatin for hyperlipidemia). CMCLAS and CMCLASCD carry the ATC level 4 class. Each medication is ongoing at the end of the study (CMENRTPT = ONGOING, CMENTPT = END OF STUDY), because the protocol requires stable background therapy throughout.

### MH: Medical History

One record per pre-existing condition, coded with MedDRA (MHDECOD and MHBODSYS). Hypertension, type 2 diabetes and hyperlipidemia are ongoing at screening (MHENRTPT = ONGOING); stroke is a prior event (MHENRTPT = BEFORE).

### DS: Disposition

Three records per subject:

| DSDECOD | DSCAT | Date | EPOCH |
|---|---|---|---|
| INFORMED CONSENT OBTAINED | PROTOCOL MILESTONE | RFICDTC | SCREENING |
| RANDOMIZED | PROTOCOL MILESTONE | RFSTDTC (randomisation on Day 1) | SCREENING (before the first dose) |
| COMPLETED | DISPOSITION EVENT | RFPENDTC | From SE: Follow-up for 286 subjects, Treatment for the 14 who missed the follow-up visit |

The generator has no withdrawals, so every subject completes the study.

### DV: Protocol Deviations

One record per missed visit (DVCAT = MISSED VISIT), with the visit in DVTERM, for example MISSED WEEK 8 VISIT. A missed Week 12 visit is IMPORTANT (12 records) because the primary endpoint is measured there; the other 38 are NOT IMPORTANT. DVSTDTC is the scheduled date of the missed visit.

### LB and VS: Laboratory Test Results and Vital Signs

| Rule | LB | VS |
|---|---|---|
| Tests | ALT, AST, CRP (CHEMISTRY); HGB (HEMATOLOGY). LBTEST uses the CDISC names, for example C Reactive Protein | Systolic and diastolic blood pressure, heart rate, respiratory rate, temperature, weight |
| Missing results | 669 records with --STAT = NOT DONE; results, units and reference ranges blank | 1,110 records; results and units blank |
| Reference range indicator | LBNRIND: 6,181 NORMAL, 94 LOW, 56 HIGH | - |
| Baseline flag (--LOBXFL) | 1,192 records | 1,778 records |
| EPOCH, TAETORD | From the visit: Screening and Baseline (pre-dose) are SCREENING; Weeks 4 to 12 are TREATMENT; Follow-up is FOLLOW-UP | Same |

The baseline flag marks the last non-missing value on or before the first dose: normally the Baseline value, or the Screening value when the Baseline result is missing.

---

## CRF fields with no data

The eCRF collects some fields the generator does not simulate. They are annotated on the aCRF as a real study would annotate them. The rule applied:

- **Map** a field when the raw data supply it.
- **Derive** it when the protocol fixes the value for every subject, as for the randomisation date.
- **Leave the variable out** otherwise.

| Domain | Variables left out | Reason |
|---|---|---|
| AE | AESPID, AECONTRT, AEENRTPT, serious event criteria | No AE number or treatment in the raw data; no event is ongoing or serious |
| CM | CMSTDTC, CMENDTC | No medication dates |
| MH | MHSTDTC | No condition start dates |
| IE | Whole domain | IE holds only criteria not met, and every subject met all of them |
| SUPPLB | Clinical significance (LBCLSIG) | No clinical-significance assessments |

---

## Exports

`17_export.sas` prepares every domain in `FINAL` and writes it to:

- **CSV** with PROC EXPORT, for review and for the Power BI report
- **XPT** with the `%loc2xpt` macro

Before writing, it:

1. Shrinks every character variable to the length of its longest value, as FDA expects, and removes formats left over from the import.
2. Applies the SDTMIG v3.4 dataset and variable labels.
3. Checks the version 5 limits (variable names up to 8 characters, labels up to 40, character values up to 200 bytes) and stops if any domain breaks them.

The XPT files are written with `format=V5`, the SAS transport version 5 format that FDA submissions and Pinnacle 21 expect.

---

## Next steps

- [x] Re-export the XPT files as version 5
- [x] Create define.xml in [`define/`](define/)
- [x] Validate with Pinnacle 21 Community and add the report to [`validation/`](validation/)
- [x] Resolve the findings in [`validation/README.md`](validation/README.md): add TS, fix three controlled terminology values, make VISITDY numeric, resize variables, add study days and blank units and ranges on NOT DONE records
- [x] Restore TV.ARMCD as an empty variable in `05_tv.sas` (Expected in SDTMIG v3.4)
- [x] Re-create define.xml and re-validate: 14 messages, no rejection criteria, no define.xml findings
- [ ] Write a Study Data Reviewer's Guide explaining the remaining messages
