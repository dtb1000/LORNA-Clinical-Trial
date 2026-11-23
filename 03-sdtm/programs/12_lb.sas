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
		LBSTAT LBLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH LBDTC;
	length LBTEST $40 LBCAT LBNRIND EPOCH LBDTC $10 LBORRES LBORNRLO LBORNRHI $12;
	set final.lb;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="LB";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	LBTESTCD=TEST;
	
	/* LBTEST uses the CDISC term for each test code */
	select (TEST);
		when ("ALT") LBTEST="Alanine Aminotransferase";
		when ("AST") LBTEST="Aspartate Aminotransferase";
		when ("CRP") LBTEST="C Reactive Protein";
		when ("HGB") LBTEST="Hemoglobin";
		otherwise LBTEST=TEST_NAME;
	end;
	
	LBORRESU=UNIT;
	LBSTRESN=RESULT;
	LBSTRESU=UNIT;
	LBSTNRLO=LOWER;
	LBSTNRHI=UPPER;
	LBNRIND="";
	VISITNUM=VISIT_NUM;
	VISIT=VISIT_TYPE;
	VISITDY=PLANNED_DAY;
	LBLOBXFL="";

	if first.SUBJECT_ID then
		LBSEQ=1;
	else
		LBSEQ+1;
	
	if not missing(RESULT) then
		LBORRES=strip(put(RESULT, best12.));
	else
		LBORRES="";
	
	if not missing(LOWER) then
		LBORNRLO=strip(put(LOWER, best12.));
	
	if not missing(UPPER) then
		LBORNRHI=strip(put(UPPER, best12.));
	
	/* A test that was not done has no units and no reference range */
	if missing(RESULT) then
		do;
			LBORRESU="";
			LBSTRESU="";
			LBORNRLO="";
			LBORNRHI="";
			LBSTNRLO=.;
			LBSTNRHI=.;
		end;
	
	if not missing(VISIT_DATE) then
		LBDTC=put(VISIT_DATE, yymmdd10.);
	
	if not missing(LBSTRESN) then
		LBSTRESC=strip(put(LBSTRESN, best12.));
	else
		LBSTRESC="";
	
	if missing(LBORRES) then
		LBSTAT="NOT DONE";
	else
		LBSTAT="";
	
	if TEST in ("ALT", "AST", "CRP") then
		LBCAT="CHEMISTRY";
	else if TEST="HGB" then
		LBCAT="HEMATOLOGY";

	if missing(RESULT) then
		LBNRIND="";
	else if RESULT lt LOWER then
		LBNRIND="LOW";
	else if RESULT gt UPPER then
		LBNRIND="HIGH";
	else
		LBNRIND="NORMAL";

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
	
	keep STUDYID DOMAIN USUBJID LBSEQ LBTESTCD LBTEST LBCAT LBORRES LBORRESU 
		LBORNRLO LBORNRHI LBSTRESC LBSTRESN LBSTRESU LBSTNRLO LBSTNRHI LBNRIND 
		LBSTAT LBLOBXFL VISITNUM VISIT VISITDY TAETORD EPOCH LBDTC;
run;

/* Sorting the LB table */
proc sort data=final.lb;
	by STUDYID USUBJID LBSEQ;
run;

/* Creating a table for LBLOBXFL */
proc sql;
	create table inter.lb_lobx as
	select l.USUBJID, l.LBSEQ
	from final.lb as l
	inner join final.dm as m
	on l.USUBJID=m.USUBJID
	where not missing(l.LBSTRESN) and l.LBDTC <= m.RFXSTDTC
	group by l.USUBJID, l.LBTESTCD
	having cats(l.LBDTC, put(l.VISITNUM, z3.)) = max(cats(l.LBDTC, put(l.VISITNUM, z3.)))
	order by l.USUBJID, l.LBSEQ;
quit;

/* Adding LBLOBXFL to the LB table */
data final.lb;
	merge final.lb(in=a) inter.lb_lobx(in=f);
	by USUBJID LBSEQ;
	if a;
	if f then
		LBLOBXFL="Y";
run;

/* Creating the final LB table with the study day */
data final.lb;
	merge final.lb(in=a) final.dm(keep=USUBJID RFSTDTC);
	by USUBJID;
	if a;
	
	/* Study day: no day 0, so add 1 on or after the first dose */
	if not missing(LBDTC) and not missing(RFSTDTC) then
		LBDY=input(LBDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (LBDTC >= RFSTDTC);
	drop RFSTDTC;
run;