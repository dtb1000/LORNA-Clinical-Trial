## **CLINICAL TRIAL DATA CLEANUP AND TRANSFORMATION PROJECT**

### **Introduction**
This project was intended to demonstrate a small-scale end-to-end clinical data workflow using Python, SAS, SQL (PROC SQL), and Power BI.

### **Workflow**
1. Generate random clinical trial data using Python
2. Validate and perform initial data cleanup using SAS
3. Map data into appropriate SDTM domains using SAS and SQL (PROC SQL)
4. Create dashboards to visualise trends using Power BI (to be updated)

### **Simulated study details**
1. Study ID: LORNA
2. Phase of CT: Phase II
3. Trial design: Parallel groups with randomisation
4. Treatment arms: Placebo, Drug A, Drug B
5. Number of subjects: 300
6. Number of study sites: 4

### **Files generated from the Python script**
1. ae.csv: Contains reports of any adverse events
2. concom\_med.csv: Contains information about any medications taken by subjects
3. deviations.csv: Contains information about any protocol deviations
4. exposure.csv: Contains information about the treatment arm as well as start and stop dates
5. labs.csv: Contains lab test results for each subject during each visit
6. medical\_history.csv: Contains information about any underlying conditions of subjects
7. study\_metadata.csv: Contains data about the study
8. subjects.csv: Contains data about each subject
9. visits.csv: Contains data about each subject's visits
10. vitals.csv: Contains vital signs measurements for each subject for each visit

### **Intentional data quality issues**
1. Missing values
2. Invalid ages
3. Duplicate subjects
4. Inconsistent coding
5. Inconsistencies with visits (incorrect names, out-of-window visits, missed visits)
6. Out-of-range laboratory values

**Note:** Consult data\_dictionary.md for details about the variables in the CSV files.

**Note:** Consult tutorial.md for information about how to run the Python code and make changes.

