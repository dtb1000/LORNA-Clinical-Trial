# SDTM define.xml

This folder holds the define.xml for the 14 SDTM domains, written to **Define-XML v2.1** with Pinnacle 21 Community.

| File | Content |
|---|---|
| [`define.xml`](define.xml) | The data definition file |
| [`define2-1-0.xsl`](define2-1-0.xsl) | Stylesheet. Keep it next to define.xml so that the file opens as a readable page in a browser |
| [`acrf.pdf`](acrf.pdf) | Copy of the annotated CRF ([`docs/LORNA-aCRF.pdf`](../../docs/LORNA-aCRF.pdf)). define.xml links each collected variable to its page here, so the file must sit in the same folder |
| [`LORNA-SDTM-define-spec.xlsx`](LORNA-SDTM-define-spec.xlsx) | The Excel specification define.xml is generated from. Edit this, not the XML |

To view define.xml, open it in a browser. Some browsers block local stylesheets; if the page is blank, open it in Firefox or serve the folder with a local web server.

## Contents

| Section | What it describes |
|---|---|
| Standards | SDTMIG v3.4 and CDISC SDTM controlled terminology 2025-09-26 |
| Datasets | Class, structure, key variables and location of each of the 14 domains, including TS |
| Variables | Label, type, length, codelist, role and origin for all 211 variables |
| Value-level metadata | Result type and length of LBORRES for each LBTESTCD and VSORRES for each VSTESTCD |
| Codelists | 39 codelists: CDISC terms with their NCI codes (including TSPARMCD, TSPARM and the reference terminologies used in TS), plus sponsor lists for arms, elements, visits, AE causality and deviation categories |
| External dictionaries | MedDRA (AE and MH coding), ATC (CM class), ISO 3166 (COUNTRY) and ISO 21090 (TS null flavours) |
| Methods | 25 derivations, including USUBJID, --SEQ, study day, EPOCH and TAETORD, the reference dates, subject elements, the standard results and the baseline flags |
| Comments | Variables not submitted (CM and MH start dates; AE fields not captured), AGEU, the empty TV.ARMCD, and how TS values were sourced |
| aCRF links | Each collected variable links to its page in `acrf.pdf` |

### Origins

| Origin | Used for |
|---|---|
| Collected (Investigator) | CRF fields, with their aCRF page |
| Collected (Vendor) | Central laboratory reference ranges |
| Derived | Variables computed in SAS, each with a method, including every --DY study day |
| Assigned | Fixed values and dictionary coding (MedDRA, ATC) |
| Protocol | Trial design domains (TA, TE, TV, TS), and fixed EX values such as the route and dose form |

## How it was made

1. **Create Spec** in Pinnacle 21 Community read the 14 XPT files in [`../datasets/xpt/`](../datasets/xpt/) with the SDTM-IG 3.4 configuration and wrote an Excel spec with dataset and variable metadata.
2. The spec was completed with origins, aCRF pages, codelists (NCI codes taken from the CT 2025-09-26 package that Pinnacle 21 installs), value-level metadata, methods and comments. TSVCDVER was set to text, because Pinnacle 21 reads its version values as dates.
3. **Generate Define** created define.xml (v2.1) from the spec.
4. Pinnacle 21 Community writes the controlled terminology standard from the *Terminology* column of the Codelists tab (`CDISC/NCI 2025-09-26`), but with PublishingSet `CDISC/NCI` and an OID containing a space and a slash. The `def:Standard` element was corrected by hand to PublishingSet `SDTM` with the OID `STD.CT.SDTM.2025-09-26`, and the codelists were pointed at it.
5. define.xml was validated together with the datasets: the validator reported **no define.xml findings**. See [`../validation/`](../validation/).

## Points to check

- **Dictionary versions:** the protocol does not state the versions. The define.xml uses **MedDRA 26.0** and **ATC 2023** as placeholders; change them in the *Dictionaries* tab if the coding used other versions.
- **Values outside CT:** every value now matches CT 2025-09-26 except `ISO 8601` in TSVCDREF, which is a valid addition to the extensible DICTNAM codelist.

## Re-creating define.xml after a change to a domain

1. Re-run *Create Spec* on the new XPT files (configuration SDTM-IG 3.4).
2. Copy the completed tabs from this spec into the new one. Keep method and comment IDs without the `MT.` and `COM.` prefixes, because Pinnacle 21 adds them, and keep the document ID `acrf`.
3. Run *Generate Define* (Define-XML 2.1), then correct the CT standard (step 4 above).
4. Copy the stylesheet and the current aCRF into this folder.
