#### **SYNTHETIC CLINICAL TRIAL DATA GENERATOR**



###### **OVERVIEW**



This project generates realistic synthetic clinical trial datasets for use in clinical programming, data management, SDTM mapping, and SAS programming projects. The generator simulates a complete Phase II parallel-group clinical trial, producing multiple related datasets that mimic those collected during an actual study.



###### **FEATURES**



The generator creates data for:

* Study metadata
* Subject demographics
* Treatment exposure
* Medical history
* Concomitant medications
* Study visits
* Protocol deviations
* Laboratory results
* Vital signs
* Adverse events



It also includes:

* Random treatment allocation
* Longitudinal laboratory trends
* Visit schedules
* Missing values
* Data quality errors
* Random protocol deviations
* Subject-specific treatment responses
* Reproducible random number generation using a user-defined seed



###### **RUNNING THE GENERATOR**



When the Python file is executed, the script asks for 2 inputs -



**Input a random number between 1 and 10000:**

Using the same seed will reproduce exactly the same clinical trial - different seeds generate different studies.



**Input the desired quality of output data:**

Possible values are CLEAN, MODERATE, and SEVERE. These determine the proportion of missing values and intentionally introduced errors - the percentages of missing values and errors are defined in QUALITY\_SETTINGS.



After execution, a folder called raw\_data is created, containing 10 CSV files -

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



###### **HOW THE GENERATOR WORKS**



**Step 1 - Study setup**

The script defines the study configuration, treatment arms, visit schedule, laboratory tests, vital signs, adverse event profiles, and medication dictionaries before generating any subjects.



**Step 2 - Create subjects**

Each subject is assigned the following attributes -

* Subject ID
* Site ID
* Age
* Sex
* Race
* Ethnicity
* Enrolment date
* Treatment assignment

Some demographic values may be missing depending on the selected data quality setting.



**Step 3 - Medical history**

Approximately 30% of subjects receive one or more medical conditions. Possible conditions are -

* Hypertension
* Type 2 Diabetes
* Hyperlipidaemia
* Stroke

Each condition has its own prevalence and automatically generates an appropriate concomitant medication.



**Step 4 - Visits**

Each subject follows the scheduled visit calendar. Some post-baseline visits are randomly missed and recorded as protocol deviations. In all other cases, the visit is added to the visit dataset.



**Step 5 - Laboratory results**

Baseline laboratory values are generated using normal distributions, and subsequent visits apply treatment-specific effects.

* Drug A generally produces the greatest improvement.
* Drug B produces a smaller improvement.
* The placebo produces little or no improvement.

Random biological variability is added to every measurement.



**Step 6 - Vital signs**

Vital signs are generated independently for every visit. The generator includes normal values, mild abnormalities, and rare extreme outliers. Parameters monitored are -

* Systolic blood pressure
* Diastolic blood pressure
* Heart rate
* Respiratory rate
* Temperature
* Weight



**Step 7 - Adverse events**

Each treatment arm has its own safety profile. For every possible adverse event, the script determines -

* Whether the event occurs
* Severity
* Seriousness
* Start date
* End date

This produces realistic adverse event datasets suitable for SDTM AE mapping.



###### **UTILITY FUNCTIONS USED IN THE SCRIPT**



Several helper functions are defined to keep the code modular. These can be slightly altered depending on the user's aims to produce more/less/different data. The helper functions defined within the script are -

1. maybe\_missing(): Randomly introduces missing values
2. weighted\_choice(): Performs probability-weighted sampling
3. maybe\_invalid\_age(): Occasionally generates impossible ages
4. random\_enrolment\_date(): Creates enrolment dates
5. create\_baseline\_labs(): Generates baseline laboratory values
6. create\_vital\_signs(): Simulates realistic vital signs
7. create\_subject\_response(): Creates subject-specific treatment responses
8. treatment\_effect(): Applies treatment effects over time



###### **LICENSE AND DISCLAIMER**



The Python script has been made open-source for anyone to use, modify, and improve. This project is intended for educational and portfolio purposes. The generated data are entirely synthetic and contain no real patient information.

