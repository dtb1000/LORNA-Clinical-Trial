/* Mapping the TE domain */

/* Creating a list of trial elements */
proc sql;
	create table inter.elements_distinct as
	select
		case when 
			upcase(ELEMENT)="SCREENING" then 1
			when upcase(ELEMENT)="200 MG" then 2
			when upcase(ELEMENT)="300 MG" then 3
			when upcase(ELEMENT)="PLACEBO" then 4
			when upcase(ELEMENT)="FOLLOW-UP" then 5 end as ORDER,
		ELEMENT
	from
		(select distinct ELEMENT
		from inter.elements)
	order by ORDER;
quit;

/* Making the structure of the TE table and mapping elements */
data final.te;
	retain STUDYID DOMAIN ETCD ELEMENT TESTRL TEENRL TEDUR;
	set inter.elements_distinct;
	length TESTRL TEENRL $100;
	STUDYID="LORNA";
	DOMAIN="TE";
	ELEMENT=ELEMENT;

	if ELEMENT="SCREENING" then
		do;
			ETCD="SCRN";
			TESTRL="Informed consent";
			TEENRL="2 weeks after the start of the Element";
			TEDUR="P14";
		end;

	if ELEMENT="200 mg" then
		do;
			ETCD="TRT";
			TESTRL="First dose of a treatment Epoch, where the dose is 200 mg";
			TEENRL="4 weeks after the start of the Element";
			TEDUR="P28D";
		end;

	if ELEMENT="300 mg" then
		do;
			ETCD="TRT";
			TESTRL="First dose of a treatment Epoch, where the dose is 300 mg";
			TEENRL="4 weeks after the start of the Element";
			TEDUR="P28D";
		end;

	if ELEMENT="PLACEBO" then
		do;
			ETCD="PLC";
			TESTRL="First dose of a treatment Epoch, where the dose is a placebo";
			TEENRL="4 weeks after the start of the Element";
			TEDUR="P28D";
		end;

	if ELEMENT="FOLLOW-UP" then
		do;
			ETCD="FU";
			TESTRL="4 weeks after the last dose of the preceding treatment Epoch";
			TEENRL="At Trial Exit";
			TEDUR="P1D";
		end;
	keep STUDYID DOMAIN ETCD ELEMENT TESTRL TEENRL TEDUR;
run;