/* Mapping the LB domain */

/* Creating a table with subject, LB, and visit data using left joins */
proc sql;
	create table final.lb as
	select lr.SUBJECT_NUM, lr.VISIT_TYPE, lr.TEST, lr.RESULT,
		   v.VISIT_NUM, v.VISIT_DATE,
		   t.TEST_NAME, t.UNIT,
		   ll.LOWER, ll.UPPER,
		   sd.SUBJECT_ID, sd.SITE_ID,
		   vl.PLANNED_DAY
	from inter.lab_results as lr
	left join inter.visit as v
	on lr.SUBJECT_NUM=v.SUBJECT_NUM and lr.VISIT_TYPE=v.VISIT_TYPE
	left join inter.lab_tests as t
	on lr.TEST=t.TEST 
	left join inter.lab_limits as ll
	on lr.TEST=ll.TEST
	left join inter.subject_data as sd
	on lr.SUBJECT_NUM=sd.SUBJECT_NUM
	left join inter.visit_lookup as vl
	on v.VISIT_NUM=vl.VISIT_NUM
	order by lr.SUBJECT_NUM, v.VISIT_NUM, lr.TEST;
quit;

/* Making the structure of the LB table and mapping elements */
data final.lb;
	retain STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU 
		LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBNRIND 
		LBLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH LBDTC;
	length LBCAT LBNRIND EPOCH LBDTC $10;
	set final.lb;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="LB";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	LBTESTCD=TEST;
	LBTEST=TEST_NAME;
	LBORRES=RESULT;
	LBORRESU=UNIT;
	LBORNRLO=LOWER;
	LBORNRHI=UPPER;
	LBSTRESC=strip(put(RESULT, best.));
	LBSTRESN=RESULT;
	LBSTRESU=UNIT;
	LBSTNRLO=LOWER;
	LBSTNRHI=UPPER;
	LBNRIND="";
	VISITNUM=VISIT_NUM;
	VISIT=VISIT_TYPE;
	VISITDY=PLANNED_DAY;
	LBDTC=put(VISIT_DATE, yymmdd10.);

	if first.SUBJECT_ID then
		LBSEQ=1;
	else
		LBSEQ+1;
	
	if TEST in ("ALT", "AST", "CRP") then
		LBCAT="CHEMISTRY";
	else if TEST="HGB" then
		LBCAT="HEMATOLOGY";

	if RESULT=. then
		LBNRIND="";
	else if RESULT gt LOWER and RESULT lt UPPER then
		LBNRIND="NORMAL";
	else if RESULT lt LOWER then
		LBNRIND="LOW";
	else if RESULT gt UPPER then
		LBNRIND="HIGH";

	if VISIT_TYPE="SCREENING" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
			LBLOBXFL="Y";
		end;

	if VISIT_TYPE="BASELINE" then
		do;
			TAETORD=2;
			EPOCH="TREATMENT1";
			LBLOBXFL="N";
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT2";
			LBLOBXFL="N";
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT3";
			LBLOBXFL="N";
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT4";
			LBLOBXFL="N";
		end;

	if VISIT_TYPE="FOLLOW-UP" then
		do;
			TAETORD=6;
			EPOCH="FOLLOW-UP";
			LBLOBXFL="N";
		end;
	keep STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU 
		LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBNRIND 
		LBLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH LBDTC;
run;