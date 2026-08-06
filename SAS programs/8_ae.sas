/* Mapping the AE domain */

/* Creating a table with subject and AE data using left joins */
proc sql;
	create table final.ae as
	select s.SUBJECT_NUM, s.REPORTED_EVENT, s.VISIT, s.START_DATE, s.END_DATE,
		   m.LLT, m.LLTCD, m.PT, m.BODYSYS,
		   l.SEVERITY, l.SERIOUS,
		   x.ARM_CODE,
		   sd.SUBJECT_ID, sd.SITE_ID
	from inter.ae_subjects as s 
	left join inter.ae_meddra as m
	on s.REPORTED_EVENT=m.REPORTED_EVENT
	left join inter.ae_list as l
	on s.AE_CODE=l.AE_CODE
	left join inter.exposure as x
	on s.SUBJECT_NUM=x.SUBJECT_NUM
	left join inter.subject_data as sd
	on s.SUBJECT_NUM=sd.SUBJECT_NUM
	order by s.SUBJECT_NUM;
quit;

/* Making the structure of the AE table and mapping elements */
data final.ae;
	retain STUDYID DOMAIN USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEBODYSYS 
		AESEV AESER AEACN AEREL AESDTH AESHOSP TAETORD EPOCH AESTDTC AEENDTC;
	length EPOCH AESTDTC AEENDTC $10;
	set final.ae;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="AE";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	AETERM=REPORTED_EVENT;
	AELLT=LLT;
	AELLTCD=LLTCD;
	AEDECOD=PT;
	AEBODYSYS=BODYSYS;
	AESEV=SEVERITY;
	AESER=SERIOUS;
	AEACN="";
	AESDTH="N";
	AESHOSP="N";

	if first.SUBJECT_ID then
		AESEQ=1;
	else
		AESEQ+1;

	if ARM_CODE in ("DRGA", "DRGB") then
		AEREL="POSSIBLY RELATED";
	else if ARM_CODE="PLC" then
		AEREL="UNLIKELY RELATED";

	if VISIT="SCREENING" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
			AESTDTC=put(START_DATE, yymmdd10.);
			AEENDTC=put(END_DATE, yymmdd10.);
		end;

	if VISIT="BASELINE" then
		do;
			TAETORD=2;
			EPOCH="TREATMENT1";
			AESTDTC=put(START_DATE, yymmdd10.);
			AEENDTC=put(END_DATE, yymmdd10.);
		end;

	if VISIT="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT2";
			AESTDTC=put(START_DATE, yymmdd10.);
			AEENDTC=put(END_DATE, yymmdd10.);
		end;

	if VISIT="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT3";
			AESTDTC=put(START_DATE, yymmdd10.);
			AEENDTC=put(END_DATE, yymmdd10.);
		end;

	if VISIT="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT4";
			AESTDTC=put(START_DATE, yymmdd10.);
			AEENDTC=put(END_DATE, yymmdd10.);
		end;

	if VISIT="FOLLOW-UP" then
		do;
			TAETORD=6;
			EPOCH="FOLLOW-UP";
			AESTDTC=put(START_DATE, yymmdd10.);
			AEENDTC=put(END_DATE, yymmdd10.);
		end;
	keep STUDYID DOMAIN USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEBODYSYS AESEV 
		AESER AEACN AEREL AESDTH AESHOSP TAETORD EPOCH AESTDTC AEENDTC;
run;