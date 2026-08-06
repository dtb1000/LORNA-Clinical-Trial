/* Mapping the DM domain */

/* Creating a table with subject and demographic data using a left join */
proc sql;
	create table final.dm as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID, 
		   d.AGE, d.SEX, d.RACE, d.ETHNICITY,
		   e.TREATMENT_ARM, e.ARM_CODE, e.START_DATE, e.END_DATE
	from inter.subject_data as sd
	left join inter.demographics as d
	on sd.SUBJECT_NUM=d.SUBJECT_NUM
	left join inter.exposure as e
	on sd.SUBJECT_NUM=e.SUBJECT_NUM;
quit;

/* Making the structure of the DM table and mapping some elements */
data final.dm;
	retain SUBJECT_NUM STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC 
		RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID AGE AGEU SEX RACE ETHNIC ARMCD 
		ARM ACTARMCD ARMNS ACTARMUD COUNTRY DMDTC;
	length RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DMDTC $10;
	set final.dm;
	STUDYID="LORNA";
	DOMAIN="DM";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	RFSTDTC=put(START_DATE, yymmdd10.);
	RFENDTC=put(END_DATE, yymmdd10.);
	RFXSTDTC=put(START_DATE, yymmdd10.);
	RFXENDTC=put(END_DATE, yymmdd10.);
	RFICDTC="";
	RFPENDTC="";
	DTHDTC="";
	DTHFL="";
	SITEID=SITE_ID;
	AGE=AGE;
	AGEU="YEARS";
	SEX=SEX;
	RACE=RACE;
	ETHNIC=ETHNICITY;
	ARMCD=ARM_CODE;
	ARM=TREATMENT_ARM;
	ACTARMCD=ARM_CODE;
	ARMNS="";
	ACTARMUD="";
	COUNTRY="USA";
	DMDTC="";
	keep SUBJECT_NUM STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC 
		RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID AGE AGEU SEX RACE ETHNIC ARMCD 
		ARM ACTARMCD ARMNS ACTARMUD COUNTRY DMDTC;
run;

/* Creating a table to extract dates for RFICDTC, RFPENDTC, and DMDTC */
proc sql;
	create table inter.dm_visit_dates as
	select SUBJECT_NUM,
		   max(case when VISIT_TYPE="SCREENING" then put(VISIT_DATE, yymmdd10.) end) as RFICDTC, 
		   max(case when VISIT_TYPE="SCREENING" then put(VISIT_DATE, yymmdd10.) end) as DMDTC,
		   /* Follow-up date if attended */
		   max(case when VISIT_TYPE="FOLLOW-UP" then put(VISIT_DATE, yymmdd10.) end) as FUDATE, 
		   /* Week 12 date */
		   max(case when VISIT_TYPE="WEEK 12" then put(VISIT_DATE, yymmdd10.) end) as WK12DATE, 
		   /* Use Follow-up, otherwise Week 12 */
		   coalesce(calculated FUDATE, calculated WK12DATE) as RFPENDTC 
	from inter.visit
	group by SUBJECT_NUM;
quit;

/* Mapping the DM domain with RFICDTC, RFPENDTC, and DMDTC */
data final.dm;
	merge final.dm inter.dm_visit_dates;
	by SUBJECT_NUM;
	if RFPENDTC="" then RFPENDTC="";
	drop SUBJECT_NUM FUDATE WK12DATE;
run;