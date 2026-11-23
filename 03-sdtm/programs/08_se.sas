/* Mapping the SE domain */

/* Creating a table with subject, visit, and element data using left joins */
proc sql;
	create table final.se as
	select distinct sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID,
					re.ARM_CODE,
					v.VISIT_NUM, v.VISIT_TYPE, v.VISIT_DATE
	from inter.subject_data as sd
	left join raw.exposure as re
	on sd.SUBJECT_NUM=re.SUBJECT_NUM
	left join inter.visit as v
	on sd.SUBJECT_NUM=v.SUBJECT_NUM;
quit;

/* Making the structure of the SE table and mapping elements */
data final.se;
	retain STUDYID DOMAIN USUBJID SESEQ ETCD ELEMENT TAETORD EPOCH SESTDTC SEENDTC;
	length EPOCH SESTDTC SEENDTC $10;
	set final.se;
	STUDYID="LORNA";
	DOMAIN="SE";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	SESEQ=VISIT_NUM;
	
	if VISIT_TYPE="SCREENING" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+14, yymmdd10.);
		end;

	if VISIT_TYPE="BASELINE" then
		do;
			TAETORD=2;
			EPOCH="TREATMENT";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="FOLLOW-UP" then
		do;
			TAETORD=6;
			EPOCH="FOLLOW-UP";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=SESTDTC;
		end;
	
	
	if ARM_CODE="DRGA" and EPOCH="TREATMENT" then
		do;
			ETCD="TRTA";
			ELEMENT="DRUG A 200 MG";
		end;
	else if ARM_CODE="DRGB" and EPOCH="TREATMENT" then
		do;
			ETCD="TRTB";
			ELEMENT="DRUG B 300 MG";
		end;
	else if ARM_CODE="PLC" and EPOCH="TREATMENT" then
		do;
			ETCD="PLC";
			ELEMENT="PLACEBO";
		end;
	else if EPOCH="SCREENING" then
		do;
			ETCD="SCRN";
			ELEMENT="SCREENING";
		end;
	else if EPOCH="FOLLOW-UP" then
		do;
		ETCD="FU";
			ELEMENT="FOLLOW-UP";
		end;
	
	keep STUDYID DOMAIN USUBJID SESEQ ETCD ELEMENT TAETORD EPOCH SESTDTC SEENDTC;
run;

/* An ELEMENT ends when the next TREATMENT begins */
proc sort data=final.se;
	by USUBJID descending TAETORD;
run;

data final.se;
	set final.se;
	by USUBJID descending TAETORD;
	length next_st $10 next_et $4;
	retain next_st next_et;
	
	if first.USUBJID then
		call missing(next_st, next_et);
	if next_et not in ("", "FU") then
		SEENDTC=next_st;
		
	next_st=SESTDTC;
	next_et=ETCD;
	drop next_st next_et;
run;

/* FOLLOW-UP begins when the last TREATMENT ends */
proc sort data=final.se;
	by USUBJID TAETORD;
run;

data final.se;
	set final.se;
	by USUBJID;
	length prev_en $10;
	retain prev_en;
	
	if first.USUBJID then
		prev_en="";
	if ETCD="FU" and not missing(prev_en) then
		SESTDTC=prev_en;
		
	prev_en=SEENDTC;
	drop prev_en;
run;

/* The final ELEMENT at the end of trial participation, and the study days */
data final.se;
	merge final.se(in=a) final.dm(keep=USUBJID RFSTDTC RFPENDTC);
	by USUBJID;
	
	if a;
	
	if last.USUBJID then
		SEENDTC=RFPENDTC;
	
	/* Study day: no day 0, so add 1 on or after the first dose */
	if not missing(SESTDTC) and not missing(RFSTDTC) then
		SESTDY=input(SESTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (SESTDTC >= RFSTDTC);
	if not missing(SEENDTC) and not missing(RFSTDTC) then
		SEENDY=input(SEENDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (SEENDTC >= RFSTDTC);
	drop RFSTDTC RFPENDTC;
run;

/* Sorting the final SE table */
proc sort data=final.se;
	by STUDYID USUBJID SESEQ;
run;