/* Mapping the VS domain */

/* Creating a table with subject, VS, and visit data using left joins */
proc sql;
	create table final.vs as
	select vr.SUBJECT_NUM, vr.VISIT_TYPE, vr.TEST, vr.RESULT,
		   v.VISIT_NUM, v.VISIT_DATE,
		   vt.TEST_NAME, vt.UNIT,
		   sd.SUBJECT_ID, sd.SITE_ID,
		   vl.PLANNED_DAY
	from inter.vital_results as vr
	left join inter.visit as v
	on vr.SUBJECT_NUM=v.SUBJECT_NUM and vr.VISIT_TYPE=v.VISIT_TYPE
	left join inter.vital_tests as vt
	on vr.TEST=vt.TEST 
	left join inter.subject_data as sd
	on vr.SUBJECT_NUM=sd.SUBJECT_NUM
	left join inter.visit_lookup as vl
	on v.VISIT_NUM=vl.VISIT_NUM
	order by vr.SUBJECT_NUM, v.VISIT_NUM, vr.TEST;
quit;

/* Making the structure of the VS table and mapping elements */
data final.vs;
	retain STUDYID DOMAIN USUBJID VSSEQ VSTESTCD VSTEST VSORRES VSORRESU VSSTRESC 
		VSSTRESN VSSTRESU VSLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH VSDTC;
	length EPOCH VSDTC $10;
	set final.vs;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="VS";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	VSTESTCD=TEST;
	VSTEST=TEST_NAME;
	VSORRES=RESULT;
	VSORRESU=UNIT;
	VSSTRESC=strip(put(RESULT, best.));
	VSSTRESN=RESULT;
	VSSTRESU=UNIT;
	VISITNUM=VISIT_NUM;
	VISIT=VISIT_TYPE;
	VISITDY=PLANNED_DAY;
	VSDTC=put(VISIT_DATE, yymmdd10.);

	if first.SUBJECT_ID then
		VSSEQ=1;
	else
		VSSEQ+1;

	if VISIT_TYPE="SCREENING" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
			VSLOBXFL="Y";
		end;

	if VISIT_TYPE="BASELINE" then
		do;
			TAETORD=2;
			EPOCH="TREATMENT1";
			VSLOBXFL="N";
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT2";
			VSLOBXFL="N";
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT3";
			VSLOBXFL="N";
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT4";
			VSLOBXFL="N";
		end;

	if VISIT_TYPE="FOLLOW-UP" then
		do;
			TAETORD=6;
			EPOCH="FOLLOW-UP";
			VSLOBXFL="N";
		end;
	keep STUDYID DOMAIN USUBJID VSSEQ VSTESTCD VSTEST VSORRES VSORRESU VSSTRESC 
		VSSTRESN VSSTRESU VSLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH VSDTC;
run;