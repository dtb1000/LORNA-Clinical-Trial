/* Mapping the EX domain */

/* Creating a table with subject and EX data using left joins */
proc sql;
	create table final.ex as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID,
		   x.TREATMENT_ARM,
		   v.VISIT_NUM, v.VISIT_TYPE, v.VISIT_DATE,
		   vl.PLANNED_DAY
	from inter.subject_data as sd
	left join inter.exposure as x
	on sd.SUBJECT_NUM=x.SUBJECT_NUM
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
	retain STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSEU EXDOSFRM EXDOSFRQ 
		EXDOSRGM EXROUTE TAETORD EPOCH EXSTDTC EXENDTC EXSTDY;
	length EPOCH EXSTDTC EXENDTC $10 EXDOSRGM $35;
	set final.ex;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="EX";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	EXTRT=TREATMENT_ARM;
	EXDOSEU="mg";
	EXDOSFRM="TABLET";
	EXDOSFRQ="Q4W";
	EXDOSRGM="ONE TABLET ORALLY EVERY 4 WEEKS";
	EXROUTE="ORAL";
	EXSTDTC=put(VISIT_DATE, yymmdd10.);
	EXENDTC=put(VISIT_DATE, yymmdd10.);
	EXSTDY=PLANNED_DAY;

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
			EPOCH="TREATMENT1";
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT2";
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT3";
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT4";
			DVTERM="MISSED WEEK 12 VISIT";
		end;
	keep STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSEU EXDOSFRM EXDOSFRQ 
		EXDOSRGM EXROUTE TAETORD EPOCH EXSTDTC EXENDTC EXSTDY;
run;