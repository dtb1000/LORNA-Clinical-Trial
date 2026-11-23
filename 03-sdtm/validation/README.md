# SDTM validation

This folder holds the **Pinnacle 21 Community** validation report for the 14 SDTM domains and their define.xml.

| File | Content |
|---|---|
| [`LORNA-SDTM-P21-report.xlsx`](LORNA-SDTM-P21-report.xlsx) | Full Pinnacle 21 report from the final run: validation summary, dataset summary, issue summary, record-level details and the rules applied |

## Run settings

| Setting | Value |
|---|---|
| Tool | Pinnacle 21 Community 4.2.0 |
| Engine | FDA (2508.1) |
| Configuration | SDTM-IG 3.4 (FDA) |
| Source data | The 14 XPT files in [`../datasets/xpt/`](../datasets/xpt/), SAS transport version 5 |
| Define.xml | [`../define/define.xml`](../define/define.xml) |
| SDTM CT | 2025-09-26 |
| MedDRA | Not installed, so MedDRA coding was not checked |
| Run date | 23 November 2026 |

**Why CT 2025-09-26 rather than 2026-03-27:** the 2026-03-27 package no longer contains the RACE (C74457) and ETHNIC (C66790) codelists, which SDTMIG v3.4 still uses for DM. CT 2025-09-26 is the latest package that matches SDTMIG v3.4. The define.xml cites the same version.

## Results

| Run | Domains | Records | Messages | Rejection criteria | define.xml findings |
|---|---|---|---|---|---|
| First | 13 | 21,976 | 47 | 1 (no TS dataset) | 0 |
| Second | 14 | 22,033 | 15 | 0 | 0 |
| Final | 14 | 22,033 | 14 | 0 | 0 |

FDA engine 2508.1 marks only rejection criteria with a severity; every other message has a blank severity.

## Fixes made after the first run

| Finding (first run) | Fix | Program |
|---|---|---|
| SD1115 Missing TS dataset (rejection criterion) | New Trial Summary domain with 57 records covering every parameter FDA expects | `16_ts.sas` |
| CT2001 SEX = UNDIFFERENTIATED (26 records) | Kept as INTERSEX, the CDISC term (C45908) | `07_dm.sas` |
| CT2002 EXDOSFRQ = Q4W (1,164 records) | EVERY 4 WEEKS (C64529) | `06_ex.sas` |
| CT2002, CT2003 LBTEST = C-Reactive Protein (1,750 records) | LBTEST set from LBTESTCD with the CDISC names, so CRP is C Reactive Protein (C64548) | `12_lb.sas` |
| SD0055 VISITDY is character (LB, VS, TV) | Planned day stored as a number | `02_normalise.sas` |
| SD1082 Variable length too long for the data (42 variables) | Every character variable resized to its longest value before export | `17_export.sas` |
| SD1083, SD1087, SD1091 Study day missing (8 variables) | AESTDY, AEENDY, DMDY, EXENDY, LBDY, SESTDY, SEENDY and VSDY added | `06`, `07`, `08`, `09`, `12`, `13` |
| SD0027, SD0030 Units present when the result is NOT DONE (LB 669, VS 1,110) | Units blank when --STAT = NOT DONE | `12_lb.sas`, `13_vs.sas` |
| SD1470 to SD1473 Reference range present when LBORRES is missing (669 each) | Reference ranges blank when LBSTAT = NOT DONE | `12_lb.sas` |
| SD1078 TV.ARM null for all records | TV.ARM removed. TV.ARMCD is kept as an empty variable: removing it too gave SD0057 (Expected variable ARMCD not found) in the second run | `05_tv.sas` |

The eCRF and aCRF in [`docs/`](../../docs/) were updated to the same terms.

## Remaining messages

Each remaining message is explained below. A real submission would record these explanations in the Study Data Reviewer's Guide.

| ID | Domain | Message | Count | Explanation |
|---|---|---|---|---|
| SD2260, SD2261 | TS | Invalid TSVAL and TSVALCD for TRT | 2 each | Drug A and Drug B are fictional and have no UNII code |
| SD1312 | TS | TSVAL missing for PCLAS | 1 | The fictional drugs have no pharmacologic class, so PCLAS is null with TSVALNF = UNK |
| CT2002 | TS | TSVCDREF value ISO 8601 not in the DICTNAM codelist | 6 records | ISO 8601 is the reference for durations and dates, as in the SDTMIG TS examples; DICTNAM is extensible |
| SD1121 | DM | Neither AGE nor AGETXT populated | 40 | Ages outside 18 to 85 in the raw data were set to missing during cleaning |
| SD1149 | DM | Expected variable missing for all records (DTHDTC, DTHFL, ARMNRS, ACTARMUD) | 4 | Nobody died, and every subject was assigned and treated as randomised |
| SD0031 | CM, MH | End timing present but no start date or start timing | 100 each | The raw data have no medication or condition start dates |
| SD1077 | CM | EPOCH not found | 1 | EPOCH needs a start date, and CM has none |
| SD1076 | DS | TAETORD is a Model Permissible variable | 1 | Kept on purpose to show the element for each disposition milestone |
| SD1202, SD1339 | DV | DVSTDTC after RFPENDTC, so EPOCH is missing | 14 each | The 14 missed follow-up visits. DVSTDTC is the scheduled date, which falls after the subject's last visit, so no element in SE covers it |
| SD1321 | GLOBAL | No treatment-emergent flag for AE (no SUPPAE) | 1 | Treatment emergence will be derived in ADaM (ADAE.TRTEMFL) |
| SD1485 | GLOBAL | No LC domain alongside LB | 1 | LC (laboratory results in conventional units) is out of scope for this project |

## Re-running the validation

1. In Pinnacle 21 Community, open **Validator** and choose Standard *SDTM*, Source Format *SAS Transport (XPORT)* and Configuration *SDTM-IG 3.4 (FDA)*.
2. Add the 14 XPT files from `../datasets/xpt/` and `../define/define.xml`.
3. Set SDTM CT to *2025-09-26* and select **Validate**.
4. Copy the report from `Documents\Pinnacle 21 Community\reports` into this folder as `LORNA-SDTM-P21-report.xlsx`.
