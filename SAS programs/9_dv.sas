/* Mapping the DV domain */

/* Creating a table with subject and DV data using left joins */
proc sql;
	create table final.dv as
	select d.SUBJECT_NUM, d.ERROR, d.VISIT_TYPE, d.VISIT_DATE, d.PLANNED_DAY,
		   sd.SUBJECT_ID, sd.SITE_ID
	from inter.deviations as d
	left join inter.subject_data as sd
	on d.SUBJECT_NUM=sd.SUBJECT_NUM
	order by SUBJECT_NUM;
quit;

/* Making the structure of the DV table and mapping elements */
data final.dv;
	retain STUDYID DOMAIN USUBJID DVSEQ DVTERM DVCAT TAETORD EPOCH DVSTDTC DVSTDY;
	length EPOCH DVSTDTC $10 DVTERM $25;
	set final.dv;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="DV";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	DVCAT=ERROR;
	DVSTDTC=put(VISIT_DATE, yymmdd10.);
	DVSTDY=PLANNED_DAY;

	if first.SUBJECT_ID then
		DVSEQ=1;
	else
		DVSEQ+1;

	if ARM_CODE in ("DRGA", "DRGB") then
		AEREL="POSSIBLY RELATED";
	else if ARM_CODE="PLC" then
		AEREL="UNLIKELY RELATED";

	if VISIT_TYPE="SCREENING" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
			DVTERM="MISSED SCREENING VISIT";
		end;

	if VISIT_TYPE="BASELINE" then
		do;
			TAETORD=2;
			EPOCH="TREATMENT1";
			DVTERM="MISSED BASELINE VISIT";
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT2";
			DVTERM="MISSED WEEK 4 VISIT";
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT3";
			DVTERM="MISSED WEEK 8 VISIT";
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT4";
			DVTERM="MISSED WEEK 12 VISIT";
		end;

	if VISIT_TYPE="FOLLOW-UP" then
		do;
			TAETORD=6;
			EPOCH="FOLLOW-UP";
			DVTERM="MISSED FOLLOW-UP VISIT";
		end;
	keep STUDYID DOMAIN USUBJID DVSEQ DVTERM DVCAT TAETORD EPOCH DVSTDTC DVSTDY;
run;