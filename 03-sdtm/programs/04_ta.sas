/* Mapping the TA domain */

/* Creating a trial design matrix for each treatment */
data inter.tdm;
	retain ARM_CODE TREATMENT_ARM SCREENING TREATMENT1 TREATMENT2 TREATMENT3 
		TREATMENT4 FOLLOWUP;
	length TREATMENT1 TREATMENT2 TREATMENT3 TREATMENT4 $13;
	set inter.arms;

	if ARM_CODE="DRGA" then
		do;
			SCREENING="SCREENING";
			TREATMENT1="DRUG A 200 MG";
			TREATMENT2="DRUG A 200 MG";
			TREATMENT3="DRUG A 200 MG";
			TREATMENT4="DRUG A 200 MG";
			FOLLOWUP="FOLLOW-UP";
		end;

	if ARM_CODE="DRGB" then
		do;
			SCREENING="SCREENING";
			TREATMENT1="DRUG B 300 MG";
			TREATMENT2="DRUG B 300 MG";
			TREATMENT3="DRUG B 300 MG";
			TREATMENT4="DRUG B 300 MG";
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
	length TABRANCH $24 EPOCH $10 TATRANS $51;
	set inter.elements;
	STUDYID="LORNA";
	DOMAIN="TA";
	ARMCD=ARM_CODE;
	ARM=upcase(TREATMENT_ARM);
	TAETORD=SEQ;
	ELEMENT=ELEMENT;
	
	if ARMCD="DRGA" and ETCD="TRT" then
		ETCD="TRTA";
	if ARMCD="DRGB" and ETCD="TRT" then
		ETCD="TRTB";

	if ELEMENT="SCREENING" then
		EPOCH="SCREENING";

	if (ELEMENT="DRUG A 200 MG" or ELEMENT="DRUG B 300 MG" or ELEMENT="PLACEBO") 
		and TAETORD=2 then
			EPOCH="TREATMENT";
	if (ELEMENT="DRUG A 200 MG" or ELEMENT="DRUG B 300 MG" or ELEMENT="PLACEBO")
		and TAETORD=3 then
			EPOCH="TREATMENT";
	if (ELEMENT="DRUG A 200 MG" or ELEMENT="DRUG B 300 MG" or ELEMENT="PLACEBO")
		and TAETORD=4 then
			EPOCH="TREATMENT";
	if (ELEMENT="DRUG A 200 MG" or ELEMENT="DRUG B 300 MG" or ELEMENT="PLACEBO")
		and TAETORD=5 then
			EPOCH="TREATMENT";

	if ELEMENT="FOLLOW-UP" then
		EPOCH="FOLLOW-UP";
	
	if ARMCD="DRGA" and EPOCH="SCREENING" then
		TABRANCH="Randomization to Drug A";
	else if ARMCD="DRGB" and EPOCH="SCREENING" then
		TABRANCH="Randomization to Drug B";
	else if ARMCD="PLC" and EPOCH="SCREENING" then
		TABRANCH="Randomization to Placebo";
	else if EPOCH ne "SCREENING" then
		TABRANCH="";
		
	if TAETORD=1 or TAETORD=5 or TAETORD=6 then
		TATRANS="";
	if TAETORD=2 or TAETORD=3 or TAETORD=4 then
		TATRANS="If study drug is stopped, go to the FOLLOW-UP epoch";
	
	keep STUDYID DOMAIN ARMCD ARM TAETORD ETCD ELEMENT TABRANCH TATRANS EPOCH;
run;