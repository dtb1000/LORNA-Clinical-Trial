#### **CLINICAL TRIAL DATA CLEANUP AND TRANSFORMATION PROJECT**

###### **Introduction**
This project was intended to demonstrate a small-scale end-to-end clinical data workflow using Python, SAS, SQL (PROC SQL), and Power BI.

###### **Workflow**
1. Generate random clinical trial data using Python
2. Validate and perform initial data cleanup using SAS
3. Map data into appropriate SDTM domains using SAS and SQL (PROC SQL)
4. Create dashboards to visualise trends using Power BI (to be updated)

###### **Simulated study details**
Study ID				            LORNA
Phase of CT				          Phase II
Trial design				        Parallel groups with randomisation
Treatment arms				      Placebo, Drug A, Drug B
Number of subjects			    300
Number of study sites			   4

###### **Files generated from the Python script**
ae.csv					             Contains reports of any adverse events
concom\_med.csv				       Contains information about any medications taken by subjects
deviations.csv				       Contains information about any protocol deviations
exposure.csv				         Contains information about the treatment arm as well as start and stop dates
labs.csv				             Contains lab test results for each subject during each visit
medical\_history.csv			   Contains information about any underlying conditions of subjects
study\_metadata.csv			     Contains data about the study
subjects.csv			         	 Contains data about each subject
visits.csv				           Contains data about each subject's visits
vitals.csv				           Contains vital signs measurements for each subject for each visit

###### **Intentional data quality issues**
1. Missing values
2. Invalid ages
3. Duplicate subjects
4. Inconsistent coding
5. Inconsistencies with visits (incorrect names, out-of-window visits, missed visits)
6. Out-of-range laboratory values

**Note:** Consult data\_dictionary.md for details about the variables in the CSV files.

**Note:** Consult modifying\_the\_code.md for information about how to make changes to the Python code parameters.

