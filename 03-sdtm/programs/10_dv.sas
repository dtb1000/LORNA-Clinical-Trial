/* Mapping the DV domain */

/* Creating a table with subject and DV data using left joins */
proc sql;
	create table final.dv as
	select d.SUBJECT_NUM, d.ERROR, d.VISIT_TYPE, d.VISIT_DATE,
		   sd.SUBJECT_ID, sd.SITE_ID
	from inter.deviations as d
	left join inter.subject_data as sd
	on d.SUBJECT_NUM=sd.SUBJECT_NUM
	order by sd.SUBJECT_ID, d.VISIT_DATE;
quit;

/* Making the structure of the DV table and mapping elements */
data final.dv;
	retain STUDYID DOMAIN USUBJID DVSEQ DVTERM DVCAT DVSCAT DVSTDTC;
	length DVSTDTC $10 DVSCAT DVTERM $25;
	set final.dv;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="DV";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	DVCAT=ERROR;
	
	if not missing(VISIT_DATE) then
		DVSTDTC=put(VISIT_DATE, yymmdd10.);
	
	if first.SUBJECT_ID then
		DVSEQ=1;
	else
		DVSEQ+1;
	
	if VISIT_TYPE="SCREENING" then
		DVTERM="MISSED SCREENING VISIT";

	if VISIT_TYPE="BASELINE" then
		DVTERM="MISSED BASELINE VISIT";

	if VISIT_TYPE="WEEK 4" then
		DVTERM="MISSED WEEK 4 VISIT";

	if VISIT_TYPE="WEEK 8" then
		DVTERM="MISSED WEEK 8 VISIT";

	if VISIT_TYPE="WEEK 12" then
		DVTERM="MISSED WEEK 12 VISIT";

	if VISIT_TYPE="FOLLOW-UP" then
		DVTERM="MISSED FOLLOW-UP VISIT";
	
	if VISIT_TYPE in ("BASELINE", "WEEK 12") then
		DVSCAT="IMPORTANT";
	else
		DVSCAT="NOT IMPORTANT";
	
	keep STUDYID DOMAIN USUBJID DVSEQ DVTERM DVCAT DVSCAT DVSTDTC;
run;

/* Making tables to get EPOCH, TAETORD, and DVSTDY */
proc sql;
	create table inter.dv_almost as
	select d.*, s.EPOCH, s.TAETORD,
	       case when not missing(d.DVSTDTC) and not missing(m.RFSTDTC) then input(d.DVSTDTC, yymmdd10.) - input(m.RFSTDTC, yymmdd10.)
	                 + (d.DVSTDTC >= m.RFSTDTC)
	       end as DVSTDY
	from final.dv as d
	left join inter.se_elements as s
	on d.USUBJID=s.USUBJID
	and s.SESTDTC <= d.DVSTDTC
	and (d.DVSTDTC < s.SEENDTC or (s.LASTEL=1 and d.DVSTDTC=s.SEENDTC))
	left join final.dm as m
	on d.USUBJID=m.USUBJID;
quit;

/* Final mapping of DV table */
data final.dv;
	retain STUDYID DOMAIN USUBJID DVSEQ DVTERM DVCAT DVSCAT
		TAETORD EPOCH DVSTDTC DVSTDY;
	set inter.dv_almost;
	keep STUDYID DOMAIN USUBJID DVSEQ DVTERM DVCAT DVSCAT
		TAETORD EPOCH DVSTDTC DVSTDY;
run;

/* Sorting the final DV table */
proc sort data=final.dv;
	by STUDYID USUBJID DVSEQ;
run;