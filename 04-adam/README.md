# Stage 6: ADaM datasets (planned)

This folder will hold the analysis datasets built from the SDTM domains in [`03-sdtm/`](../03-sdtm/). They will follow **ADaM v2.1**, the **ADaM Implementation Guide (ADaMIG) v1.3** and the **ADaM Occurrence Data Structure (OCCDS) v1.1**. Every derivation will come from the statistical analysis plan in Section 8 of the [protocol](../docs/LORNA-Trial-Protocol-v1.1.pdf).

## Planned folder contents

| Folder | Content |
|---|---|
| `programs/` | One SAS program per dataset, numbered in run order, starting with ADSL |
| `datasets/csv/` | Datasets as CSV |
| `datasets/xpt/` | Datasets as SAS transport version 5 files |
| `define/` | define.xml (Define-XML v2.1) with analysis results metadata where useful |
| `validation/` | Pinnacle 21 Community report and issues summary |

## Planned datasets

| Dataset | Structure | Main SDTM source | Supports |
|---|---|---|---|
| ADSL | Subject level | DM, DS, EX | Analysis populations, treatment groups, demographics, disposition, dates of first and last dose |
| ADLB | Basic Data Structure (BDS) | LB | Primary endpoints, change from baseline, responders, laboratory safety |
| ADVS | BDS | VS | Change from baseline in vital signs |
| ADEX | BDS | EX | Number of doses, cumulative dose, duration of exposure, compliance |
| ADAE | OCCDS | AE | Treatment-emergent adverse events and events of special interest |
| ADCM | OCCDS | CM | Prior and concomitant medications |
| ADMH | OCCDS | MH | Medical history summaries |
| ADDV | OCCDS | DV | Important protocol deviations and exclusion from the per-protocol population |

ADSL is built first, because every other dataset takes its population flags, treatment variables and reference dates from it.

## Key derivations from the SAP

| Concept | Definition |
|---|---|
| Populations | Intent-to-treat: all randomised. Full analysis set: randomised and dosed, analysed as randomised. Safety: dosed, analysed as treated. Per-protocol: full analysis set subjects with all 4 doses and no important deviation |
| Baseline | Last non-missing value on or before the first dose: normally the Day 1 pre-dose value, otherwise Screening |
| Change from baseline | Post-baseline value minus baseline; percent change = 100 × change ÷ baseline |
| Analysis visits | Laboratory and vital sign results assigned by study day: Week 4 (days 2–43), Week 8 (44–71), Week 12 (72–99), Week 16 (100–141). If two fall in a window, the one closest to the target day is analysed, and the later one if they are equally close |
| Treatment-emergent AE | Onset on or after the first dose and no later than 28 days after the last dose |
| Prior and concomitant medication | Prior: started before the first dose. Concomitant: taken between the first and last dose, including medications with no end date |
| Exposure | Duration = last dose − first dose + 28 days; compliance = doses received ÷ 4 × 100 |
| Responders at Week 12 | CRP: at least 50% reduction. ALT and AST: at or below the upper limit of normal, among subjects above it at baseline. HGB: increase of at least 1.0 g/dL, among subjects below the lower limit of normal at baseline. Subjects without a Week 12 value are non-responders |

## Planned steps

- [ ] Program ADSL and check the population counts against DM, DS and EX
- [ ] Program the BDS datasets (ADLB, ADVS, ADEX) with analysis visits, baselines and change from baseline
- [ ] Program the OCCDS datasets (ADAE, ADCM, ADMH, ADDV) with treatment-emergent, prior and concomitant flags
- [ ] Check that every record traces back to SDTM through --SEQ and SRCDOM/SRCVAR/SRCSEQ where appropriate
- [ ] Create define.xml for the ADaM datasets
- [ ] Validate with Pinnacle 21 Community
