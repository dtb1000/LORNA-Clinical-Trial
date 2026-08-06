## **DATA DICTIONARY**

### **ae.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
TREATMENT: Treatment arm to which subject is assigned
VISIT: Visit during which adverse event was reported
REPORTED\_EVENT: Type of adverse event
SEVERITY: Severity of reported adverse event
SERIOUS: Seriousness of adverse event
START\_DATE: Start date of adverse event
END\_DATE: End date of adverse event

### **concom\_med.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
MEDICATION: Name of non-study drugs being taken by the subject
DOSE: Dose of concomitant medication
UNIT: Unit of dose
FORMULATION: Formulation of concomitant medication
FREQUENCY: Frequency of dose

### **deviations.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
ERROR: Type of deviation
VISIT\_TYPE: Type of visit
VISIT\_DATE: Date of visit

### **exposure.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
TREATMENT\_ARM: Treatment arm to which subject is assigned
ARM\_CODE: Treatment arm code
START\_DATE: Date on which treatment was started
END\_DATE: Date on which treatment was ended

### **labs.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
VISIT\_TYPE: Type of visit
VISIT\_DATE: Date of visit
TEST: Test code
TEST\_NAME: Full name of test parameter
RESULT: Measured value of test parameter
UNIT: Unit in which the test parameter is measured
LOWER: Normal lower limit of test parameter
UPPER: Normal upper limit of test parameter

### **medical\_history.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
MEDICAL\_BG: Underlying condition of the subject

### **study\_metadata.csv**
STUDY\_ID: ID of the clinical trial
PHASE: Phase of the clinical trial
STUDY\_TYPE: Study design of clinical trial
N\_SUBJECTS: Number of subjects enrolled
N\_SITES: Number of sites participating
COUNTRY: Country in which the clinical trial is taking place
SEED: Random seed number used to generate the synthetic clinical trial data

### **subjects.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
AGE: Age of subject
SEX: Sex of subject
RACE: Race of the subject
ETHNICITY: Ethnicity of the subject
ENROLLED\_ON: Date of subject enrollment

### **visits.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
VISIT\_TYPE: Type of visit
VISIT\_DATE: Date of visit

#### **vitals.csv**
SUBJECT\_NUM: Subject serial number
SUBJECT\_ID: Unique subject identifier
SITEID: Study site identifier
VISIT\_TYPE: Type of visit
VISIT\_DATE: Date of visit
TEST: Test code
TEST\_NAME: Full name of test parameter
RESULT: Measured value of test parameter
UNIT: Unit in which the test parameter is measured
