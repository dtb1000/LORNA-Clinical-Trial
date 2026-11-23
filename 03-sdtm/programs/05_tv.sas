/* Mapping the TV domain */

/* Making the structure of the TV table and mapping elements */
data final.tv;
	retain STUDYID DOMAIN VISITNUM VISIT VISITDY ARMCD TVSTRL TVENRL;
	set inter.visit_lookup;
	length TVSTRL $61 TVENRL $39;
	STUDYID="LORNA";
	DOMAIN="TV";
	VISITNUM=VISIT_NUM;
	VISIT=VISIT_TYPE;
	VISITDY=PLANNED_DAY;
	ARMCD="";

	if VISIT="SCREENING" then
		do;
			TVSTRL="Day -14, start of the SCREENING Epoch (informed consent)";
			TVENRL="2 hours after the start of the Visit";
		end;

	if VISIT="BASELINE" then
		do;
			TVSTRL="Day 1, before the first dose of study drug";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="WEEK 4" then
		do;
			TVSTRL="Day 29 (+/- 5 days), second dose of study drug";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="WEEK 8" then
		do;
			TVSTRL="Day 57 (+/- 5 days), third dose of study drug";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="WEEK 12" then
		do;
			TVSTRL="Day 85 (+/- 5 days), fourth dose of study drug";
			TVENRL="30 minutes after the start of the Visit";
		end;

	if VISIT="FOLLOW-UP" then
		do;
			TVSTRL="Day 113 (+/- 5 days), 4 weeks after fourth dose of study drug";
			TVENRL="At Trial Exit";
		end;
	keep STUDYID DOMAIN VISITNUM VISIT VISITDY ARMCD TVSTRL TVENRL;
run;