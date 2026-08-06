# Importing relevant libraries
from pathlib import Path
from datetime import datetime, timedelta
import pandas as pd
import random

# Details about the trial
STUDY_CONFIG = {
    "STUDY_ID": "LORNA",                                                        # Name of CT
    "PHASE": "Phase II",                                                        # Phase of CT
    "STUDY_TYPE": "PARALLEL",                                                   # Design of CT
    "N_SUBJECTS": 300,                                                          # Number of subjects enrolled
    "N_SITES": 4,                                                               # Number of study sites involved
    "COUNTRY": "USA"                                                            # Country where the trial takes place
}

# Output lists for study data
study_metadata = []                                                             # Creates the list study_metadata
subjects = []                                                                   # Creates the list subjects
medical_history = []                                                            # Creates the list medical_history
concom_med = []                                                                 # Creates the list concom_med
exposure = []                                                                   # Creates the list exposure
visits = []                                                                     # Creates the list visits
protocol_deviations = []                                                        # Creates the list protocol deviations
labs = []                                                                       # Creates the list labs
vitals = []                                                                     # Creates the list vitals
adverse_events = []                                                             # Creates the list adverse_events

# Defines the output directory to store CSV files
OUTPUT_DIR = "raw_data"
output = Path(OUTPUT_DIR)
output.mkdir(exist_ok=True)

# Randomly generates data for the given seed number
SEED = input("Input a random number between 1 and 10000: ")
random.seed(SEED)

# Treatment arms
ARMS = {
    "Treatment 1": {
        "treatment": "Drug A",
        "code": "DRGA"
    },
    "Treatment 2": {
        "treatment": "Drug B",
        "code": "DRGB"
    },
    "Control": {
        "treatment": "Placebo",
        "code": "PLC"
    }
}

# Study sites involved
SITES = [
    f"SITE{i:03d}" for i in range(1,5)
]

# Study visit schedule
VISITS = [
    ("SCREENING", -14),
    ("BASELINE", 0),
    ("WEEK 4", 28),
    ("WEEK 8", 56),
    ("WEEK 12", 84),
    ("FOLLOW-UP", 112)
]

# Details about subjects
SEXES = [
    "Male",
    "male",
    "Man",
    "man",
    "Female",
    "female",
    "Woman",
    "woman",
    "Intersex",
    "Unknown",
    "Not specified"
]                                                                   # Sex
RACES = [
    "White",
    "WHITE",
    "white",
    "ASIAN",
    "asian",
    "Black or African American",
    "BLACK OR AFRICAN AMERICAN",
    "AFRICAN AMERICAN",
    "OTHER",
    "other"
]                                                                   # Race
ETHNICITIES = [
    "Hispanic or Latino",
    "Not Hispanic or Latino",
    "HISPANIC",
    "Hispanic not Latino",
    "NOT HISPANIC NOT LATINO"
]                                                             # Ethnicity

MED_HIST = {
    "Hypertension": 0.40,
    "Type 2 Diabetes": 0.20,
    "Hyperlipidemia": 0.25,
    "Stroke": 0.05
}                                                                # Medical history
MED_HIST_RATE = 0.30

CON_MED = {
    "Lisinopril": {
        "unit": "mg",
        "doses": {
            2.5: 0.05,
            5: 0.15,
            10: 0.35,
            20: 0.35,
            40: 0.10,
        },
        "formulations": {
            "Tablet": 1.00,
        },
        "frequencies": {
            "QD": 0.95,
            "BID": 0.05,
        },
    },

    "Metformin": {
        "unit": "mg",
        "doses": {
            500: 0.45,
            850: 0.10,
            1000: 0.45,
        },
        "formulations": {
            "Immediate-release tablet": 0.70,
            "Extended-release tablet": 0.30,
        },
        "frequencies": {
            "QD": 0.30,
            "BID": 0.65,
            "TID": 0.05,
        },
    },

    "Simvastatin": {
        "unit": "mg",
        "doses": {
            5: 0.05,
            10: 0.25,
            20: 0.40,
            40: 0.30,
        },
        "formulations": {
            "Tablet": 1.00,
        },
        "frequencies": {
            "QD": 1.00,
        },
    },

    "Losartan": {
        "unit": "mg",
        "doses": {
            25: 0.20,
            50: 0.55,
            100: 0.25,
        },
        "formulations": {
            "Tablet": 1.00,
        },
        "frequencies": {
            "QD": 0.90,
            "BID": 0.10,
        },
    },
}                                                                 # Concomitant medication
MED_TO_CONMED = {
    "Hypertension": "Lisinopril",
    "Type 2 Diabetes": "Metformin",
    "Hyperlipidemia": "Simvastatin",
    "Stroke": "Losartan"
}                                                           # Mapping medical history to concomitant medication

# Laboratory test results and findings
LABS = {
    "ALT": ("Alanine Aminotransferase", 7, 56, "U/L"),
    "AST": ("Aspartate Aminotransferase", 8, 48, "U/L"),
    "CRP": ("C-Reactive Protein", 0, 10, "mg/L"),
    "HGB": ("Hemoglobin", 12, 17.5, "g/dL")
}                                                                    # Lab test value ranges
VS = {
    "SYSBP": ("Systolic BP", "mmHg"),
    "DIABP": ("Diastolic BP", "mmHg"),
    "HR": ("Heart Rate", "bpm"),
    "TEMP": ("Temperature", "C"),
    "WEIGHT": ("Weight", "kg"),
    "RESP": ("Respiratory Rate", "breaths/min")
}                                                                      # Vital signs

# Effects of each treatment on test parameters
TREATMENT_EFFECTS = {

    "Drug A": {
        "ALT": {
            "trend": "decrease",
            "slope": (1.0, 1.5),
            "noise": 2.0,
            "minimum": 5,
        },
        "AST": {
            "trend": "decrease",
            "slope": (0.8, 1.3),
            "noise": 2.0,
            "minimum": 5,
        },
        "CRP": {
            "trend": "decrease",
            "slope": (0.3, 0.7),
            "noise": 0.8,
            "minimum": 0.1,
        },
        "HGB": {
            "trend": "stable",
            "shift": (-0.15, 0.15),
            "noise": 0.3,
            "minimum": 5,
        },
    },
    "Drug B": {
        "ALT": {
            "trend": "decrease",
            "slope": (0.5, 1.0),
            "noise": 2.0,
            "minimum": 5,
        },
        "AST": {
            "trend": "decrease",
            "slope": (0.4, 0.8),
            "noise": 2.0,
            "minimum": 5,
        },
        "CRP": {
            "trend": "decrease",
            "slope": (0.2, 0.4),
            "noise": 0.8,
            "minimum": 0.1,
        },
        "HGB": {
            "trend": "stable",
            "shift": (-0.10, 0.10),
            "noise": 0.3,
            "minimum": 5,
        },
    },
    "Placebo": {
        "ALT": {
            "trend": "decrease",
            "slope": (0.00, 0.20),
            "noise": 2.0,
            "minimum": 5,
        },
        "AST": {
            "trend": "decrease",
            "slope": (0.00, 0.20),
            "noise": 2.0,
            "minimum": 5,
        },
        "CRP": {
            "trend": "decrease",
            "slope": (0.00, 0.10),
            "noise": 0.8,
            "minimum": 0.1,
        },
        "HGB": {
            "trend": "stable",
            "shift": (-0.10, 0.10),
            "noise": 0.3,
            "minimum": 5,
        },
    },
}

AE_PROFILE = {
    "Drug A": {
        "events": {
            "Headache": {
                "incidence": 0.18,
                "severity_probs": {
                    "Mild": 0.70,
                    "Moderate": 0.25,
                    "Severe": 0.05,
                },
                "serious_prob": 0.001,
            },
            "Dizziness": {
                "incidence": 0.10,
                "severity_probs": {
                    "Mild": 0.60,
                    "Moderate": 0.35,
                    "Severe": 0.05,
                },
                "serious_prob": 0.002,
            },
            "Fatigue": {
                "incidence": 0.15,
                "severity_probs": {
                    "Mild": 0.65,
                    "Moderate": 0.30,
                    "Severe": 0.05,
                },
                "serious_prob": 0.001,
            },
            "Nausea": {
                "incidence": 0.12,
                "severity_probs": {
                    "Mild": 0.75,
                    "Moderate": 0.20,
                    "Severe": 0.05,
                },
                "serious_prob": 0.001,
            },
            "Allergy": {
                "incidence": 0.03,
                "severity_probs": {
                    "Mild": 0.50,
                    "Moderate": 0.35,
                    "Severe": 0.15,
                },
                "serious_prob": 0.1,
            },
        },
    },

    "Drug B": {
        "events": {
            "Headache": {
                "incidence": 0.09,
                "severity_probs": {
                    "Mild": 0.80,
                    "Moderate": 0.18,
                    "Severe": 0.02,
                },
                "serious_prob": 0.001,
            },
            "Fatigue": {
                "incidence": 0.07,
                "severity_probs": {
                    "Mild": 0.75,
                    "Moderate": 0.22,
                    "Severe": 0.03,
                },
                "serious_prob": 0.001,
            },
            "Nausea": {
                "incidence": 0.05,
                "severity_probs": {
                    "Mild": 0.80,
                    "Moderate": 0.18,
                    "Severe": 0.02,
                },
                "serious_prob": 0.001,
            },
        },
    },

    "Placebo": {
        "events": {
            "Headache": {
                "incidence": 0.10,
                "severity_probs": {
                    "Mild": 0.90,
                    "Moderate": 0.09,
                    "Severe": 0.01,
                },
                "serious_prob": 0.0005,
            },
        },
    },
}                                                              # Safety profile for each treatment
AE_VISITS = [
            ("BASELINE", 0),
            ("WEEK 4", 28),
            ("WEEK 8", 56),
            ("WEEK 12", 84)
        ]                                                               # Setting possible visits to report adverse events

# Deciding the quality of output data
QUALITY = input("Input the desired quality of output data (allowed values are CLEAN, MODERATE, and SEVERE): ")
QUALITY_SETTINGS = {
    "CLEAN": {"missing_rate": 0.00, "error_rate": 0.00},
    "MODERATE": {"missing_rate": 0.05, "error_rate": 0.05},
    "SEVERE": {"missing_rate": 0.10, "error_rate": 0.10}
}
MISSING_RATE = QUALITY_SETTINGS[QUALITY]["missing_rate"]
ERROR_RATE = QUALITY_SETTINGS[QUALITY]["error_rate"]

# Function to randomly generate missing values
def maybe_missing(value):
    if random.random() < MISSING_RATE:
        return None
    return value

# Function to randomly select a value from a dictionary using the specified probability weights
def weighted_choice(options):
    return random.choices(
        list(options.keys()),
        weights=list(options.values()),
        k=1
    )[0]

# Function to randomly generate invalid ages
def maybe_invalid_age(age):
    if random.random() < 0.01:
        return random.choice([-5, 150, 999])
    return age

# Function to generate random enrolment dates
def random_enrolment_date(subject_number):
    base = datetime(2023, 1, 1)
    return base + timedelta(days=subject_number + random.randint(0, 2))

# Function to generate random baseline lab results
def create_baseline_labs():
    return {
        "ALT": round(random.normalvariate(40, 8), 1),
        "AST": round(random.normalvariate(35, 6), 1),
        "CRP": round(random.normalvariate(5, 2), 1),
        "HGB": round(random.normalvariate(14, 1.2), 1)
    }

# Function to create random vital signs
def create_vital_signs(parameter):

    parameter = VS[parameter][0]

    # Rare extreme outliers
    if random.random() < 0.01:
        extreme_values = {
            "Systolic BP": random.choice([50, 300]),
            "Diastolic BP": random.choice([20, 200]),
            "Heart Rate": random.choice([20, 250]),
            "Respiratory Rate": random.choice([4, 60]),
            "Temperature": random.choice([32.0, 43.0]),
            "Weight": random.choice([20, 300]),
            "BMI": random.choice([10, 80])
        }

        return extreme_values[parameter]

    # Mild abnormalities
    if random.random() < 0.10:
        abnormal_values = {
            "Systolic BP": random.normalvariate(145, 15),
            "Diastolic BP": random.normalvariate(95, 10),
            "Heart Rate": random.normalvariate(105, 15),
            "Respiratory Rate": random.normalvariate(24, 4),
            "Temperature": random.normalvariate(38.2, 0.5),
            "Weight": random.normalvariate(110, 20),
            "BMI": random.normalvariate(35, 5)
        }

        return round(abnormal_values[parameter])

    # Normal values
    normal_values = {
        "Systolic BP": random.normalvariate(120, 10),
        "Diastolic BP": random.normalvariate(80, 8),
        "Heart Rate": random.normalvariate(72, 8),
        "Respiratory Rate": random.normalvariate(16, 2),
        "Temperature": random.normalvariate(36.8, 0.3),
        "Weight": random.normalvariate(80, 15),
        "BMI": random.normalvariate(27, 4)
    }

    return round(normal_values[parameter])

# Function to create subject-specific treatment response parameters which remain constant throughout the trial
def create_subject_response(treatment):

    arm = treatment["treatment"]
    profile = {}

    for lab, params in TREATMENT_EFFECTS[arm].items():

        if params["trend"] == "decrease":
            profile[lab] = {
                "trend": "decrease",
                "slope": random.uniform(*params["slope"])
            }

        elif params["trend"] == "increase":
            profile[lab] = {
                "trend": "increase",
                "slope": random.uniform(*params["slope"])
            }

        else:
            profile[lab] = {
                "trend": "stable",
                "shift": random.uniform(*params["shift"])
            }

    return profile

# Function to randomly generate effects of drugs on test parameters
def treatment_effect(test, baseline, week, response_profile, treatment):
    arm = treatment["treatment"]
    params = TREATMENT_EFFECTS[arm][test]
    subject = response_profile[test]

    # Expected values
    if subject["trend"] == "decrease":
        expected = baseline - week * subject["slope"]

    elif subject["trend"] == "increase":
        expected = baseline + week * subject["slope"]

    else:
        expected = baseline + subject["shift"]

    # Accounting for biological variability
    value = expected + random.normalvariate(0, params["noise"])

    # Preventing negative values
    return max(value, params["minimum"])

# Function to generate clinical trial data
def generate_data():
    global offset, visit_name, visit_date
    study_metadata.append({
        **STUDY_CONFIG,
        "SEED": SEED
    })

    for i in range(1, STUDY_CONFIG["N_SUBJECTS"] + 1):

        subjnum = i
        subjid = f"SUBJ{i:03d}"
        siteid = random.choice(SITES)
        age = maybe_invalid_age(random.randint(18, 85))
        sex = random.choice(SEXES)
        race = random.choice(RACES)
        ethnicity = random.choice(ETHNICITIES)
        treatment = random.choice(list(ARMS.values()))
        response_profile = create_subject_response(treatment)
        enrol_date = random_enrolment_date(subjnum)
        baseline_labs = create_baseline_labs()                                  # Creates baseline lab results

        subjects.append({
            "SUBJECT_NUM": subjnum,
            "SUBJECT_ID": subjid,
            "SITE_ID": siteid,
            "AGE": maybe_missing(age),
            "SEX": maybe_missing(sex),
            "RACE": maybe_missing(race),
            "ETHNICITY": maybe_missing(ethnicity),
            "ENROLLED_ON": enrol_date.date()
        })

        exposure.append({
            "SUBJECT_NUM": subjnum,
            "SUBJECT_ID": subjid,
            "SITE_ID": siteid,
            "TREATMENT_ARM": treatment["treatment"],
            "ARM_CODE": treatment["code"],
            "START_DATE": enrol_date.date(),
            "END_DATE": (enrol_date + timedelta(days=84)).date()
        })

        if random.random() < MED_HIST_RATE:                                     # Decides whether the subject has any medical history

            assigned_conditions = set()

            for med_hist, prevalence in MED_HIST.items():                       # Independently assigns each condition
                if random.random() < prevalence:
                    assigned_conditions.add(med_hist)

            if not assigned_conditions:                                     # Guarantees at least one condition
                assigned_conditions.add(
                    random.choices(
                        list(MED_HIST.keys()),
                        weights=list(MED_HIST.values()),
                        k=1
                    )[0]
                )

            for med_hist in assigned_conditions:                                # Creates medical history and concomitant medication records

                medical_history.append({
                    "SUBJECT_NUM": subjnum,
                    "SUBJECT_ID": subjid,
                    "SITE_ID": siteid,
                    "MEDICAL_BG": med_hist
                })

                drug = MED_TO_CONMED[med_hist]
                drug_info = CON_MED[drug]

                concom_med.append({
                    "SUBJECT_NUM": subjnum,
                    "SUBJECT_ID": subjid,
                    "SITE_ID": siteid,
                    "MEDICATION": drug,
                    "DOSE": weighted_choice(drug_info["doses"]),
                    "UNIT": drug_info["unit"],
                    "FORMULATION": weighted_choice(drug_info["formulations"]),
                    "FREQUENCY": weighted_choice(drug_info["frequencies"]),
                })

        for visit_name, offset in VISITS:

            visit_date = enrol_date + timedelta(days=offset)                    # Offset represents days after enrolment

            if visit_name not in ("SCREENING", "BASELINE") and random.random() < 0.05:
                protocol_deviations.append({
                    "SUBJECT_NUM": subjnum,
                    "SUBJECT_ID": subjid,
                    "SITE_ID": siteid,
                    "ERROR": "Missed visit",
                    "VISIT_TYPE": visit_name,
                    "VISIT_DATE": visit_date.date()
                })

                continue

            visits.append({
                "SUBJECT_NUM": subjnum,
                "SUBJECT_ID": subjid,
                "SITE_ID": siteid,
                "VISIT_TYPE": visit_name,
                "VISIT_DATE": visit_date.date()
            })

            week = max(offset/7, 0)                                               # Converts the offset to weeks post-screening

            for test, (test_name, lln, uln, unit) in LABS.items():                # Generates lab results for each visit
                value = round(
                    treatment_effect(
                        test=test,
                        baseline=baseline_labs[test],
                        week=week,
                        response_profile=response_profile,
                        treatment=treatment,
                    ),
                    1,
                )

                labs.append({
                    "SUBJECT_NUM": subjnum,
                    "SUBJECT_ID": subjid,
                    "SITE_ID": siteid,
                    "VISIT_TYPE": visit_name,
                    "VISIT_DATE": visit_date.date(),
                    "TEST": test,
                    "TEST_NAME": test_name,
                    "RESULT": maybe_missing(value),
                    "UNIT": unit,
                    "LOWER": lln,
                    "UPPER": uln
                })

            for code, (parameter, unit) in VS.items():                             # Generates vital sign values for each visit
                vitals.append({
                    "SUBJECT_NUM": subjnum,
                    "SUBJECT_ID": subjid,
                    "SITE_ID": siteid,
                    "VISIT_TYPE": visit_name,
                    "VISIT_DATE": visit_date.date(),
                    "TEST": code,
                    "TEST_NAME": parameter,
                    "RESULT": maybe_missing(create_vital_signs(code)),
                    "UNIT": unit
                })

        profile = AE_PROFILE[treatment["treatment"]]

        for event_name, event_data in profile["events"].items():

            if random.random() < event_data["incidence"]:
                severity = random.choices(
                    population=list(event_data["severity_probs"].keys()),
                    weights=list(event_data["severity_probs"].values()),
                    k=1
                )[0]

                serious = random.random() < event_data["serious_prob"]

                # Choose the visit where AE starts
                ae_visit, ae_offset = random.choice(AE_VISITS)

                ae_visit_date = enrol_date + timedelta(days=ae_offset)

                start_delay = random.randint(0, 3)
                started_on = ae_visit_date + timedelta(days=start_delay)
                duration = random.randint(0, 2)
                ended_on = started_on + timedelta(days=duration)

                adverse_events.append({
                    "SUBJECT_NUM": subjnum,
                    "SUBJECT_ID": subjid,
                    "SITE_ID": siteid,
                    "TREATMENT": treatment["treatment"],
                    "VISIT": ae_visit,
                    "REPORTED_EVENT": event_name,
                    "SEVERITY": severity.upper(),
                    "SERIOUS": "YES" if serious else "NO",
                    "START_DATE": started_on.date(),
                    "END_DATE": ended_on.date()
                })

        # Exports all the lists as CSV files
        (pd.DataFrame(study_metadata).to_csv(output / "study_metadata.csv", index=False))
        (pd.DataFrame(subjects).to_csv(output / "subjects.csv", index=False))
        (pd.DataFrame(exposure).to_csv(output / "exposure.csv", index=False))
        (pd.DataFrame(medical_history).to_csv(output / "medical_history.csv", index=False))
        (pd.DataFrame(concom_med).to_csv(output / "concom_med.csv", index=False))
        (pd.DataFrame(protocol_deviations).to_csv(output / "deviations.csv", index=False))
        (pd.DataFrame(visits).to_csv(output / "visits.csv", index=False))
        (pd.DataFrame(labs).to_csv(output / "labs.csv", index=False))
        (pd.DataFrame(vitals).to_csv(output / "vitals.csv", index=False))
        (pd.DataFrame(adverse_events).to_csv(output / "ae.csv", index=False))

# Calling functions to generate study data
generate_data()
print("Clinical trial data generated.")