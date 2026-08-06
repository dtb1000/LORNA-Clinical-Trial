/* Mapping the TA domain */

/* Creating a trial design matrix for each treatment */
data inter.tdm;
	retain ARM_CODE TREATMENT_ARM SCREENING TREATMENT1 TREATMENT2 TREATMENT3 
		TREATMENT4 FOLLOWUP;
	length TREATMENT1 TREATMENT2 TREATMENT3 TREATMENT4 $7;
	set inter.arms;

	if ARM_CODE="DRGA" then
		do;
			SCREENING="SCREENING";
			TREATMENT1="200 mg";
			TREATMENT2="200 mg";
			TREATMENT3="200 mg";
			TREATMENT4="200 mg";
			FOLLOWUP="FOLLOW-UP";
		end;

	if ARM_CODE="DRGB" then
		do;
			SCREENING="SCREENING";
			TREATMENT1="300 mg";
			TREATMENT2="300 mg";
			TREATMENT3="300 mg";
			TREATMENT4="300 mg";
			FOLLOWUP="FOLLOW-UP";
		end;

	if ARM_CODE="PLC" then
		do;
			SCREENING="SCREENING";
			TREATMENT1="PLACEBO";
			TREATMENT2="PLACEBO";
			TREATMENT3="PLACEBO";
			TREATMENT4="PLACEBO";
			FOLLOWUP="FOLLOW-UP";
		end;
	keep ARM_CODE TREATMENT_ARM SCREENING TREATMENT1 TREATMENT2 TREATMENT3 
		TREATMENT4 FOLLOWUP;
run;

/* Transforming the trial design matrix to show elements with corresponding sequence number */
data inter.elements;
	set inter.tdm;
	array visit{6} SCREENING TREATMENT1 TREATMENT2 TREATMENT3 TREATMENT4 FOLLOWUP;

	do SEQ=1 to dim(visit);
		ELEMENT=visit[SEQ];

		select (SEQ);
			when (1) ETCD="SCRN";
			when (2) ETCD="TRT";
			when (3) ETCD="TRT";
			when (4) ETCD="TRT";
			when (5) ETCD="TRT";
			when (6) ETCD="FU";
		end;

		if ARM_CODE="PLC" and ELEMENT="PLACEBO" then
			ETCD="PLC";
		output;
	end;
	keep ARM_CODE TREATMENT_ARM SEQ ETCD ELEMENT;
run;

/* Making the structure of the TA table and mapping elements */
data final.ta;
	retain STUDYID DOMAIN ARMCD ARM TAETORD ETCD ELEMENT TABRANCH TATRANS EPOCH;
	length TABRANCH $24 EPOCH $10;
	set inter.elements;
	STUDYID="LORNA";
	DOMAIN="TA";
	ARMCD=ARM_CODE;
	ARM=TREATMENT_ARM;
	TAETORD=SEQ;
	ETCD=ETCD;
	ELEMENT=ELEMENT;
	TATRANS="";

	if ELEMENT="SCREENING" then
		EPOCH="SCREENING";

	if (ELEMENT="200 mg" or ELEMENT="300 mg" or ELEMENT="PLACEBO") and TAETORD=2 
		then
			EPOCH="TREATMENT1";
	else if (ELEMENT="200 mg" or ELEMENT="300 mg" or ELEMENT="PLACEBO") and 
		TAETORD=3 then
			EPOCH="TREATMENT2";
	else if (ELEMENT="200 mg" or ELEMENT="300 mg" or ELEMENT="PLACEBO") and 
		TAETORD=4 then
			EPOCH="TREATMENT3";
	else if (ELEMENT="200 mg" or ELEMENT="300 mg" or ELEMENT="PLACEBO") and 
		TAETORD=5 then
			EPOCH="TREATMENT4";

	if ELEMENT="FOLLOW-UP" then
		EPOCH="FOLLOW-UP";

	if ARMCD="DRGA" and EPOCH="SCREENING" then
		TABRANCH="Randomization to Drug A";

	if ARMCD="DRGB" and EPOCH="SCREENING" then
		TABRANCH="Randomization to Drug B";

	if ARMCD="PLC" and EPOCH="SCREENING" then
		TABRANCH="Randomization to Placebo";

	if EPOCH ne "SCREENING" then
		TABRANCH="";
	keep STUDYID DOMAIN ARMCD ARM TAETORD ETCD ELEMENT TABRANCH TATRANS EPOCH;
run;