/* Mapping the SE domain */

/* Creating a table with subject, visit, and element data using left joins */
proc sql;
	create table final.se as
	select distinct sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID,
					x.ARM_CODE,
					v.VISIT_NUM, v.VISIT_TYPE, v.VISIT_DATE,
					e.ETCD, e.ELEMENT
	from inter.subject_data as sd
	left join inter.exposure as x
	on sd.SUBJECT_NUM=x.SUBJECT_NUM
	left join inter.visit as v
	on sd.SUBJECT_NUM=v.SUBJECT_NUM
	left join inter.elements as e
	on x.ARM_CODE=e.ARM_CODE and v.VISIT_NUM=e.SEQ;
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
	ETCD=ETCD;
	ELEMENT=ELEMENT;

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
			EPOCH="TREATMENT1";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="WEEK 4" then
		do;
			TAETORD=3;
			EPOCH="TREATMENT2";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="WEEK 8" then
		do;
			TAETORD=4;
			EPOCH="TREATMENT3";
			SESTDTC=put(VISIT_DATE, yymmdd10.);
			SEENDTC=put(VISIT_DATE+28, yymmdd10.);
		end;

	if VISIT_TYPE="WEEK 12" then
		do;
			TAETORD=5;
			EPOCH="TREATMENT4";
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
	keep STUDYID DOMAIN USUBJID SESEQ ETCD ELEMENT TAETORD EPOCH SESTDTC SEENDTC;
run;