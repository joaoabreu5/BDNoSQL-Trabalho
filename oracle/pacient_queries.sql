-- Delete 
-- Check for existing dependencies first
-- SELECT * FROM USER_DEPENDENCIES WHERE REFERENCED_NAME = 'PATIENTROW';

-- Drop the table type if it exists
-- DROP TYPE PatientTable;

-- Drop the object type if it exists
-- DROP TYPE PatientRow;

-- 1)
-- All info about Hospital.Patient
CREATE OR REPLACE TYPE PatientRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE
);

CREATE OR REPLACE TYPE PatientTable IS TABLE OF PatientRow;

CREATE OR REPLACE FUNCTION AllInfoPatient(id_patient IN NUMBER)
  RETURN PatientTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM Hospital.Patient p
    WHERE p.IDPATIENT = id_patient
  ) LOOP
    PIPE ROW (PatientRow(rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE,
                         rec.PHONE, rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY));
  END LOOP;
  RETURN;
END AllInfoPatient;

SELECT * FROM TABLE(AllInfoPatient(2));

-- 2) 
-- All info about Hospital.Medical_History
CREATE OR REPLACE TYPE MedicalHistoryRow AS OBJECT (
  RECORD_ID NUMBER,
  RECORD_DATE DATE,
  IDPATIENT NUMBER,
  CONDITION VARCHAR2(25)
);

CREATE OR REPLACE TYPE MedicalHistoryTable IS TABLE OF MedicalHistoryRow;

CREATE OR REPLACE FUNCTION AllInfoMedicalHistory(id_patient IN NUMBER)
  RETURN MedicalHistoryTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT m.RECORD_ID, m.RECORD_DATE, m.IDPATIENT, m.CONDITION
    FROM HOSPITAL.MEDICAL_HISTORY m
    WHERE m.IDPATIENT = id_patient
  ) LOOP
    PIPE ROW (MedicalHistoryRow(rec.RECORD_ID, rec.RECORD_DATE, rec.IDPATIENT, rec.CONDITION));
  END LOOP;
  RETURN;
END AllInfoMedicalHistory;

SELECT * FROM TABLE(AllInfoMedicalHistory(1));

-- 3)
-- All info about Hospital.Insurance
CREATE OR REPLACE TYPE InsuranceRow AS OBJECT (
  POLICY_NUMBER VARCHAR2(45),
  PROVIDER VARCHAR2(45),
  INSURANCE_PLAN VARCHAR2(45),
  CO_PAY NUMBER(10,2),
  COVERAGE VARCHAR2(20),
  MATERNITY CHAR(1),
  DENTAL CHAR(1),
  OPTICAL CHAR(1)
);

CREATE OR REPLACE TYPE InsuranceTable IS TABLE OF InsuranceRow;

CREATE OR REPLACE FUNCTION AllInfoInsurance(id_patient IN NUMBER)
  RETURN InsuranceTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT i.POLICY_NUMBER, i.PROVIDER, i.INSURANCE_PLAN, i.CO_PAY, i.COVERAGE,
           i.MATERNITY, i.DENTAL, i.OPTICAL
    FROM HOSPITAL.INSURANCE i
    JOIN HOSPITAL.PATIENT p ON i.POLICY_NUMBER = p.POLICY_NUMBER
    WHERE p.IDPATIENT = id_patient
  ) LOOP
    PIPE ROW (InsuranceRow(rec.POLICY_NUMBER, rec.PROVIDER, rec.INSURANCE_PLAN, rec.CO_PAY,
                           rec.COVERAGE, rec.MATERNITY, rec.DENTAL, rec.OPTICAL));
  END LOOP;
  RETURN;
END AllInfoInsurance;

SELECT * FROM TABLE(AllInfoInsurance(1));

-- 4)
-- All info about Hospital.Emergency_Contact
CREATE OR REPLACE TYPE EmergencyContactRow AS OBJECT (
  CONTACT_NAME VARCHAR2(45),
  PHONE VARCHAR2(30),
  RELATION VARCHAR2(45),
  IDPATIENT NUMBER(38,0)
);

CREATE OR REPLACE TYPE EmergencyContactTable IS TABLE OF EmergencyContactRow;

CREATE OR REPLACE FUNCTION AllInfoEmergencyContact(id_patient IN NUMBER)
  RETURN EmergencyContactTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT e.CONTACT_NAME, e.PHONE, e.RELATION, e.IDPATIENT
    FROM HOSPITAL.EMERGENCY_CONTACT e
    WHERE e.IDPATIENT = id_patient
  ) LOOP
    PIPE ROW (EmergencyContactRow(rec.CONTACT_NAME, rec.PHONE, rec.RELATION, rec.IDPATIENT));
  END LOOP;
  RETURN;
END AllInfoEmergencyContact;

SELECT * FROM TABLE(AllInfoEmergencyContact(1));

-- 5)
-- Combined type for all patient information
CREATE OR REPLACE TYPE PatientAllInfoRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE,
  RECORD_ID NUMBER(38,0),
  RECORD_DATE DATE, 
  CONDITION VARCHAR2(25),
  INSURANCE_PROVIDER VARCHAR2(45),
  INSURANCE_PLAN VARCHAR2(45),
  CO_PAY NUMBER(10,2),
  COVERAGE VARCHAR2(20),
  MATERNITY CHAR(1),
  DENTAL CHAR(1),
  OPTICAL CHAR(1),
  EMERGENCY_CONTACT_NAME VARCHAR2(45),
  EMERGENCY_CONTACT_PHONE VARCHAR2(12),
  EMERGENCY_CONTACT_RELATION VARCHAR2(45)
);

CREATE OR REPLACE TYPE PatientAllInfoTable IS TABLE OF PatientAllInfoRow;

CREATE OR REPLACE FUNCTION AllInfoPatient(id_patient IN NUMBER)
  RETURN PatientAllInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY,
           m.RECORD_ID, m.RECORD_DATE, m.CONDITION,
           i.PROVIDER AS INSURANCE_PROVIDER, i.INSURANCE_PLAN, i.CO_PAY, i.COVERAGE,
           i.MATERNITY, i.DENTAL, i.OPTICAL,
           e.CONTACT_NAME AS EMERGENCY_CONTACT_NAME, e.PHONE AS EMERGENCY_CONTACT_PHONE,
           e.RELATION AS EMERGENCY_CONTACT_RELATION
    FROM HOSPITAL.PATIENT p
    LEFT JOIN HOSPITAL.MEDICAL_HISTORY m ON p.IDPATIENT = m.IDPATIENT
    LEFT JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    LEFT JOIN HOSPITAL.EMERGENCY_CONTACT e ON p.IDPATIENT = e.IDPATIENT
    WHERE p.IDPATIENT = id_patient
  ) LOOP
    PIPE ROW (PatientAllInfoRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY,
      rec.RECORD_ID, rec.RECORD_DATE, rec.CONDITION,
      rec.INSURANCE_PROVIDER, rec.INSURANCE_PLAN, rec.CO_PAY, rec.COVERAGE,
      rec.MATERNITY, rec.DENTAL, rec.OPTICAL,
      rec.EMERGENCY_CONTACT_NAME, rec.EMERGENCY_CONTACT_PHONE, rec.EMERGENCY_CONTACT_RELATION
    ));
  END LOOP;
  RETURN;
END AllInfoPatient;

SELECT * FROM TABLE(AllInfoPatient(2));

-- 6)
-- Get Pacient(s) by BloodType
CREATE OR REPLACE FUNCTION AllInfoPatientByBloodType(blood_type IN VARCHAR2)
  RETURN PatientTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    WHERE p.BLOOD_TYPE = blood_type
  ) LOOP
    PIPE ROW (PatientRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    ));
  END LOOP;
  RETURN;
END AllInfoPatientByBloodType;

-- Query to retrieve patient information for a specific blood type
SELECT * FROM TABLE(AllInfoPatientByBloodType('A+'));

-- 7)
-- Get Pacient(s) by Gender
CREATE OR REPLACE FUNCTION AllInfoPatientByGender(gender IN VARCHAR2)
  RETURN PatientTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    WHERE p.GENDER = gender
  ) LOOP
    PIPE ROW (PatientRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    ));
  END LOOP;
  RETURN;
END AllInfoPatientByGender;

-- Query to retrieve patient information for a specific gender
SELECT * FROM TABLE(AllInfoPatientByGender('Male'));

-- 8)
-- Get Pacients by Condition
CREATE OR REPLACE FUNCTION GetPatientsWithCondition(p_condition IN VARCHAR2)
  RETURN PatientTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM Patient p
    INNER JOIN Medical_History mh ON p.IDPATIENT = mh.IDPATIENT
    WHERE mh.CONDITION = p_condition
  ) LOOP
    PIPE ROW (PatientRow(rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE,
                         rec.PHONE, rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY));
  END LOOP;
  RETURN;
END GetPatientsWithCondition;

SELECT * FROM TABLE(GetPatientsWithCondition('Flu'));

-- 9)
-- Get all types of Relations
CREATE OR REPLACE TYPE RelationTypeRow AS OBJECT (
  RELATION VARCHAR2(45)
);

CREATE OR REPLACE TYPE RelationTypeTable IS TABLE OF RelationTypeRow;

CREATE OR REPLACE FUNCTION ListAllRelations
  RETURN RelationTypeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT e.RELATION
    FROM HOSPITAL.EMERGENCY_CONTACT e
  ) LOOP
    PIPE ROW (RelationTypeRow(rec.RELATION));
  END LOOP;
  RETURN;
END ListAllRelations;

-- Query to retrieve all unique relationship types
SELECT * FROM TABLE(ListAllRelations);

-- 10)
-- Get all types of Providers
CREATE OR REPLACE TYPE ProviderInfoRow AS OBJECT (
  PROVIDER VARCHAR2(45)
);

CREATE OR REPLACE TYPE ProviderInfoTable IS TABLE OF ProviderInfoRow;

CREATE OR REPLACE FUNCTION ListAllProviders
  RETURN ProviderInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT i.PROVIDER
    FROM HOSPITAL.INSURANCE i
  ) LOOP
    PIPE ROW (ProviderInfoRow(rec.PROVIDER));
  END LOOP;
  RETURN;
END ListAllProviders;

-- Query to retrieve all unique providers
SELECT * FROM TABLE(ListAllProviders);

-- 11)
-- Get all types of InsurancePlans
-- Type for insurance plan information
CREATE OR REPLACE TYPE InsurancePlanInfoRow AS OBJECT (
  INSURANCE_PLAN VARCHAR2(45)
);

CREATE OR REPLACE TYPE InsurancePlanInfoTable IS TABLE OF InsurancePlanInfoRow;

CREATE OR REPLACE FUNCTION ListAllInsurancePlans
  RETURN InsurancePlanInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT i.INSURANCE_PLAN
    FROM HOSPITAL.INSURANCE i
  ) LOOP
    PIPE ROW (InsurancePlanInfoRow(rec.INSURANCE_PLAN));
  END LOOP;
  RETURN;
END ListAllInsurancePlans;

-- Query to retrieve all unique insurance plans
SELECT * FROM TABLE(ListAllInsurancePlans);

-- 12)
-- Get all types of Coverage
-- Type for coverage information
CREATE OR REPLACE TYPE CoverageInfoRow AS OBJECT (
  COVERAGE VARCHAR2(20)
);

CREATE OR REPLACE TYPE CoverageInfoTable IS TABLE OF CoverageInfoRow;

CREATE OR REPLACE FUNCTION ListAllCoverages
  RETURN CoverageInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT i.COVERAGE
    FROM HOSPITAL.INSURANCE i
  ) LOOP
    PIPE ROW (CoverageInfoRow(rec.COVERAGE));
  END LOOP;
  RETURN;
END ListAllCoverages;

-- Query to retrieve all unique coverage types
SELECT * FROM TABLE(ListAllCoverages);

-- 12)
-- Get all types of Conditions
-- Type for condition information
CREATE OR REPLACE TYPE ConditionInfoRow AS OBJECT (
  CONDITION VARCHAR2(45)
);

CREATE OR REPLACE TYPE ConditionInfoTable IS TABLE OF ConditionInfoRow;

CREATE OR REPLACE FUNCTION ListAllConditions
  RETURN ConditionInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT m.CONDITION
    FROM HOSPITAL.MEDICAL_HISTORY m
  ) LOOP
    PIPE ROW (ConditionInfoRow(rec.CONDITION));
  END LOOP;
  RETURN;
END ListAllConditions;

-- Query to retrieve all unique conditions
SELECT * FROM TABLE(ListAllConditions);

-- 13)
-- Get all types of Blood
-- Type for blood type information
CREATE OR REPLACE TYPE BloodTypeInfoRow AS OBJECT (
  BLOOD_TYPE VARCHAR2(3)
);

CREATE OR REPLACE TYPE BloodTypeInfoTable IS TABLE OF BloodTypeInfoRow;

CREATE OR REPLACE FUNCTION ListAllBloodTypes
  RETURN BloodTypeInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT p.BLOOD_TYPE
    FROM HOSPITAL.PATIENT p
  ) LOOP
    PIPE ROW (BloodTypeInfoRow(rec.BLOOD_TYPE));
  END LOOP;
  RETURN;
END ListAllBloodTypes;

-- Query to retrieve all unique blood types
SELECT * FROM TABLE(ListAllBloodTypes);

-- 14)
-- Returns all patients with medical history records on a date, including the condition. 
-- Type for patient information with medical history
CREATE OR REPLACE TYPE PatientMedicalHistoryRow AS OBJECT (
  IDPATIENT NUMBER,
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE,
  CONDITION VARCHAR2(45)
);

CREATE OR REPLACE TYPE PatientMedicalHistoryTable IS TABLE OF PatientMedicalHistoryRow;

CREATE OR REPLACE FUNCTION ListPatientsByMedicalHistoryDate(target_date IN DATE)
  RETURN PatientMedicalHistoryTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY, mh.CONDITION
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.MEDICAL_HISTORY mh ON p.IDPATIENT = mh.IDPATIENT
    WHERE mh.RECORD_DATE = target_date
  ) LOOP
    PIPE ROW (PatientMedicalHistoryRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY, rec.CONDITION
    ));
  END LOOP;
  RETURN;
END ListPatientsByMedicalHistoryDate;

-- Query to retrieve all patients with medical history on a specific date
SELECT * FROM TABLE(ListPatientsByMedicalHistoryDate(TO_DATE('23.01.15', 'YY.MM.DD')));

-- 15)
-- All the patients that have a spectific insurance provider
-- Type for patient information with insurance provider
CREATE OR REPLACE TYPE PatientInsuranceRow AS OBJECT (
  IDPATIENT NUMBER,
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE,
  INSURANCE_PROVIDER VARCHAR2(45)
);

CREATE OR REPLACE TYPE PatientInsuranceTable IS TABLE OF PatientInsuranceRow;

CREATE OR REPLACE FUNCTION ListPatientsByInsuranceProvider(provider_name IN VARCHAR2)
  RETURN PatientInsuranceTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY, i.PROVIDER AS INSURANCE_PROVIDER
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.PROVIDER = provider_name
  ) LOOP
    PIPE ROW (PatientInsuranceRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY, rec.INSURANCE_PROVIDER
    ));
  END LOOP;
  RETURN;
END ListPatientsByInsuranceProvider;

-- Query to retrieve all patients with a specific insurance provider
SELECT * FROM TABLE(ListPatientsByInsuranceProvider('DEF Insurance'));

-- 16)
-- All the patients that have a spectific insurance plan
-- Type for patient information with insurance plan
CREATE OR REPLACE TYPE PatientInsurance_PlanRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE,
  INSURANCE_PLAN VARCHAR2(45)
);

CREATE OR REPLACE TYPE PatientInsurance_PlanTable IS TABLE OF PatientInsurance_PlanRow;

CREATE OR REPLACE FUNCTION ListPatientsByInsurancePlan(plan_name IN VARCHAR2)
  RETURN PatientInsurance_PlanTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY, i.INSURANCE_PLAN
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.INSURANCE_PLAN = plan_name
  ) LOOP
    PIPE ROW (PatientInsurance_PlanRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY, rec.INSURANCE_PLAN
    ));
  END LOOP;
  RETURN;
END ListPatientsByInsurancePlan;

-- Query to retrieve all patients with a specific insurance plan
SELECT * FROM TABLE(ListPatientsByInsurancePlan('Standard Plan'));


-- 17)
-- All the patients that have a spectific coverage
-- Type for patient information with coverage
CREATE OR REPLACE TYPE PatientCoverageRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE,
  COVERAGE VARCHAR2(20)
);

CREATE OR REPLACE TYPE PatientCoverageTable IS TABLE OF PatientCoverageRow;

CREATE OR REPLACE FUNCTION ListPatientsByCoverage(coverage_name IN VARCHAR2)
  RETURN PatientCoverageTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY, i.COVERAGE
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.COVERAGE = coverage_name
  ) LOOP
    PIPE ROW (PatientCoverageRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY, rec.COVERAGE
    ));
  END LOOP;
  RETURN;
END ListPatientsByCoverage;

-- Query to retrieve all patients with a specific coverage
SELECT * FROM TABLE(ListPatientsByCoverage('Full Coverage'));

-- 18)
-- ListPatientsByAgeRange: Retrieve all patients within a specified age range.
-- Type for patient information with age range
CREATE OR REPLACE TYPE PatientAgeRangeRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE
);

CREATE OR REPLACE TYPE PatientAgeRangeTable IS TABLE OF PatientAgeRangeRow;

CREATE OR REPLACE FUNCTION ListPatientsByAgeRange(min_age IN NUMBER, max_age IN NUMBER)
  RETURN PatientAgeRangeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, p.BIRTHDAY) / 12) BETWEEN min_age AND max_age
  ) LOOP
    PIPE ROW (PatientAgeRangeRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    ));
  END LOOP;
  RETURN;
END ListPatientsByAgeRange;

-- Query to retrieve all patients within a specified age range
SELECT * FROM TABLE(ListPatientsByAgeRange(30, 40));

-- ListPatientsWithMaternityCoverage: Retrieve all patients who have maternity coverage in their insurance plan.
-- Type for patient information with maternity coverage
CREATE OR REPLACE TYPE PatientMaternityCoverageRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE
);

CREATE OR REPLACE TYPE PatientMaternityCoverageTable IS TABLE OF PatientMaternityCoverageRow;

CREATE OR REPLACE FUNCTION ListPatientsWithMaternityCoverage
  RETURN PatientMaternityCoverageTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.MATERNITY = 'Y'
  ) LOOP
    PIPE ROW (PatientMaternityCoverageRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    ));
  END LOOP;
  RETURN;
END ListPatientsWithMaternityCoverage;

-- Query to retrieve all patients with maternity coverage
SELECT * FROM TABLE(ListPatientsWithMaternityCoverage);

-- ListPatientsWithDentalCoverage: Retrieve all patients who have dental coverage in their insurance plan.
-- Type for patient information with dental coverage
CREATE OR REPLACE TYPE PatientDentalCoverageRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE
);

CREATE OR REPLACE TYPE PatientDentalCoverageTable IS TABLE OF PatientDentalCoverageRow;

CREATE OR REPLACE FUNCTION ListPatientsWithDentalCoverage
  RETURN PatientDentalCoverageTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.DENTAL = 'Y'
  ) LOOP
    PIPE ROW (PatientDentalCoverageRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    ));
  END LOOP;
  RETURN;
END ListPatientsWithDentalCoverage;

-- Query to retrieve all patients with dental coverage
SELECT * FROM TABLE(ListPatientsWithDentalCoverage);

-- ListPatientsWithOpticalCoverage: Retrieve all patients who have optical coverage in their insurance plan.
-- Type for patient information with optical coverage
CREATE OR REPLACE TYPE PatientOpticalCoverageRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_FNAME VARCHAR2(45),
  PATIENT_LNAME VARCHAR2(45),
  BLOOD_TYPE VARCHAR2(3),
  PHONE VARCHAR2(12),
  EMAIL VARCHAR2(50),
  GENDER VARCHAR2(10),
  POLICY_NUMBER VARCHAR2(45),
  BIRTHDAY DATE
);

CREATE OR REPLACE TYPE PatientOpticalCoverageTable IS TABLE OF PatientOpticalCoverageRow;

CREATE OR REPLACE FUNCTION ListPatientsWithOpticalCoverage
  RETURN PatientOpticalCoverageTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.OPTICAL = 'Y'
  ) LOOP
    PIPE ROW (PatientOpticalCoverageRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    ));
  END LOOP;
  RETURN;
END ListPatientsWithOpticalCoverage;

-- Query to retrieve all patients with optical coverage
SELECT * FROM TABLE(ListPatientsWithOpticalCoverage);