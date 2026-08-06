## **DATA DICTIONARY**

### **ae.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. TREATMENT: Treatment arm to which subject is assigned
5. VISIT: Visit during which adverse event was reported
6. REPORTED\_EVENT: Type of adverse event
7. SEVERITY: Severity of reported adverse event
8. SERIOUS: Seriousness of adverse event
9. START\_DATE: Start date of adverse event
10. END\_DATE: End date of adverse event

### **concom\_med.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. MEDICATION: Name of non-study drugs being taken by the subject
5. DOSE: Dose of concomitant medication
6. UNIT: Unit of dose
7. FORMULATION: Formulation of concomitant medication
8. FREQUENCY: Frequency of dose

### **deviations.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. ERROR: Type of deviation
5. VISIT\_TYPE: Type of visit
6. VISIT\_DATE: Date of visit

### **exposure.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. TREATMENT\_ARM: Treatment arm to which subject is assigned
5. ARM\_CODE: Treatment arm code
6. START\_DATE: Date on which treatment was started
7. END\_DATE: Date on which treatment was ended

### **labs.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. VISIT\_TYPE: Type of visit
5. VISIT\_DATE: Date of visit
6. TEST: Test code
7. TEST\_NAME: Full name of test parameter
8. RESULT: Measured value of test parameter
9. UNIT: Unit in which the test parameter is measured
10. LOWER: Normal lower limit of test parameter
11. UPPER: Normal upper limit of test parameter

### **medical\_history.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. MEDICAL\_BG: Underlying condition of the subject

### **study\_metadata.csv**
1. STUDY\_ID: ID of the clinical trial
2. PHASE: Phase of the clinical trial
3. STUDY\_TYPE: Study design of clinical trial
4. N\_SUBJECTS: Number of subjects enrolled
5. N\_SITES: Number of sites participating
6. COUNTRY: Country in which the clinical trial is taking place
7. SEED: Random seed number used to generate the synthetic clinical trial data

### **subjects.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. AGE: Age of subject
5. SEX: Sex of subject
6. RACE: Race of the subject
7. ETHNICITY: Ethnicity of the subject
8. ENROLLED\_ON: Date of subject enrollment

### **visits.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. VISIT\_TYPE: Type of visit
5. VISIT\_DATE: Date of visit

#### **vitals.csv**
1. SUBJECT\_NUM: Subject serial number
2. SUBJECT\_ID: Unique subject identifier
3. SITEID: Study site identifier
4. VISIT\_TYPE: Type of visit
5. VISIT\_DATE: Date of visit
6. TEST: Test code
7. TEST\_NAME: Full name of test parameter
8. RESULT: Measured value of test parameter
9. UNIT: Unit in which the test parameter is measured
