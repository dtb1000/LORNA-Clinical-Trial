/* Normalising information in SAS tables */

/* STUDY table */
data inter.study;
	retain STUDY_ID INDICATION COUNTRY START_DATE END_DATE PHASE N_SITES 
		N_SUBJECTS STUDY_TYPE RANDOMIZATION BLINDING SEED;
	set raw.study_metadata;
	PHASE=upcase(PHASE);
	INDICATION="CHRONIC LIVER DISEASE";
	RANDOMIZATION="1:1:1";
	BLINDING="DOUBLE BLIND";
	START_DATE="15JUN2022"d;
	END_DATE="14JUN2024"d;
	format START_DATE END_DATE yymmdd10.;
run;

/* SITE table */
data inter.site;
	retain SITE_ID COUNTRY;
	set raw.study_metadata;

	do i=1 to 4;
		SITE_ID=cats("SITE00", i);
		output;
	end;
	keep SITE_ID COUNTRY;
run;

/* SUBJECT_DATA table */
data inter.subject_data;
	retain SUBJECT_NUM SUBJECT_ID SITE_ID RAND_DATE ENROLLED_ON;
	set raw.subjects;
	RAND_DATE=ENROLLED_ON-7;
	format RAND_DATE ENROLLED_ON yymmdd10.;
	keep SUBJECT_NUM SUBJECT_ID SITE_ID RAND_DATE ENROLLED_ON;
run;

/* DEMOGRAPHICS table */
data inter.demographics;
	retain SUBJECT_NUM AGE SEX RACE ETHNICITY;
	set raw.subjects;

	/* Cleaning up the SEX variable */
	SEX=upcase(SEX);

	if SEX=" " then
		SEX="UNKNOWN";

	if SEX="MAN" then
		SEX="MALE";

	if SEX="WOMAN" then
		SEX="FEMALE";

	/* Cleaning up the RACE variable */
	RACE=upcase(RACE);

	/* Cleaning up the ETHNICITY variable */
	ETHNICITY=upcase(ETHNICITY);

	if ETHNICITY="HISPANIC NOT LATINO" then
		ETHNICITY="HISPANIC OR LATINO";

	if ETHNICITY="NOT HISPANIC NOT LATINO" then
		ETHNICITY="NOT HISPANIC OR LATINO";

	/* Cleaning up the AGE variable */
	if AGE<18 or AGE>85 then
		AGE=.;
	keep SUBJECT_NUM AGE SEX RACE ETHNICITY;
run;

/* VISIT table */
data inter.visit;
	retain SUBJECT_NUM VISIT_NUM VISIT_TYPE VISIT_DATE;
	set raw.visits;

	/* Assigning visit numbers */
	if VISIT_TYPE="SCREENING" then
		VISIT_NUM=1;
	else if VISIT_TYPE="BASELINE" then
		VISIT_NUM=2;
	else if VISIT_TYPE="WEEK 4" then
		VISIT_NUM=3;
	else if VISIT_TYPE="WEEK 8" then
		VISIT_NUM=4;
	else if VISIT_TYPE="WEEK 12" then
		VISIT_NUM=5;
	else if VISIT_TYPE="FOLLOW-UP" then
		VISIT_NUM=6;
	keep SUBJECT_NUM VISIT_NUM VISIT_TYPE VISIT_DATE;
run;

/* ARMS table */
proc sql;
	create table inter.arms as
	select distinct ARM_CODE, TREATMENT_ARM
	from inter.exposure
	order by ARM_CODE;
quit;

/* EXPOSURE table */
data inter.exposure;
	retain SUBJECT_NUM TREATMENT_ARM ARM_CODE START_DATE END_DATE;
	set raw.exposure;
	TREATMENT_ARM=upcase(TREATMENT_ARM);
	keep SUBJECT_NUM TREATMENT_ARM ARM_CODE START_DATE END_DATE;
run;

/* LAB_TESTS table */
proc sql;
	create table inter.lab_tests as
	select distinct TEST, upcase(TEST_NAME) as TEST_NAME, UNIT
	from raw.labs;
quit;

/* LAB_LIMITS table */
proc sql;
	create table inter.lab_limits as
	select distinct TEST, LOWER, UPPER
	from raw.labs;
quit;

/* LAB_RESULTS table */
data inter.lab_results;
	retain SUBJECT_NUM VISIT_TYPE TEST RESULT;
	set raw.labs;
	keep SUBJECT_NUM VISIT_TYPE TEST RESULT;
run;

/* VITAL_TESTS table */
proc sql;
	create table inter.vital_tests as
	select distinct TEST, upcase(TEST_NAME) as TEST_NAME, UNIT
	from raw.vitals;
quit;

/* VITAL_RESULTS table */
data inter.vital_results;
	retain SUBJECT_NUM VISIT_TYPE TEST RESULT;
	set raw.vitals;
	keep SUBJECT_NUM VISIT_TYPE TEST RESULT;
run;

/* MED_HIST table */
data inter.med_hist;
	retain SUBJECT_NUM MEDICAL_BG;
	set raw.medical_history;
	MEDICAL_BG=upcase(MEDICAL_BG);
	keep SUBJECT_NUM MEDICAL_BG;
run;

/* CONMED_LIST table */
proc sql;
	create table inter.conmed_list as
	select distinct upcase(MEDICATION) as MEDICATION, DOSE, UNIT, upcase(FORMULATION) as FORMULATION, FREQUENCY
	from raw.concom_med;
quit;

data inter.conmed_list;
	length MED_CODE $15;
	set inter.conmed_list;

	/* Assigning codes to Lisinopril */
	if MEDICATION="LISINOPRIL" and DOSE=2.5 then
		MED_CODE="LIS2.5";
	else if MEDICATION="LISINOPRIL" and DOSE=5 then
		MED_CODE="LIS5";
	else if MEDICATION="LISINOPRIL" and DOSE=10 then
		MED_CODE="LIS10";
	else if MEDICATION="LISINOPRIL" and DOSE=20 then
		MED_CODE="LIS20";
	else if MEDICATION="LISINOPRIL" and DOSE=40 then
		MED_CODE="LIS40";

	/* Assigning codes to Losartan */
	if MEDICATION="LOSARTAN" and DOSE=25 then
		MED_CODE="LOS25";
	else if MEDICATION="LOSARTAN" and DOSE=50 then
		MED_CODE="LOS50";
	else if MEDICATION="LOSARTAN" and DOSE=100 then
		MED_CODE="LOS100";

	/* Assigning codes to Metformin */
	if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET500ERBID";
	else if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET500ERQD";
	else if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET500IRBID";
	else if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET500IRQD";
	else if MEDICATION="METFORMIN" and DOSE=850 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET850IRBID";
	else if MEDICATION="METFORMIN" and DOSE=850 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET850IRQD";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET1000ERBID";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="TID" then
			MED_CODE="MET1000ERTID";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET1000IRBID";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET1000IRQD";

	/* Assigning codes to Simvastatin */
	if MEDICATION="SIMVASTATIN" and DOSE=5 then
		MED_CODE="SIM5";
	else if MEDICATION="SIMVASTATIN" and DOSE=10 then
		MED_CODE="SIM10";
	else if MEDICATION="SIMVASTATIN" and DOSE=20 then
		MED_CODE="SIM20";
	else if MEDICATION="SIMVASTATIN" and DOSE=40 then
		MED_CODE="SIM40";
run;

/* CONMED_SUBJECTS table */
data inter.conmed_subjects;
	retain SUBJECT_NUM MED_CODE;
	length MED_CODE $15;
	set raw.concom_med;
	MEDICATION=upcase(MEDICATION);
	FORMULATION=upcase(FORMULATION);
	UNIT=upcase(UNIT);

	/* Assigning codes to Lisinopril */
	if MEDICATION="LISINOPRIL" and DOSE=2.5 then
		MED_CODE="LIS2.5";
	else if MEDICATION="LISINOPRIL" and DOSE=5 then
		MED_CODE="LIS5";
	else if MEDICATION="LISINOPRIL" and DOSE=10 then
		MED_CODE="LIS10";
	else if MEDICATION="LISINOPRIL" and DOSE=20 then
		MED_CODE="LIS20";
	else if MEDICATION="LISINOPRIL" and DOSE=40 then
		MED_CODE="LIS40";

	/* Assigning codes to Losartan */
	if MEDICATION="LOSARTAN" and DOSE=25 then
		MED_CODE="LOS25";
	else if MEDICATION="LOSARTAN" and DOSE=50 then
		MED_CODE="LOS50";
	else if MEDICATION="LOSARTAN" and DOSE=100 then
		MED_CODE="LOS100";

	/* Assigning codes to Metformin */
	if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET500ERBID";
	else if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET500ERQD";
	else if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET500IRBID";
	else if MEDICATION="METFORMIN" and DOSE=500 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET500IRQD";
	else if MEDICATION="METFORMIN" and DOSE=850 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET850IRBID";
	else if MEDICATION="METFORMIN" and DOSE=850 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET850IRQD";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET1000ERBID";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="EXTENDED-RELEASE TABLET" and FREQUENCY="TID" then
			MED_CODE="MET1000ERTID";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="BID" then
			MED_CODE="MET1000IRBID";
	else if MEDICATION="METFORMIN" and DOSE=1000 and 
		FORMULATION="IMMEDIATE-RELEASE TABLET" and FREQUENCY="QD" then
			MED_CODE="MET1000IRQD";

	/* Assigning codes to Simvastatin */
	if MEDICATION="SIMVASTATIN" and DOSE=5 then
		MED_CODE="SIM5";
	else if MEDICATION="SIMVASTATIN" and DOSE=10 then
		MED_CODE="SIM10";
	else if MEDICATION="SIMVASTATIN" and DOSE=20 then
		MED_CODE="SIM20";
	else if MEDICATION="SIMVASTATIN" and DOSE=40 then
		MED_CODE="SIM40";
	keep SUBJECT_NUM MED_CODE MEDICATION;
run;

/* AE_LIST table */
proc sql;
	create table inter.ae_list as
	select distinct upcase(REPORTED_EVENT) as REPORTED_EVENT, SEVERITY, SERIOUS
	from raw.ae;
quit;

data inter.ae_list;
	length AE_CODE $6;
	set inter.ae_list;

	/* Assigning codes to allergy */
	if REPORTED_EVENT="ALLERGY" then
		AE_CODE="ALG";

	/* Assigning codes to dizziness */
	if REPORTED_EVENT="DIZZINESS" and SEVERITY="MILD" then
		AE_CODE="DIZMIL";
	else if REPORTED_EVENT="DIZZINESS" and SEVERITY="MODERATE" then
		AE_CODE="DIZMOD";

	/* Assigning codes to fatigue */
	if REPORTED_EVENT="FATIGUE" and SEVERITY="MILD" then
		AE_CODE="FATMIL";
	else if REPORTED_EVENT="FATIGUE" and SEVERITY="MODERATE" then
		AE_CODE="FATMOD";
	else if REPORTED_EVENT="FATIGUE" and SEVERITY="SEVERE" then
		AE_CODE="FATSEV";

	/* Assigning codes to headache */
	if REPORTED_EVENT="HEADACHE" and SEVERITY="MILD" then
		AE_CODE="HEAMIL";
	else if REPORTED_EVENT="HEADACHE" and SEVERITY="MODERATE" then
		AE_CODE="HEAMOD";
	else if REPORTED_EVENT="HEADACHE" and SEVERITY="SEVERE" then
		AE_CODE="HEASEV";

	/* Assigning codes to nausea */
	if REPORTED_EVENT="NAUSEA" and SEVERITY="MILD" then
		AE_CODE="NAUMIL";
	else if REPORTED_EVENT="NAUSEA" and SEVERITY="MODERATE" then
		AE_CODE="NAUMOD";
	else if REPORTED_EVENT="NAUSEA" and SEVERITY="SEVERE" then
		AE_CODE="NAUSEV";
run;

/* AE_MedDRA table */
proc sql;
	create table inter.ae_meddra as
	select distinct REPORTED_EVENT
	from inter.ae_list;
quit;


data inter.ae_meddra;
	retain REPORTED_EVENT LLT LLTCD PT BODYSYS;
	length BODYSYS $25;
	set inter.ae_meddra;
	REPORTED_EVENT=upcase(REPORTED_EVENT);

	if REPORTED_EVENT="ALLERGY" then
		do;
			LLT="Drug allergy";
			LLTCD=10013661;
			PT="Drug hypersensitivity";
			BODYSYS="Immune system";
		end;

	if REPORTED_EVENT="DIZZINESS" then
		do;
			LLT="Dizziness";
			LLTCD=10013573;
			PT="Dizziness";
			BODYSYS="Nervous system";
		end;

	if REPORTED_EVENT="FATIGUE" then
		do;
			LLT="Fatigue";
			LLTCD=10016256;
			PT="Fatigue";
			BODYSYS="General system";
		end;

	if REPORTED_EVENT="HEADACHE" then
		do;
			LLT="Headache";
			LLTCD=10019211;
			PT="Headache";
			BODYSYS="Nervous system";
		end;

	if REPORTED_EVENT="NAUSEA" then
		do;
			LLT="Nausea";
			LLTCD=10028813;
			PT="Nausea";
			BODYSYS="Gastrointestinal system";
		end;
	keep REPORTED_EVENT LLT LLTCD PT BODYSYS;
run;

/* AE_SUBJECTS table */
data inter.ae_subjects;
	retain SUBJECT_NUM REPORTED_EVENT AE_CODE VISIT START_DATE END_DATE;
	length AE_CODE $6;
	set raw.ae;
	REPORTED_EVENT=upcase(REPORTED_EVENT);

	/* Assigning codes to allergy */
	if REPORTED_EVENT="ALLERGY" then
		AE_CODE="ALG";

	/* Assigning codes to dizziness */
	if REPORTED_EVENT="DIZZINESS" and SEVERITY="MILD" then
		AE_CODE="DIZMIL";
	else if REPORTED_EVENT="DIZZINESS" and SEVERITY="MODERATE" then
		AE_CODE="DIZMOD";

	/* Assigning codes to fatigue */
	if REPORTED_EVENT="FATIGUE" and SEVERITY="MILD" then
		AE_CODE="FATMIL";
	else if REPORTED_EVENT="FATIGUE" and SEVERITY="MODERATE" then
		AE_CODE="FATMOD";
	else if REPORTED_EVENT="FATIGUE" and SEVERITY="SEVERE" then
		AE_CODE="FATSEV";

	/* Assigning codes to headache */
	if REPORTED_EVENT="HEADACHE" and SEVERITY="MILD" then
		AE_CODE="HEAMIL";
	else if REPORTED_EVENT="HEADACHE" and SEVERITY="MODERATE" then
		AE_CODE="HEAMOD";
	else if REPORTED_EVENT="HEADACHE" and SEVERITY="SEVERE" then
		AE_CODE="HEASEV";

	/* Assigning codes to nausea */
	if REPORTED_EVENT="NAUSEA" and SEVERITY="MILD" then
		AE_CODE="NAUMIL";
	else if REPORTED_EVENT="NAUSEA" and SEVERITY="MODERATE" then
		AE_CODE="NAUMOD";
	else if REPORTED_EVENT="NAUSEA" and SEVERITY="SEVERE" then
		AE_CODE="NAUSEV";
	keep SUBJECT_NUM REPORTED_EVENT AE_CODE VISIT START_DATE END_DATE;
run;

/* VISIT_LOOKUP table */
proc sql;
	create table inter.visit_lookup as
	select distinct VISIT_NUM, VISIT_TYPE
	from inter.visit;
quit;

data inter.visit_lookup;
	retain VISIT_NUM VISIT_TYPE PLANNED_DAY;
	set inter.visit_lookup;

	/* Assigning planned days */
	if VISIT_NUM=1 then
		PLANNED_DAY="-14";
	else if VISIT_NUM=2 then
		PLANNED_DAY="1";
	else if VISIT_NUM=3 then
		PLANNED_DAY="29";
	else if VISIT_NUM=4 then
		PLANNED_DAY="57";
	else if VISIT_NUM=5 then
		PLANNED_DAY="85";
	else if VISIT_NUM=6 then
		PLANNED_DAY="113";
	keep VISIT_NUM VISIT_TYPE PLANNED_DAY;
run;

/* DEVIATIONS table */
proc sql;
	create table inter.deviations as
	select d.SUBJECT_NUM, upcase(d.ERROR) as ERROR, d.VISIT_TYPE, d.VISIT_DATE,
		   vl.PLANNED_DAY
	from raw.deviations as d
	left join inter.visit_lookup as vl
	on d.VISIT_TYPE=vl.VISIT_TYPE
	order by SUBJECT_NUM;
quit;