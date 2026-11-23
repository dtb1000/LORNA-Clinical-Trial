/* Mapping the TS domain */

/* Trial Summary: one record per trial summary parameter value. Values come from the protocol (v1.1)
   and the trial design; the study dates and the number of subjects come from DM. */

/* Controlled terminology version used for coded values */
%let ctver=2025-09-26;

/* Taking the study start and end dates and the number of subjects from DM */
proc sql noprint;
	select min(RFICDTC), max(RFPENDTC), count(distinct USUBJID)
	into :sstdtc trimmed, :sendtc trimmed, :actsub trimmed
	from final.dm;
quit;

%put NOTE: SSTDTC=&sstdtc SENDTC=&sendtc ACTSUB=&actsub;

/* Macro writing one TS record: wrap any value that contains a comma in %str() */
%macro tsrec(parmcd, seq, parm, val, nf=, code=, ref=, ver=);
	TSPARMCD="&parmcd";
	TSSEQ=&seq;
	TSPARM="&parm";
	TSVAL="&val";
	TSVALNF="&nf";
	TSVALCD="&code";
	TSVCDREF="&ref";
	TSVCDVER="&ver";
	output;
%mend tsrec;

/* Making the TS records */
data inter.ts;
	length TSPARMCD $8 TSPARM $40 TSVAL $200 TSVALNF $3 TSVALCD $20 TSVCDREF $20
		TSVCDVER $10;

	/* Trial identification */
	%tsrec(TITLE, 1, Trial Title, Long-term Outcomes and Response Assessment of a Novel Agent (LORNA) Trial)
	%tsrec(SPONSOR, 1, Clinical Study Sponsor, PR Life Sciences)
	%tsrec(REGID, 1, Registry Identifier, NCT00001240, code=NCT00001240, ref=ClinicalTrials.gov)
	%tsrec(THERAREA, 1, Therapeutic Area, HEPATOLOGY)
	%tsrec(SDTMVER, 1, SDTM Version, 2.0)
	%tsrec(SDTIGVER, 1, SDTM IG Version, 3.4)

	/* Design */
	%tsrec(STYPE, 1, Study Type, INTERVENTIONAL, code=C98388, ref=CDISC CT, ver=&ctver)
	%tsrec(TPHASE, 1, Trial Phase Classification, PHASE II TRIAL, code=C15601, ref=CDISC CT, ver=&ctver)
	%tsrec(TTYPE, 1, Trial Type, EFFICACY, code=C49666, ref=CDISC CT, ver=&ctver)
	%tsrec(TTYPE, 2, Trial Type, SAFETY, code=C49667, ref=CDISC CT, ver=&ctver)
	%tsrec(TINDTP, 1, Trial Intent Type, TREATMENT, code=C49656, ref=CDISC CT, ver=&ctver)
	%tsrec(INTMODEL, 1, Intervention Model, PARALLEL, code=C82639, ref=CDISC CT, ver=&ctver)
	%tsrec(INTTYPE, 1, Intervention Type, DRUG, code=C1909, ref=CDISC CT, ver=&ctver)
	%tsrec(TBLIND, 1, Trial Blinding Schema, DOUBLE BLIND, code=C15228, ref=CDISC CT, ver=&ctver)
	%tsrec(TCNTRL, 1, Control Type, PLACEBO, code=C49648, ref=CDISC CT, ver=&ctver)
	%tsrec(RANDOM, 1, Trial is Randomized, Y, code=C49488, ref=CDISC CT, ver=&ctver)
	%tsrec(NARMS, 1, Planned Number of Arms, 3)
	%tsrec(NCOHORT, 1, Number of Groups/Cohorts, 3)
	%tsrec(ADDON, 1, Added on to Existing Treatments, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(ADAPT, 1, Adaptive Design, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(EXTTIND, 1, Extension Trial Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(LENGTH, 1, Trial Length, P18W, ref=ISO 8601)
	%tsrec(STOPRULE, 1, Study Stop Rules, %str(The DSMB reviews unblinded safety data and may recommend modification or termination of the study for safety reasons only))

	/* Population */
	%tsrec(PLANSUB, 1, Planned Number of Subjects, 300)
	%tsrec(AGEMIN, 1, Planned Minimum Age of Subjects, P18Y, ref=ISO 8601)
	%tsrec(AGEMAX, 1, Planned Maximum Age of Subjects, P85Y, ref=ISO 8601)
	%tsrec(SEXPOP, 1, Sex of Participants, BOTH, code=C49636, ref=CDISC CT, ver=&ctver)
	%tsrec(HLTSUBJI, 1, Healthy Subject Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(TDIGRP, 1, Diagnosis Group, Chronic liver disease, code=328383001, ref=SNOMED, ver=2025-09)
	%tsrec(INDIC, 1, Trial Disease/Condition Indication, Chronic liver disease, code=328383001, ref=SNOMED, ver=2025-09)
	%tsrec(PDSTIND, 1, Pediatric Study Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(PDPSTIND, 1, Pediatric Postmarket Study Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(PIPIND, 1, Pediatric Investigation Plan Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(RDIND, 1, Rare Disease Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
	%tsrec(FCNTRY, 1, Planned Country of Investigational Sites, USA, code=USA, ref=ISO 3166)

	/* Treatments: Drug A and Drug B are fictional, so they have no UNII code or pharmacologic class */
	%tsrec(TRT, 1, Investigational Therapy or Treatment, DRUG A, ref=UNII, ver=2026-08-04)
	%tsrec(TRT, 2, Investigational Therapy or Treatment, DRUG B, ref=UNII, ver=2026-08-04)
	%tsrec(PCLAS, 1, Pharmacologic Class, , nf=UNK)
	%tsrec(CURTRT, 1, Current Therapy or Treatment, , nf=NA)

	/* Objectives and outcome measures */
	%tsrec(OBJPRIM, 1, Trial Primary Objective, %str(To compare the effects of Drug A and of Drug B with placebo on liver function (ALT, AST) and systemic inflammation (CRP) in adults with CLD))
	%tsrec(OBJPRIM, 2, Trial Primary Objective, %str(To evaluate the safety and tolerability of Drug A and Drug B compared with placebo from first dose through follow-up))
	%tsrec(OBJSEC, 1, Trial Secondary Objective, %str(To compare the magnitude and time course of changes in ALT, AST, CRP and HGB among the three treatment groups, including Drug A versus Drug B))
	%tsrec(OBJSEC, 2, Trial Secondary Objective, %str(To assess the proportion of participants achieving clinically meaningful improvements in laboratory biomarkers))
	%tsrec(OUTMSPRI, 1, Primary Outcome Measure, Change from baseline to Week 12 in ALT)
	%tsrec(OUTMSPRI, 2, Primary Outcome Measure, Change from baseline to Week 12 in AST)
	%tsrec(OUTMSPRI, 3, Primary Outcome Measure, Change from baseline to Week 12 in CRP)
	%tsrec(OUTMSPRI, 4, Primary Outcome Measure, %str(Incidence, severity and relationship of treatment-emergent adverse events from first dose through follow-up))
	%tsrec(OUTMSSEC, 1, Secondary Outcome Measure, %str(Mean change from baseline in ALT, AST, CRP and HGB at Weeks 4, 8 and 12 and at follow-up))
	%tsrec(OUTMSSEC, 2, Secondary Outcome Measure, %str(Difference between Drug A and Drug B in mean change from baseline to Week 12 in ALT, AST, CRP and HGB))
	%tsrec(OUTMSSEC, 3, Secondary Outcome Measure, %str(Proportion of participants achieving the predefined improvement in CRP, ALT, AST and HGB at Week 12))
	%tsrec(OUTMSSEC, 4, Secondary Outcome Measure, %str(Change from baseline in vital signs at Weeks 4, 8 and 12 and at follow-up))

	/* Study dates and subjects, from DM */
	%tsrec(SSTDTC, 1, Study Start Date, &sstdtc, ref=ISO 8601)
	%tsrec(SENDTC, 1, Study End Date, &sendtc, ref=ISO 8601)
	%tsrec(DCUTDTC, 1, Data Cutoff Date, &sendtc, ref=ISO 8601)
	%tsrec(DCUTDESC, 1, Data Cutoff Description, LAST SUBJECT LAST VISIT)
	%tsrec(ACTSUB, 1, Actual Number of Subjects, &actsub)
	%tsrec(ONGOSIND, 1, Ongoing Study Indicator, N, code=C49487, ref=CDISC CT, ver=&ctver)
run;

/* Making the structure of the TS table */
data final.ts;
	retain STUDYID DOMAIN TSSEQ TSPARMCD TSPARM TSVAL TSVALNF TSVALCD TSVCDREF TSVCDVER;
	set inter.ts;
	STUDYID="LORNA";
	DOMAIN="TS";
	keep STUDYID DOMAIN TSSEQ TSPARMCD TSPARM TSVAL TSVALNF TSVALCD TSVCDREF TSVCDVER;
run;

/* Sorting the final TS table */
proc sort data=final.ts;
	by STUDYID TSPARMCD TSSEQ;
run;
