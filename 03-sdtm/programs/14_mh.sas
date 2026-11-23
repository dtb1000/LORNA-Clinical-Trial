/* Mapping the MH domain */

/* Creating a table with subject and MH data using inner and left joins */
proc sql;
	create table final.mh as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID, 
		   m.MEDICAL_BG 
	from inter.subject_data as sd
	inner join raw.medical_history as m
	on sd.SUBJECT_NUM=m.SUBJECT_NUM
	order by sd.SUBJECT_NUM;
quit;

/* Making the structure of the MH table and mapping elements */
data final.mh;
	retain STUDYID DOMAIN USUBJID MHSEQ MHTERM MHDECOD MHBODSYS MHENRTPT MHENTPT;
	length MHTERM $15 MHDECOD $24 MHBODSYS $34;
	set final.mh;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="MH";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	MHTERM=upcase(MEDICAL_BG);
	MHENTPT="SCREENING";

	if first.SUBJECT_ID then
		MHSEQ=1;
	else
		MHSEQ+1;

	if MHTERM="HYPERTENSION" then
		do;
			MHDECOD="Hypertension";
			MHBODSYS="Vascular disorders";
			MHENRTPT="ONGOING";
		end;
	
	if MHTERM="TYPE 2 DIABETES" then
		do;
			MHDECOD="Type 2 diabetes mellitus";
			MHBODSYS="Metabolism and nutrition disorders";
			MHENRTPT="ONGOING";
		end;
	
	if MHTERM="HYPERLIPIDEMIA" then
		do;
			MHDECOD="Hyperlipidaemia";
			MHBODSYS="Metabolism and nutrition disorders";
			MHENRTPT="ONGOING";
		end;
	
	if MHTERM="STROKE" then
		do;
			MHDECOD="Cerebrovascular accident";
			MHBODSYS="Nervous system disorders";
			MHENRTPT="BEFORE";
		end;
	
	keep STUDYID DOMAIN USUBJID MHSEQ MHTERM MHDECOD MHBODSYS MHENRTPT MHENTPT;
run;

/* Sorting the final MH table */
proc sort data=final.mh;
	by STUDYID USUBJID MHSEQ;
run;