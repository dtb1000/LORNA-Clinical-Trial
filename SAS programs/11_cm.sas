/* Mapping the CM domain */

/* Creating a table with subject and CM data using inner and left joins */
proc sql;
	create table final.cm as
	select sd.SUBJECT_NUM, sd.SUBJECT_ID, sd.SITE_ID, 
		   cs.MED_CODE,
		   cl.MEDICATION, cl.DOSE, cl.UNIT, cl.FORMULATION, cl.FREQUENCY 
	from inter.subject_data as sd
	inner join inter.conmed_subjects as cs
	on sd.SUBJECT_NUM=cs.SUBJECT_NUM
	left join inter.conmed_list as cl
	on cs.MED_CODE=cl.MED_CODE
	order by sd.SUBJECT_NUM;
quit;

/* Making the structure of the CM table and mapping elements */
data final.cm;
	retain STUDYID DOMAIN USUBJID CMSEQ CMTRT CMDECOD CMCAT CMINDC CMDOSE CMDOSEU 
		CMDOSFRM CMDOSFRQ CMROUTE TAETORD EPOCH;
		length CMINDC $15;
	set final.cm;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="CM";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	CMTRT=MEDICATION;
	CMDECOD=MEDICATION;
	CMCAT="PRIOR";
	CMDOSE=DOSE;
	CMDOSEU=UNIT;
	CMDOSFRM=FORMULATION;
	CMDOSFRQ=FREQUENCY;
	CMROUTE="ORAL";
	TAETORD=.;
	EPOCH="";

	if first.SUBJECT_ID then
		CMSEQ=1;
	else
		CMSEQ+1;

	if CMTRT="LISINOPRIL" then
		CMINDC="STROKE";
	else if CMTRT="LOSARTAN" then
		CMINDC="HYPERTENSION";
	else if CMTRT="SIMVASTATIN" then
		CMINDC="HYPERLIPIDEMIA";
	else if CMTRT="METFORMIN" then
		CMINDC="TYPE 2 DIABETES";
	keep STUDYID DOMAIN USUBJID CMSEQ CMTRT CMDECOD CMCAT CMINDC CMDOSE CMDOSEU 
		CMDOSFRM CMDOSFRQ CMROUTE TAETORD EPOCH;
run;