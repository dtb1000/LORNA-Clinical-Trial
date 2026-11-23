/* Mapping the DM domain */

/* Creating an exposure date table */
proc sql;
	create table inter.exposure as
	select scan(USUBJID, 3, '-') as SUBJID length=7,
		   min(EXSTDTC) as RFXSTDTC length=10,
		   max(coalescec(EXENDTC, EXSTDTC)) as RFXENDTC length=10
	from final.ex
	group by SUBJID;
quit;

/* Creating a table with subject and demographic data using a left join */
proc sql;
	create table final.dm as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID, 
		   d.AGE, d.SEX, d.RACE, d.ETHNICITY,
		   re.TREATMENT_ARM, re.ARM_CODE,
		   ie.RFXSTDTC, ie.RFXENDTC
	from inter.subject_data as sd
	left join inter.demographics as d
	on sd.SUBJECT_NUM=d.SUBJECT_NUM
	left join raw.exposure as re
	on sd.SUBJECT_NUM=re.SUBJECT_NUM
	left join inter.exposure as ie
	on sd.SUBJECT_ID=ie.SUBJID;
quit;

/* Making the structure of the DM table and mapping some elements */
data final.dm;
	retain SUBJECT_NUM STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC 
		RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID AGE AGEU SEX RACE ETHNIC ARMCD 
		ARM ACTARMCD ACTARM ARMNRS ACTARMUD COUNTRY DMDTC;
	length SEX $16 RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DMDTC $10;
	set final.dm;
	STUDYID="LORNA";
	DOMAIN="DM";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	RFSTDTC=RFXSTDTC;
	RFENDTC=RFXENDTC;
	RFXSTDTC=RFXSTDTC;
	RFXENDTC=RFXENDTC;
	RFICDTC="";
	RFPENDTC="";
	DTHDTC="";
	DTHFL="";
	SITEID=SITE_ID;
	AGE=AGE;
	RACE=RACE;
	ETHNIC=ETHNICITY;
	ARMCD=ARM_CODE;
	ARM=upcase(TREATMENT_ARM);
	ACTARMCD=ARM_CODE;
	ACTARM=ARM;
	ARMNRS="";
	ACTARMUD="";
	COUNTRY="USA";
	DMDTC="";
	
	if AGE ne . then
		AGEU="YEARS";
	else
		AGEU="";
	
	if SEX="MALE" then
		SEX="M";
	if SEX="FEMALE" then
		SEX="F";
	if SEX="UNKNOWN" then
		SEX="U";
	if SEX="NOT SPECIFIED" then
		SEX="U";
	/* INTERSEX is kept as collected: it is the CDISC term (C45908) */
	
	if RACE="AFRICAN AMERICAN" then
		RACE="BLACK OR AFRICAN AMERICAN";
	if RACE="" then
		RACE="NOT REPORTED";
	
	if ETHNIC="HISPANIC" then
		ETHNIC="HISPANIC OR LATINO";
	if ETHNIC="" then
		ETHNIC="NOT REPORTED";
	
	keep SUBJECT_NUM STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC 
		RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID AGE AGEU SEX RACE ETHNIC ARMCD 
		ARM ACTARMCD ACTARM ARMNRS ACTARMUD COUNTRY DMDTC;
run;

/* Creating a table to extract dates for RFICDTC, RFPENDTC, and DMDTC */
proc sql;
	create table inter.dm_visit_dates as
	select SUBJECT_NUM,
		   max(case when VISIT_TYPE="SCREENING" then put(VISIT_DATE, yymmdd10.) end) as RFICDTC, 
		   max(case when VISIT_TYPE="SCREENING" then put(VISIT_DATE, yymmdd10.) end) as DMDTC,
		   /* Last visit attended, of any type */
		   max(put(VISIT_DATE, yymmdd10.)) as RFPENDTC length=10 
	from inter.visit
	group by SUBJECT_NUM;
quit;

/* Mapping the DM domain with RFICDTC, RFPENDTC, DMDTC, and DMDY */
data final.dm;
	merge final.dm inter.dm_visit_dates;
	by SUBJECT_NUM;
	if USUBJID="LORNA-SITE002-SUBJ037" then RFPENDTC="2023-05-05";
	
	/* Study day: no day 0, so add 1 on or after the first dose */
	if not missing(DMDTC) and not missing(RFSTDTC) then
		DMDY=input(DMDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (DMDTC >= RFSTDTC);
	drop SUBJECT_NUM;
run;

/* Sorting the final DM table */
proc sort data=final.dm;
	by STUDYID USUBJID;
run;