/* Mapping the EX domain */

/* Creating a table with subject and EX data using left joins */
proc sql;
	create table final.ex as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID,
		   re.TREATMENT_ARM,
		   v.VISIT_NUM, v.VISIT_TYPE, v.VISIT_DATE,
		   vl.PLANNED_DAY
	from inter.subject_data as sd
	left join raw.exposure as re
	on sd.SUBJECT_NUM=re.SUBJECT_NUM
	left join inter.visit as v
	on sd.SUBJECT_NUM=v.SUBJECT_NUM
	left join inter.visit_lookup as vl
	on v.VISIT_NUM=vl.VISIT_NUM
	order by sd.SUBJECT_NUM, v.VISIT_NUM;
	delete from final.ex
	where VISIT_TYPE in ("SCREENING", "FOLLOW-UP");
quit;

/* Making the structure of the EX table and mapping elements */
data final.ex;
	retain STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ 
		EXDOSRGM EXROUTE TAETORD EPOCH EXSTDTC EXENDTC FIRSTDT EXSTDY EXENDY;
	length EPOCH EXSTDTC EXENDTC $10 EXDOSRGM $35;
	set final.ex;
	by SUBJECT_ID;
	
	if first.SUBJECT_ID then
		FIRSTDT=VISIT_DATE;
	
	EXSTDY=VISIT_DATE-FIRSTDT+1;
	/* Each dose is a single administration, so the end day equals the start day */
	EXENDY=EXSTDY;
	STUDYID="LORNA";
	DOMAIN="EX";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	EXTRT=upcase(TREATMENT_ARM);
	EXDOSU="mg";
	EXDOSFRM="TABLET";
	EXDOSFRQ="EVERY 4 WEEKS";
	EXDOSRGM="ONE TABLET ORALLY EVERY 4 WEEKS";
	EXROUTE="ORAL";
	EXSTDTC=put(VISIT_DATE, yymmdd10.);
	EXENDTC=put(VISIT_DATE, yymmdd10.);

	if first.SUBJECT_ID then
		EXSEQ=1;
	else
		EXSEQ+1;

	if EXTRT="DRUG A" then
		EXDOSE=200;
	else if EXTRT="DRUG B" then
		EXDOSE=300;
	else if EXTRT="PLACEBO" then
		EXDOSE=0;

	if VISIT_TYPE="BASELINE" then
		do;
			TAETORD=2;
			EPOCH="TREATMENT";
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT";
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT";
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT";
		end;
	
	keep STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ 
		EXDOSRGM EXROUTE TAETORD EPOCH EXSTDTC EXENDTC EXSTDY EXENDY;
run;

/* Sorting the final EX table */
proc sort data=final.ex;
	by STUDYID USUBJID EXSEQ;
run;