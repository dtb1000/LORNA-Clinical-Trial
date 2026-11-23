/* Mapping the DS domain */

/* Making a table with DS events */
proc sql;
    create table inter.ds_events (
    ORDER num(1),
    EVENT varchar(25)
    );
    insert into inter.ds_events
    values(1, "INFORMED CONSENT OBTAINED")
    values(2, "RANDOMIZED")
    values(3, "COMPLETED");
quit;

/* Creating a table with dates of DS events */
proc sql;
	create table inter.ds_dates as
	select SUBJID, RFICDTC as IC, RFSTDTC as RAND, RFPENDTC as COMP
	from final.dm
	order by USUBJID;
quit;

/* Creating a CROSS JOIN table of DS events for all subjects */
proc sql;
	create table inter.ds_almost as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID, 
		   dsd.IC, dsd.RAND, dsd.COMP,
		   dse.ORDER, dse.EVENT
	from inter.subject_data as sd
	inner join inter.ds_dates as dsd
	on sd.SUBJECT_ID=dsd.SUBJID
	cross join inter.ds_events as dse
	order by sd.SUBJECT_NUM, dse.ORDER;
quit;

/* Making the structure of the DS table and mapping elements */
data inter.ds_almost;
	retain STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT DSSTDTC;
	set inter.ds_almost;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="DS";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	DSTERM=EVENT;
	DSDECOD=EVENT;

	if first.SUBJECT_ID then
		DSSEQ=1;
	else
		DSSEQ+1;

	if DSTERM="INFORMED CONSENT OBTAINED" then
		do;
			DSSTDTC=IC;
			DSCAT="PROTOCOL MILESTONE";
		end;
	else if DSTERM="RANDOMIZED" then
		do;
			DSSTDTC=RAND;
			DSCAT="PROTOCOL MILESTONE";
		end;
	else if DSTERM="COMPLETED" then
		do;
			DSSTDTC=COMP;
			DSCAT="DISPOSITION EVENT";
		end;
	
	keep STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT DSSTDTC;
run;

/* Adding EPOCH and TAETORD */
proc sql;
	create table final.ds as
	select d.*, s.EPOCH, s.TAETORD
	from inter.ds_almost as d
	left join inter.se_elements as s
	on d.USUBJID=s.USUBJID and s.SESTDTC <= d.DSSTDTC and (d.DSSTDTC < s.SEENDTC or (s.LASTEL=1 and d.DSSTDTC=s.SEENDTC))
	order by d.USUBJID, d.DSSEQ;
quit;

/* Fixing RANDOMIZED EPOCH and TAETORD and adding DSSTDY */
data final.ds;
	retain STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT TAETORD EPOCH
		DSSTDTC DSSTDY;
	
	merge final.ds(in=a) final.dm(keep=USUBJID RFSTDTC);
	by USUBJID;
	if a;
	if DSDECOD = "RANDOMIZED" then do;
		TAETORD = 1;
		EPOCH = "SCREENING";
	end;
	DSSTDY=input(DSSTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (DSSTDTC >= RFSTDTC);
	drop RFSTDTC;
	
	keep STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT TAETORD EPOCH
		DSSTDTC DSSTDY;
run;

/* Sorting the final DS table */
proc sort data=final.ds;
	by STUDYID USUBJID DSSEQ;
run;