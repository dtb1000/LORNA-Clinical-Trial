# Study documents

These documents define the LORNA (DLF552) trial and the way its data were collected and mapped. Every dataset in this repository can be traced back to them.

| Document | Content | Used by |
|---|---|---|
| [`LORNA-Trial-Protocol-v1.1.pdf`](LORNA-Trial-Protocol-v1.1.pdf) | Objectives and endpoints, design, eligibility criteria, schedule of activities, study intervention, safety reporting and, in Section 8, the statistical analysis plan (SAP) | All stages; the SAP drives the ADaM derivations |
| [`LORNA-eCRF.pdf`](LORNA-eCRF.pdf) | The 13 data collection forms, from screening and informed consent to the investigator's confirmation | Defines what is collected |
| [`LORNA-aCRF.pdf`](LORNA-aCRF.pdf) | The eCRF annotated with the SDTM domain and variable for each field | SDTM mapping and define.xml |

## Protocol version 1.1

Version 1.1 (1 November 2022) is an amendment of version 1.0 and is the version in force for the whole study. Its main changes are the addition of the SAP as Section 8 and the correction of inconsistencies between sections. A table at the start of the document lists every change.

## Reading the annotated CRF

The aCRF follows the CDISC Metadata Submission Guidelines:

- Each form shows a labelled box for every domain it feeds, for example `DM (Demographics)`.
- Each field carries the variable it maps to, coloured to match its domain box.
- Fields that are collected but not submitted are marked `[NOT SUBMITTED]`.
- Bookmarks list the forms and the domains, so you can jump to every page that feeds a domain.

The annotations use CDISC SDTM controlled terminology 2025-09-26, the same version as the datasets and define.xml: for example, Intersex is annotated as SEX = INTERSEX, the dosing frequency as EXDOSFRQ = "EVERY 4 WEEKS", and the CRP test as LBTEST = C Reactive Protein. A copy of the aCRF sits next to the define.xml in [`03-sdtm/define/`](../03-sdtm/define/), because define.xml links each collected variable to its page.

Some fields on the CRF have no values in the synthetic data because the Python generator does not simulate them, for example medication start dates. They are annotated as a real study would annotate them. [`03-sdtm/README.md`](../03-sdtm/README.md) lists them and explains how each is handled.
