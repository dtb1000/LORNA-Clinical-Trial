/* Mapping the TE domain */

/* Making the structure of the TE table and mapping elements */
data final.te;
	retain STUDYID DOMAIN ETCD ELEMENT TESTRL TEENRL TEDUR;
	set inter.elements;
	length TESTRL TEENRL $100;
	STUDYID="LORNA";
	DOMAIN="TE";
	ELEMENT=ELEMENT;

	if ELEMENT="SCREENING" then
		do;
			ETCD="SCRN";
			TESTRL="Informed consent";
			TEENRL="2 weeks after the start of the Element";
			TEDUR="P14D";
		end;

	if ELEMENT="DRUG A 200 MG" then
		do;
			ETCD="TRTA";
			TESTRL="Dose of study drug, where study drug is Drug A 200 mg";
			TEENRL="4 weeks after the start of the Element";
			TEDUR="P28D";
		end;

	if ELEMENT="DRUG B 300 MG" then
		do;
			ETCD="TRTB";
			TESTRL="Dose of study drug, where study drug is Drug B 300 mg";
			TEENRL="4 weeks after the start of the Element";
			TEDUR="P28D";
		end;

	if ELEMENT="PLACEBO" then
		do;
			ETCD="PLC";
			TESTRL="Dose of study drug, where study drug is placebo";
			TEENRL="4 weeks after the start of the Element";
			TEDUR="P28D";
		end;

	if ELEMENT="FOLLOW-UP" then
		do;
			ETCD="FU";
			TESTRL="4 weeks after the last dose of the preceding treatment Epoch";
			TEENRL="At Trial Exit";
			TEDUR="";
		end;
	keep STUDYID DOMAIN ETCD ELEMENT TESTRL TEENRL TEDUR;
run;