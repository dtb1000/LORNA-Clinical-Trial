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
		VSSTRESN VSSTRESU VSSTAT VSLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH VSDTC;
	length EPOCH VSDTC $10 VSTEST $40 VSORRES VSORRESU VSSTRESU VSSTAT $12;
	set final.vs;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="VS";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	VSTESTCD=TEST;
	VSSTRESN=RESULT;
	VISITNUM=VISIT_NUM;
	VISIT=VISIT_TYPE;
	VISITDY=PLANNED_DAY;
	VSLOBXFL="";

	if first.SUBJECT_ID then
		VSSEQ=1;
	else
		VSSEQ+1;
		
	select (TEST);
		when ("SYSBP") VSTEST="Systolic Blood Pressure";
		when ("DIABP") VSTEST="Diastolic Blood Pressure";
		when ("HR") VSTEST="Heart Rate";
		when ("RESP") VSTEST="Respiratory Rate";
		when ("TEMP") VSTEST="Temperature";
		when ("WEIGHT") VSTEST="Weight";
		otherwise VSTEST=TEST_NAME;
	end;
	
	if UNIT="bpm" then
		VSORRESU="beats/min";
	else
		VSORRESU=UNIT;
	
	VSSTRESU=VSORRESU;
	
	if not missing(RESULT) then
		do;
			VSORRES=strip(put(RESULT, best12.));
			VSSTRESC=VSORRES;
			VSSTAT="";
		end;
	else
		do;
			/* A measurement that was not done has no result and no units */
			VSORRES="";
			VSSTRESC="";
			VSORRESU="";
			VSSTRESU="";
			VSSTAT="NOT DONE";
		end;
	
	if not missing(VISIT_DATE) then
		VSDTC=put(VISIT_DATE, yymmdd10.);

	if VISIT_TYPE="SCREENING" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
		end;

	if VISIT_TYPE="BASELINE" then
		do;
			TAETORD=1;
			EPOCH="SCREENING";
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

	if VISIT_TYPE="FOLLOW-UP" then
		do;
			TAETORD=6;
			EPOCH="FOLLOW-UP";
		end;
	
	keep STUDYID DOMAIN USUBJID VSSEQ VSTESTCD VSTEST VSORRES VSORRESU VSSTRESC 
		VSSTRESN VSSTRESU VSSTAT VSLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH VSDTC;
run;

/* Sorting the VS table */
proc sort data=final.vs;
	by STUDYID USUBJID VSSEQ;
run;

/* Creating a table for VSLOBXFL */
proc sql;
	create table inter.vs_lobx as
	select v.USUBJID, v.VSSEQ
	from final.vs as v
	inner join final.dm as m
	on v.USUBJID=m.USUBJID
	where not missing(v.VSSTRESN) and v.VSDTC <= m.RFXSTDTC
	group by v.USUBJID, v.VSTESTCD
	having cats(v.VSDTC, put(v.VISITNUM, z3.)) = max(cats(v.VSDTC, put(v.VISITNUM, z3.)))
	order by v.USUBJID, v.VSSEQ;
quit;

/* Adding VSLOBXFL to the VS table */
data final.vs;
	merge final.vs(in=a) inter.vs_lobx(in=f);
	by USUBJID VSSEQ;
	if a;
	if f then
		VSLOBXFL="Y";
run;

/* Creating the final VS table with the study day */
data final.vs;
	merge final.vs(in=a) final.dm(keep=USUBJID RFSTDTC);
	by USUBJID;
	if a;
	
	/* Study day: no day 0, so add 1 on or after the first dose */
	if not missing(VSDTC) and not missing(RFSTDTC) then
		VSDY=input(VSDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (VSDTC >= RFSTDTC);
	drop RFSTDTC;
run;