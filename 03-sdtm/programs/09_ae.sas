/* Mapping the AE domain */

/* Creating a table with subject and AE data using left joins */
proc sql;
	create table final.ae as
	select s.SUBJECT_NUM, s.REPORTED_EVENT, s.START_DATE, s.END_DATE,
		   m.LLT, m.LLTCD, m.PT, m.PTCD, m.HLT, m.HLTCD, m.HLGT, m.HLGTCD, m.BODYSYS, m.BODYSYSCD, m.SOC, m.SOCCD,
		   l.SEVERITY, l.SERIOUS,
		   re.ARM_CODE,
		   sd.SUBJECT_ID, sd.SITE_ID
	from inter.ae_subjects as s 
	left join inter.ae_meddra as m
	on s.REPORTED_EVENT=m.REPORTED_EVENT
	left join inter.ae_list as l
	on s.AE_CODE=l.AE_CODE
	left join raw.exposure as re
	on s.SUBJECT_NUM=re.SUBJECT_NUM
	left join inter.subject_data as sd
	on s.SUBJECT_NUM=sd.SUBJECT_NUM
	order by sd.SUBJECT_ID, s.START_DATE;
quit;

/* Making the structure of the AE table and mapping elements */
data final.ae;
	retain STUDYID DOMAIN USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEPTCD AEHLT 
		AEHLTCD AEHLGT AEHLGTCD AEBODSYS AEBDSYCD AESOC AESOCCD AESEV AESER AEREL
		AEOUT AESTDTC AEENDTC;
	length AEREL $22 AESTDTC AEENDTC $10;
	set final.ae;
	by SUBJECT_ID;
	STUDYID="LORNA";
	DOMAIN="AE";
	SUBJID=SUBJECT_ID;
	USUBJID=catx("-", STUDYID, SITE_ID, SUBJID);
	AETERM=REPORTED_EVENT;
	AELLT=LLT;
	AELLTCD=LLTCD;
	AEDECOD=PT;
	AEPTCD=PTCD;
	AEHLT=HLT;
	AEHLTCD=HLTCD;
	AEHLGT=HLGT;
	AEHLGTCD=HLGTCD;
	AEBODSYS=BODYSYS;
	AEBDSYCD=BODYSYSCD;
	AESOC=SOC;
	AESOCCD=SOCCD;
	AESEV=SEVERITY;
	AEOUT="RECOVERED/RESOLVED";

	if first.SUBJECT_ID then
		AESEQ=1;
	else
		AESEQ+1;

	if ARM_CODE in ("DRGA", "DRGB") then
		AEREL="POSSIBLY RELATED";
	else if ARM_CODE="PLC" then
		AEREL="UNLIKELY TO BE RELATED";

	if SERIOUS="NO" then
		AESER="N";
	else if SERIOUS="YES" then
		AESER="Y";

	if not missing(START_DATE) then
		AESTDTC=put(START_DATE, yymmdd10.);
	if not missing(END_DATE) then
		AEENDTC=put(END_DATE, yymmdd10.);
	
	keep STUDYID DOMAIN USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEPTCD AEHLT 
		AEHLTCD AEHLGT AEHLGTCD AEBODSYS AEBDSYCD AESOC AESOCCD AESEV AESER AEREL
		AEOUT AESTDTC AEENDTC;
run;

/* Making tables to get EPOCH, TAETORD, AEACN, and the study days */
proc sql;
	create table inter.se_elements as
	select USUBJID, SESTDTC, SEENDTC, EPOCH, TAETORD,
	       (TAETORD = max(TAETORD)) as LASTEL
	from final.se
	group by USUBJID;

	create table inter.lastdose as
	select USUBJID, max(coalescec(EXENDTC, EXSTDTC)) as LASTDOSE length=10
	from final.ex
	group by USUBJID;

	create table inter.ae_almost as
	select a.*, s.EPOCH, s.TAETORD, d.LASTDOSE, m.RFSTDTC
	from final.ae as a
	left join inter.se_elements as s
	on a.USUBJID=s.USUBJID and s.SESTDTC <= a.AESTDTC and (a.AESTDTC < s.SEENDTC or (s.LASTEL=1 and a.AESTDTC=s.SEENDTC))
	left join inter.lastdose as d
	on a.USUBJID=d.USUBJID
	left join final.dm as m
	on a.USUBJID=m.USUBJID;
quit;

/* Final mapping of AE table */
data final.ae;
	retain STUDYID DOMAIN USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEPTCD AEHLT 
		AEHLTCD AEHLGT AEHLGTCD AEBODSYS AEBDSYCD AESOC AESOCCD AESEV AESER AEACN
		AEREL AEOUT TAETORD EPOCH AESTDTC AEENDTC AESTDY AEENDY;
	length AEACN $16;
	set inter.ae_almost;
	
	if not missing(AESTDTC) and AESTDTC >= LASTDOSE then
		AEACN="NOT APPLICABLE";
	else
		AEACN="DOSE NOT CHANGED";
	
	/* Study day: no day 0, so add 1 on or after the first dose */
	if not missing(AESTDTC) and not missing(RFSTDTC) then
		AESTDY=input(AESTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (AESTDTC >= RFSTDTC);
	if not missing(AEENDTC) and not missing(RFSTDTC) then
		AEENDY=input(AEENDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + (AEENDTC >= RFSTDTC);
	
	keep STUDYID DOMAIN USUBJID AESEQ AETERM AELLT AELLTCD AEDECOD AEPTCD AEHLT 
		AEHLTCD AEHLGT AEHLGTCD AEBODSYS AEBDSYCD AESOC AESOCCD AESEV AESER AEACN
		AEREL AEOUT TAETORD EPOCH AESTDTC AEENDTC AESTDY AEENDY;
run;

/* Sorting the final AE table */
proc sort data=final.ae;
	by STUDYID USUBJID AESEQ;
run;