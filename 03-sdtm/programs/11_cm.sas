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
	retain STUDYID DOMAIN USUBJID CMSEQ CMTRT CMINDC CMCLAS CMCLASCD CMDOSE 
		CMDOSU CMDOSFRM CMDOSFRQ CMROUTE CMENRTPT CMENTPT;
	length CMINDC $15 CMCLAS $46;
	set final.cm;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="CM";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	CMTRT=MEDICATION;
	CMDOSE=DOSE;
	CMDOSU=UNIT;
	CMDOSFRM=FORMULATION;
	CMDOSFRQ=FREQUENCY;
	CMROUTE="ORAL";
	CMENRTPT="ONGOING";
	CMENTPT="END OF STUDY";

	if first.SUBJECT_ID then
		CMSEQ=1;
	else
		CMSEQ+1;

	if CMTRT="LISINOPRIL" then
		do;
			CMINDC="HYPERTENSION";
			CMCLAS="ACE INHIBITORS, PLAIN";
			CMCLASCD="C09AA";
		end;
	else if CMTRT="LOSARTAN" then
		do;
			CMINDC="STROKE";
			CMCLAS="ANGIOTENSIN II RECEPTOR BLOCKERS (ARBS), PLAIN";
			CMCLASCD="C09CA";
		end;
	else if CMTRT="SIMVASTATIN" then
		do;
			CMINDC="HYPERLIPIDEMIA";
			CMCLAS="HMG COA REDUCTASE INHIBITORS";
			CMCLASCD="C10AA";
		end;
	else if CMTRT="METFORMIN" then
		do;
			CMINDC="TYPE 2 DIABETES";
			CMCLAS="BIGUANIDES";
			CMCLASCD="A10BA";
		end;
	keep STUDYID DOMAIN USUBJID CMSEQ CMTRT CMINDC CMCLAS CMCLASCD CMDOSE 
		CMDOSU CMDOSFRM CMDOSFRQ CMROUTE CMENRTPT CMENTPT;
run;

/* Sorting the final CM table */
proc sort data=final.cm;
	by STUDYID USUBJID CMSEQ;
run;