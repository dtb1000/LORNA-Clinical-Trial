# Stage 5: Reporting in Power BI

[`LORNA-Clinical-Trial-Report.pbix`](LORNA-Clinical-Trial-Report.pbix) is an interactive Power BI report on the final, validated SDTM datasets in [`03-sdtm/datasets/csv/`](../03-sdtm/datasets/csv/). Open it in Power BI Desktop.

## Pages

|Page|Visuals|Domains used|
|-|-|-|
|Trial-related information|Subject counts by site and arm, cumulative enrolment by month, age distribution, average age by site and arm|DM|
|Subject-related information|Sex, race and ethnicity, and the sex mix in each arm|DM|
|Medical history and concomitant medications|Conditions by arm, medications with dose, dose unit, form and frequency, dosing frequency, formulation by medication|CM, DM|
|Missed visits|Missed visits by site, visit, arm and epoch, a visit-by-arm matrix and a subject listing|DV, DM|
|Vital signs across trial visits|Mean of each parameter by visit and arm, and mean change from Baseline to Week 12|VS, DM|
|Laboratory test results|Mean of each test by visit and arm, and mean change from Baseline to Week 12|LB, DM|
|Adverse events|Most frequent events, severity by arm, events by site, demographics of subjects with events, and an event listing|AE, DM|

The visuals cross-filter: selecting a bar, slice or row on a page filters the other visuals on it. The vital signs and laboratory pages have a single-select slicer to choose the parameter or test; they open on Diastolic Blood Pressure and Alanine Aminotransferase.

## Data model

|Table|Source|Purpose|
|-|-|-|
|`sdtm ae`, `sdtm cm`, `sdtm dm`, `sdtm dv`, `sdtm ex`, `sdtm lb`, `sdtm se`, `sdtm ta`, `sdtm te`, `sdtm tv`, `sdtm vs`|The matching CSV file in `03-sdtm/datasets/csv/`, read from the folder in the `CsvFolder` parameter|One table per SDTM domain used by the report, each linked to `sdtm dm` by USUBJID. TS is not loaded because no visual uses it|
|`DimArm`|Calculated from `sdtm dm`|Treatment arms|
|`DimVisit`|Calculated from `sdtm tv`|Visit names and numbers, linked to LB and VS|
|`Enrolment Months`|Calculated|Month axis for the cumulative enrolment chart|

Display details:

* **Sex** is shown with readable labels mapped from the CDISC terms in DM: M as Male, F as Female, INTERSEX as Intersex, and U as Unknown.
* **Laboratory tests** use the CDISC test names from LBTEST, for example C Reactive Protein.
* **Study days** (AESTDY, AEENDY, DMDY, EXENDY, LBDY, SESTDY, SEENDY, VSDY) are loaded as whole numbers, ready for new visuals.
* **Medication doses** keep their decimals, so a 2.5 mg dose shows as 2.5.
* **Measures** compute the mean laboratory and vital sign values at Baseline and Week 12, the mean change between them, and the cumulative number of subjects enrolled.

## Refreshing the data

The report opens with its saved data. Every query reads its CSV file from the folder held in one Power Query parameter, `CsvFolder`, which is set to the author's copy of `03-sdtm/datasets/csv/`. To refresh it on another computer:

1. Open the report in Power BI Desktop.
2. Go to **Transform data > Edit parameters**.
3. Set `CsvFolder` to your copy of `03-sdtm/datasets/csv/`, ending with a backslash, for example `C:\LORNA\03-sdtm\datasets\csv\`.
4. Select **Refresh**.

If the SDTM programs are re-run, refresh the report so it shows the new datasets.

## Next steps

* \[ ] Add pages built on the ADaM datasets, such as treatment-emergent adverse events and responder rates at Week 12

