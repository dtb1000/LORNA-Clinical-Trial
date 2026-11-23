/* Exporting the final SDTM domains as CSV and SAS transport version 5 (XPT) files */
/* Run after every mapping program, including 16_ts.sas */

/* Output folders */
%let csvpath=/home/u64484701/CT/CSV;
%let xptpath=/home/u64484701/CT/XPT;

/* Dataset labels (SDTMIG v3.4) */
data work.ds_labels;
	length memname $8 dslabel $40;
	infile datalines dlm='|' truncover;
	input memname $ dslabel $;
	datalines;
AE|Adverse Events
CM|Concomitant/Prior Medications
DM|Demographics
DS|Disposition
DV|Protocol Deviations
EX|Exposure
LB|Laboratory Test Results
MH|Medical History
SE|Subject Elements
TA|Trial Arms
TE|Trial Elements
TS|Trial Summary
TV|Trial Visits
VS|Vital Signs
;
run;

/* Variable labels (SDTMIG v3.4); a variable has the same label in every domain */
data work.var_labels;
	length name $8 label $40;
	infile datalines dlm='|' truncover;
	input name $ label $;
	datalines;
STUDYID|Study Identifier
DOMAIN|Domain Abbreviation
USUBJID|Unique Subject Identifier
SUBJID|Subject Identifier for the Study
SITEID|Study Site Identifier
VISITNUM|Visit Number
VISIT|Visit Name
VISITDY|Planned Study Day of Visit
TAETORD|Planned Order of Element within Arm
EPOCH|Epoch
ARMCD|Planned Arm Code
ARM|Description of Planned Arm
ETCD|Element Code
ELEMENT|Description of Element
RFSTDTC|Subject Reference Start Date/Time
RFENDTC|Subject Reference End Date/Time
RFXSTDTC|Date/Time of First Study Treatment
RFXENDTC|Date/Time of Last Study Treatment
RFICDTC|Date/Time of Informed Consent
RFPENDTC|Date/Time of End of Participation
DTHDTC|Date/Time of Death
DTHFL|Subject Death Flag
AGE|Age
AGEU|Age Units
SEX|Sex
RACE|Race
ETHNIC|Ethnicity
ACTARMCD|Actual Arm Code
ACTARM|Description of Actual Arm
ARMNRS|Reason Arm and/or Actual Arm is Null
ACTARMUD|Description of Unplanned Actual Arm
COUNTRY|Country
DMDTC|Date/Time of Collection
DMDY|Study Day of Collection
AESEQ|Sequence Number
AETERM|Reported Term for the Adverse Event
AELLT|Lowest Level Term
AELLTCD|Lowest Level Term Code
AEDECOD|Dictionary-Derived Term
AEPTCD|Preferred Term Code
AEHLT|High Level Term
AEHLTCD|High Level Term Code
AEHLGT|High Level Group Term
AEHLGTCD|High Level Group Term Code
AEBODSYS|Body System or Organ Class
AEBDSYCD|Body System or Organ Class Code
AESOC|Primary System Organ Class
AESOCCD|Primary System Organ Class Code
AESEV|Severity/Intensity
AESER|Serious Event
AEACN|Action Taken with Study Treatment
AEREL|Causality
AEOUT|Outcome of Adverse Event
AESTDTC|Start Date/Time of Adverse Event
AEENDTC|End Date/Time of Adverse Event
AESTDY|Study Day of Start of Adverse Event
AEENDY|Study Day of End of Adverse Event
CMSEQ|Sequence Number
CMTRT|Reported Name of Drug, Med, or Therapy
CMINDC|Indication
CMCLAS|Medication Class
CMCLASCD|Medication Class Code
CMDOSE|Dose per Administration
CMDOSU|Dose Units
CMDOSFRM|Dose Form
CMDOSFRQ|Dosing Frequency per Interval
CMROUTE|Route of Administration
CMENRTPT|End Relative to Reference Time Point
CMENTPT|End Reference Time Point
DSSEQ|Sequence Number
DSTERM|Reported Term for the Disposition Event
DSDECOD|Standardized Disposition Term
DSCAT|Category for Disposition Event
DSSTDTC|Start Date/Time of Disposition Event
DSSTDY|Study Day of Start of Disposition Event
DVSEQ|Sequence Number
DVTERM|Protocol Deviation Term
DVCAT|Category for Protocol Deviation
DVSCAT|Subcategory for Protocol Deviation
DVSTDTC|Start Date/Time of Deviation
DVSTDY|Study Day of Start of Deviation
EXSEQ|Sequence Number
EXTRT|Name of Treatment
EXDOSE|Dose
EXDOSU|Dose Units
EXDOSFRM|Dose Form
EXDOSFRQ|Dosing Frequency per Interval
EXDOSRGM|Intended Dose Regimen
EXROUTE|Route of Administration
EXSTDTC|Start Date/Time of Treatment
EXENDTC|End Date/Time of Treatment
EXSTDY|Study Day of Start of Treatment
EXENDY|Study Day of End of Treatment
LBSEQ|Sequence Number
LBTESTCD|Lab Test or Examination Short Name.
LBTEST|Lab Test or Examination Name
LBCAT|Category for Lab Test
LBORRES|Result or Finding in Original Units
LBORRESU|Original Units
LBORNRLO|Reference Range Lower Limit in Orig Unit
LBORNRHI|Reference Range Upper Limit in Orig Unit
LBSTRESC|Character Result/Finding in Std Format
LBSTRESN|Numeric Result/Finding in Standard Units
LBSTRESU|Standard Units
LBSTNRLO|Reference Range Lower Limit-Std Units
LBSTNRHI|Reference Range Upper Limit-Std Units
LBNRIND|Reference Range Indicator
LBSTAT|Completion Status
LBLOBXFL|Last Observation Before Exposure Flag
LBDTC|Date/Time of Specimen Collection
LBDY|Study Day of Specimen Collection
MHSEQ|Sequence Number
MHTERM|Reported Term for the Medical History
MHDECOD|Dictionary-Derived Term
MHBODSYS|Body System or Organ Class
MHENRTPT|End Relative to Reference Time Point
MHENTPT|End Reference Time Point
SESEQ|Sequence Number
SESTDTC|Start Date/Time of Element
SEENDTC|End Date/Time of Element
SESTDY|Study Day of Start of Element
SEENDY|Study Day of End of Element
TABRANCH|Branch
TATRANS|Transition Rule
TESTRL|Rule for Start of Element
TEENRL|Rule for End of Element
TEDUR|Planned Duration of Element
TVSTRL|Visit Start Rule
TVENRL|Visit End Rule
TSSEQ|Sequence Number
TSPARMCD|Trial Summary Parameter Short Name
TSPARM|Trial Summary Parameter
TSVAL|Parameter Value
TSVALNF|Parameter Value Null Flavor
TSVALCD|Parameter Value Code
TSVCDREF|Name of the Reference Terminology
TSVCDVER|Version of the Reference Terminology
VSSEQ|Sequence Number
VSTESTCD|Vital Signs Test Short Name
VSTEST|Vital Signs Test Name
VSORRES|Result or Finding in Original Units
VSORRESU|Original Units
VSSTRESC|Character Result/Finding in Std Format
VSSTRESN|Numeric Result/Finding in Standard Units
VSSTRESU|Standard Units
VSSTAT|Completion Status
VSLOBXFL|Last Observation Before Exposure Flag
VSDTC|Date/Time of Measurements
VSDY|Study Day of Vital Signs
;
run;

/* Resizing every character variable to its longest value. FDA expects character lengths to
   match the data, so that the XPT files are no larger than they need to be. */
%macro resize_all;
	%local i j ds vars var maxlen;

	proc sql noprint;
		select memname into :rs_list separated by ' '
		from dictionary.tables
		where libname='FINAL' and memtype='DATA'
		order by memname;
	quit;

	%do i=1 %to %sysfunc(countw(&rs_list));
		%let ds=%scan(&rs_list, &i);
		%let vars=;

		proc sql noprint;
			select name into :vars separated by ' '
			from dictionary.columns
			where libname='FINAL' and memname="&ds" and type='char'
			order by varnum;
		quit;

		%do j=1 %to %sysfunc(countw(&vars));
			%let var=%scan(&vars, &j);

			/* LENGTH() returns 1 for a blank value, so a variable with no data keeps length 1 */
			proc sql noprint;
				select max(length(&var)) into :maxlen trimmed
				from final.&ds;
				alter table final.&ds
				modify &var char(&maxlen);
			quit;
		%end;

		/* Removing formats and informats left over from the import; SDTM values need none */
		proc datasets lib=final nolist;
			modify &ds;
			format _all_;
			informat _all_;
		quit;
	%end;
%mend resize_all;

%resize_all;

/* Matching every variable in FINAL to its label */
proc sql;
	create table work.apply_labels as
	select c.memname, c.name, l.label, d.dslabel
	from dictionary.columns as c
	left join work.var_labels as l
	on upcase(c.name)=l.name
	left join work.ds_labels as d
	on c.memname=d.memname
	where c.libname='FINAL' and c.memtype='DATA'
	order by c.memname, c.varnum;
quit;

/* Applying the dataset and variable labels */
data _null_;
	set work.apply_labels;
	by memname;

	if missing(label) then
		put "WARNING: No label defined for " memname +(-1) "." name;

	if first.memname then
		call execute(catx(' ', 'proc datasets lib=final nolist; modify', memname,
			cats('(label="', dslabel, '");'), 'label'));

	if not missing(label) then
		call execute(cats(name, '="', label, '"'));

	if last.memname then
		call execute('; run; quit;');
run;

/* Checking the version 5 transport limits before export */
proc sql noprint;
	select count(*) into :v5_issues trimmed
	from dictionary.columns
	where libname='FINAL' and memtype='DATA'
		and (length(name)>8 or length(label)>40 or (type='char' and length>200));
	select count(*) into :ds_issues trimmed
	from dictionary.tables
	where libname='FINAL' and memtype='DATA'
		and (length(memname)>8 or length(memlabel)>40 or missing(memlabel));
quit;

%put NOTE: Variables breaking version 5 limits: &v5_issues;
%put NOTE: Datasets breaking version 5 limits or without a label: &ds_issues;

/* Retrieving all mapped domains */
proc sql noprint;
	select memname
	into :datasets separated by ' '
	from dictionary.tables
	where libname='FINAL' and memtype='DATA'
	order by memname;
quit;

/* Using the %loc2xpt macro to export each domain as a version 5 XPT file */
%macro export_all_xpt;
	%local i ds dsfile;

	%if &v5_issues>0 or &ds_issues>0 %then %do;
		%put ERROR: Fix the version 5 issues counted above before exporting XPT files.;
		%return;
	%end;

	%do i=1 %to %sysfunc(countw(&datasets));
		%let ds=%scan(&datasets, &i);
		%let dsfile=%sysfunc(lowcase(&ds));
		filename outfile "&xptpath./&dsfile..xpt";
		%put NOTE: Exporting &ds...;
		%loc2xpt(libref=final, memlist=&ds, filespec=outfile, format=V5);
		filename outfile clear;
	%end;
%mend;

/* Using a custom macro to export each domain as a CSV file */
%macro export_csv(lib=, path=);
	%local i n table table_list;

	proc sql noprint;
		select memname
		into :table_list separated by ' '
		from dictionary.tables
		where libname="%upcase(&lib)" and memtype='DATA'
		order by memname;
	quit;

	%let n=%sysfunc(countw(&table_list));

	%do i=1 %to &n;
		%let table=%scan(&table_list, &i);

		proc export data=&lib..&table
			outfile="&path./%sysfunc(lowcase(&table)).csv"
			dbms=csv
			replace;
		run;
	%end;
%mend;

%export_all_xpt;

%export_csv(lib=FINAL, path=&csvpath);