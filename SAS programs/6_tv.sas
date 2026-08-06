/* Mapping the TV domain */

/* Making the structure of the TV table and mapping elements */
data final.tv;
	retain STUDYID DOMAIN VISITNUM VISIT ARMCD ARM TVSTRL TVENRL;
	set inter.visit_lookup;
	length TVSTRL TVENRL $100;
	STUDYID="LORNA";
	DOMAIN="TV";
	VISITNUM=VISIT_NUM;
	VISIT=VISIT_TYPE;
	ARMCD="";
	ARM="";

	if VISIT="SCREENING" then
		do;
			TVSTRL="Start of SCREENING Epoch";
			TVENRL="2 hours after the start of the Visit";
		end;

	if VISIT="BASELINE" then
		do;
			TVSTRL="Start of TREATMENT1 Epoch";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="WEEK 4" then
		do;
			TVSTRL="Start of TREATMENT2 Epoch";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="WEEK 8" then
		do;
			TVSTRL="Start of TREATMENT3 Epoch";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="WEEK 12" then
		do;
			TVSTRL="Start of TREATMENT4 Epoch";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="FOLLOW-UP" then
		do;
			TVSTRL="Start of FOLLOW-UP Epoch";
			TVENRL="At Trial Exit";
		end;
	keep STUDYID DOMAIN VISITNUM VISIT ARMCD ARM TVSTRL TVENRL;
run;