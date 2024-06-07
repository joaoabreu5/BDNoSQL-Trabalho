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

CREATE OR REPLACE PROCEDURE ListAllRelationsProc (relations OUT RelationTypeTable) IS
BEGIN
  relations := RelationTypeTable();
  FOR rec IN (
    SELECT DISTINCT e.RELATION
    FROM HOSPITAL.EMERGENCY_CONTACT e
  ) LOOP
    relations.EXTEND;
    relations(relations.COUNT) := RelationTypeRow(rec.RELATION);
  END LOOP;
END ListAllRelationsProc;

DECLARE
  relations RelationTypeTable;
BEGIN
  ListAllRelationsProc(relations);
  FOR i IN 1..relations.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('RELATION: ' || relations(i).RELATION);
  END LOOP;
END;

-- 10)
-- Get all types of Providers
CREATE OR REPLACE TYPE ProviderInfoRow AS OBJECT (
  PROVIDER VARCHAR2(45)
);

CREATE OR REPLACE TYPE ProviderInfoTable IS TABLE OF ProviderInfoRow;

CREATE OR REPLACE PROCEDURE ListAllProvidersProc (providers OUT ProviderInfoTable) IS
BEGIN
  providers := ProviderInfoTable(); -- Initialize the collection
  FOR rec IN (
    SELECT DISTINCT i.PROVIDER
    FROM HOSPITAL.INSURANCE i
  ) LOOP
    providers.EXTEND;
    providers(providers.COUNT) := ProviderInfoRow(rec.PROVIDER);
  END LOOP;
END ListAllProvidersProc;

DECLARE
  providers ProviderInfoTable;
BEGIN
  ListAllProvidersProc(providers);
  FOR i IN 1..providers.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('PROVIDER: ' || providers(i).PROVIDER);
  END LOOP;
END;

-- 11)
-- Get all types of InsurancePlans
CREATE OR REPLACE TYPE InsurancePlanInfoRow AS OBJECT (
  INSURANCE_PLAN VARCHAR2(45)
);

CREATE OR REPLACE TYPE InsurancePlanInfoTable IS TABLE OF InsurancePlanInfoRow;

CREATE OR REPLACE PROCEDURE ListAllInsurancePlansProc (plans OUT InsurancePlanInfoTable) IS
BEGIN
  plans := InsurancePlanInfoTable(); -- Initialize the collection
  FOR rec IN (
    SELECT DISTINCT i.INSURANCE_PLAN
    FROM HOSPITAL.INSURANCE i
  ) LOOP
    plans.EXTEND;
    plans(plans.COUNT) := InsurancePlanInfoRow(rec.INSURANCE_PLAN);
  END LOOP;
END ListAllInsurancePlansProc;

DECLARE
  plans InsurancePlanInfoTable;
BEGIN
  ListAllInsurancePlansProc(plans);
  FOR i IN 1..plans.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('INSURANCE_PLAN: ' || plans(i).INSURANCE_PLAN);
  END LOOP;
END;

-- 12)
-- Get all types of Coverage
CREATE OR REPLACE TYPE CoverageInfoRow AS OBJECT (
  COVERAGE VARCHAR2(20)
);

CREATE OR REPLACE TYPE CoverageInfoTable IS TABLE OF CoverageInfoRow;

CREATE OR REPLACE PROCEDURE ListAllCoveragesProc (coverages OUT CoverageInfoTable) IS
BEGIN
  coverages := CoverageInfoTable();
  FOR rec IN (
    SELECT DISTINCT i.COVERAGE
    FROM HOSPITAL.INSURANCE i
  ) LOOP
    coverages.EXTEND;
    coverages(coverages.COUNT) := CoverageInfoRow(rec.COVERAGE);
  END LOOP;
END ListAllCoveragesProc;

DECLARE
  coverages CoverageInfoTable;
BEGIN
  ListAllCoveragesProc(coverages);
  FOR i IN 1..coverages.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('COVERAGE: ' || coverages(i).COVERAGE);
  END LOOP;
END;

-- 12)
-- Get all types of Conditions
CREATE OR REPLACE TYPE ConditionInfoRow AS OBJECT (
  CONDITION VARCHAR2(45)
);

CREATE OR REPLACE TYPE ConditionInfoTable IS TABLE OF ConditionInfoRow;

CREATE OR REPLACE PROCEDURE ListAllConditionsProc (conditions OUT ConditionInfoTable) IS
BEGIN
  conditions := ConditionInfoTable();
  FOR rec IN (
    SELECT DISTINCT m.CONDITION
    FROM HOSPITAL.MEDICAL_HISTORY m
  ) LOOP
    conditions.EXTEND;
    conditions(conditions.COUNT) := ConditionInfoRow(rec.CONDITION);
  END LOOP;
END ListAllConditionsProc;

DECLARE
  conditions ConditionInfoTable;
BEGIN
  ListAllConditionsProc(conditions);
  FOR i IN 1..conditions.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('CONDITION: ' || conditions(i).CONDITION);
  END LOOP;
END;

-- 13)
-- Get all types of Blood
CREATE OR REPLACE TYPE BloodTypeInfoRow AS OBJECT (
  BLOOD_TYPE VARCHAR2(3)
);

CREATE OR REPLACE TYPE BloodTypeInfoTable IS TABLE OF BloodTypeInfoRow;

CREATE OR REPLACE PROCEDURE ListAllBloodTypesProc (blood_types OUT BloodTypeInfoTable) IS
BEGIN
  blood_types := BloodTypeInfoTable();
  FOR rec IN (
    SELECT DISTINCT p.BLOOD_TYPE
    FROM HOSPITAL.PATIENT p
  ) LOOP
    blood_types.EXTEND;
    blood_types(blood_types.COUNT) := BloodTypeInfoRow(rec.BLOOD_TYPE);
  END LOOP;
END ListAllBloodTypesProc;

DECLARE
  blood_types BloodTypeInfoTable;
BEGIN
  ListAllBloodTypesProc(blood_types);
  FOR i IN 1..blood_types.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('BLOOD_TYPE: ' || blood_types(i).BLOOD_TYPE);
  END LOOP;
END;

-- 14)
-- Returns all patients with medical history records on a date, including the condition. 
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

SELECT * FROM TABLE(ListPatientsByMedicalHistoryDate(TO_DATE('23.01.15', 'YY.MM.DD')));

-- 15)
-- All the patients that have a spectific insurance provider
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

SELECT * FROM TABLE(ListPatientsByInsuranceProvider('DEF Insurance'));

-- 16)
-- All the patients that have a spectific insurance plan
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

SELECT * FROM TABLE(ListPatientsByInsurancePlan('Standard Plan'));

-- 17)
-- All the patients that have a spectific coverage
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

SELECT * FROM TABLE(ListPatientsByCoverage('Full Coverage'));

-- 18)
-- ListPatientsByAgeRange: Retrieve all patients within a specified age range.
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

SELECT * FROM TABLE(ListPatientsByAgeRange(30, 40));

-- 19)
-- ListPatientsWithMaternityCoverage: Retrieve all patients who have maternity coverage in their insurance plan.
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

CREATE OR REPLACE PROCEDURE ListPatientsWithMaternityCoverageProc (patients OUT PatientMaternityCoverageTable) IS
BEGIN
  patients := PatientMaternityCoverageTable();
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.MATERNITY = 'Y'
  ) LOOP
    patients.EXTEND;
    patients(patients.COUNT) := PatientMaternityCoverageRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    );
  END LOOP;
END ListPatientsWithMaternityCoverageProc;

DECLARE
  patients PatientMaternityCoverageTable;
BEGIN
  ListPatientsWithMaternityCoverageProc(patients);
  FOR i IN 1..patients.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('IDPATIENT: ' || patients(i).IDPATIENT ||
                         ', PATIENT_FNAME: ' || patients(i).PATIENT_FNAME ||
                         ', PATIENT_LNAME: ' || patients(i).PATIENT_LNAME ||
                         ', BLOOD_TYPE: ' || patients(i).BLOOD_TYPE ||
                         ', PHONE: ' || patients(i).PHONE ||
                         ', EMAIL: ' || patients(i).EMAIL ||
                         ', GENDER: ' || patients(i).GENDER ||
                         ', POLICY_NUMBER: ' || patients(i).POLICY_NUMBER ||
                         ', BIRTHDAY: ' || patients(i).BIRTHDAY);
  END LOOP;
END;

-- 20)
-- ListPatientsWithDentalCoverage: Retrieve all patients who have dental coverage in their insurance plan.
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

SELECT * FROM TABLE(ListPatientsWithDentalCoverage);

-- 21)
-- ListPatientsWithOpticalCoverage: Retrieve all patients who have optical coverage in their insurance plan.
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

CREATE OR REPLACE PROCEDURE ListPatientsWithOpticalCoverageProc (patients OUT PatientOpticalCoverageTable) IS
BEGIN
  patients := PatientOpticalCoverageTable();
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME, p.PATIENT_LNAME, p.BLOOD_TYPE, p.PHONE,
           p.EMAIL, p.GENDER, p.POLICY_NUMBER, p.BIRTHDAY
    FROM HOSPITAL.PATIENT p
    JOIN HOSPITAL.INSURANCE i ON p.POLICY_NUMBER = i.POLICY_NUMBER
    WHERE i.OPTICAL = 'Y'
  ) LOOP
    patients.EXTEND;
    patients(patients.COUNT) := PatientOpticalCoverageRow(
      rec.IDPATIENT, rec.PATIENT_FNAME, rec.PATIENT_LNAME, rec.BLOOD_TYPE, rec.PHONE,
      rec.EMAIL, rec.GENDER, rec.POLICY_NUMBER, rec.BIRTHDAY
    );
  END LOOP;
END ListPatientsWithOpticalCoverageProc;

DECLARE
  patients PatientOpticalCoverageTable;
BEGIN
  ListPatientsWithOpticalCoverageProc(patients);
  FOR i IN 1..patients.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('IDPATIENT: ' || patients(i).IDPATIENT ||
                         ', PATIENT_FNAME: ' || patients(i).PATIENT_FNAME ||
                         ', PATIENT_LNAME: ' || patients(i).PATIENT_LNAME ||
                         ', BLOOD_TYPE: ' || patients(i).BLOOD_TYPE ||
                         ', PHONE: ' || patients(i).PHONE ||
                         ', EMAIL: ' || patients(i).EMAIL ||
                         ', GENDER: ' || patients(i).GENDER ||
                         ', POLICY_NUMBER: ' || patients(i).POLICY_NUMBER ||
                         ', BIRTHDAY: ' || patients(i).BIRTHDAY);
  END LOOP;
END;

-- 22)
-- Number of Patients per Blood Type
CREATE OR REPLACE TYPE BloodTypePatientCountRow AS OBJECT (
    BLOOD_TYPE VARCHAR2(3),
    PATIENT_COUNT NUMBER
);

CREATE OR REPLACE TYPE BloodTypePatientCountTable IS TABLE OF BloodTypePatientCountRow;

CREATE OR REPLACE PROCEDURE GetPatientCountPerBloodTypeProc (blood_type_counts OUT BloodTypePatientCountTable) IS
BEGIN
  blood_type_counts := BloodTypePatientCountTable();
  FOR rec IN (
    SELECT p.BLOOD_TYPE, COUNT(*) AS PATIENT_COUNT
    FROM Hospital.Patient p
    GROUP BY p.BLOOD_TYPE
  ) LOOP
    blood_type_counts.EXTEND;
    blood_type_counts(blood_type_counts.COUNT) := BloodTypePatientCountRow(
      rec.BLOOD_TYPE, rec.PATIENT_COUNT
    );
  END LOOP;
END GetPatientCountPerBloodTypeProc;

DECLARE
  blood_type_counts BloodTypePatientCountTable;
BEGIN
  GetPatientCountPerBloodTypeProc(blood_type_counts);
  FOR i IN 1..blood_type_counts.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('BLOOD_TYPE: ' || blood_type_counts(i).BLOOD_TYPE ||
                         ', PATIENT_COUNT: ' || blood_type_counts(i).PATIENT_COUNT);
  END LOOP;
END;

-- 23)
-- Number of Patients per Condition
CREATE OR REPLACE TYPE ConditionPatientCountRow AS OBJECT (
    CONDITION VARCHAR2(45),
    PATIENT_COUNT NUMBER
);

CREATE OR REPLACE TYPE ConditionPatientCountTable IS TABLE OF ConditionPatientCountRow;

CREATE OR REPLACE PROCEDURE GetPatientCountPerConditionProc (condition_counts OUT ConditionPatientCountTable) IS
BEGIN
  condition_counts := ConditionPatientCountTable();
  FOR rec IN (
    SELECT m.CONDITION, COUNT(*) AS PATIENT_COUNT
    FROM Hospital.Medical_History m
    GROUP BY m.CONDITION
  ) LOOP
    condition_counts.EXTEND;
    condition_counts(condition_counts.COUNT) := ConditionPatientCountRow(
      rec.CONDITION, rec.PATIENT_COUNT
    );
  END LOOP;
END GetPatientCountPerConditionProc;

DECLARE
  condition_counts ConditionPatientCountTable;
BEGIN
  GetPatientCountPerConditionProc(condition_counts);
  FOR i IN 1..condition_counts.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('CONDITION: ' || condition_counts(i).CONDITION ||
                         ', PATIENT_COUNT: ' || condition_counts(i).PATIENT_COUNT);
  END LOOP;
END;

---------------------------------------------------------------------------------------------------------------

-- INSERTS

-- Insert Pacient
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDPATIENT value
    SELECT COALESCE(MAX(IDPATIENT), 0) INTO max_id FROM HOSPITAL.PATIENT;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE patient_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_hospital_patient_new2 (
    p_patient_fname VARCHAR2,
    p_patient_lname VARCHAR2,
    p_blood_type VARCHAR2,
    p_email VARCHAR2,
    p_phone VARCHAR2,
    p_gender VARCHAR2,
    p_policy_number VARCHAR2,
    p_birthday VARCHAR2
) IS
BEGIN
    INSERT INTO HOSPITAL.PATIENT (
        IDPATIENT, PATIENT_FNAME, PATIENT_LNAME, BLOOD_TYPE, EMAIL, PHONE, GENDER, POLICY_NUMBER, BIRTHDAY
    )
    VALUES (
        patient_seq_new.NEXTVAL, p_patient_fname, p_patient_lname, p_blood_type, p_email, p_phone, p_gender, p_policy_number, TO_DATE(p_birthday, 'YY.MM.DD')
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into HOSPITAL.PATIENT');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_hospital_patient_new2(
        'Francisco', 'Claudino', 'O+', 'claudino@gmail.com', '123-456-7892', 'Male', 'POL005', '85.07.15'
    );
END;

-- Insert Medical_History
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum RECORD_ID value
    SELECT COALESCE(MAX(RECORD_ID), 0) INTO max_id FROM HOSPITAL.MEDICAL_HISTORY;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE medical_history_seq START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_hospital_medical_history_new (
    p_condition VARCHAR2,
    p_record_date VARCHAR2,
    p_idpatient NUMBER
) IS
BEGIN
    INSERT INTO HOSPITAL.MEDICAL_HISTORY (
        RECORD_ID, CONDITION, RECORD_DATE, IDPATIENT
    )
    VALUES (
        medical_history_seq.NEXTVAL, p_condition, TO_DATE(p_record_date, 'YY.MM.DD'), p_idpatient
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into HOSPITAL_MEDICAL_HISTORY');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_hospital_medical_history_new(
        'Diabetes', '24.05.15', 91
    );
END;

-- Insert Insurance
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum numeric value for POLICY_NUMBER
    SELECT COALESCE(MAX(TO_NUMBER(SUBSTR(POLICY_NUMBER, 4))), 0) INTO max_id FROM HOSPITAL.INSURANCE;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE insurance_seq_new START WITH ' || (max_id + 2) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_hospital_insurance_new (
    p_provider VARCHAR2,
    p_insurance_plan VARCHAR2,
    p_co_pay NUMBER,
    p_coverage VARCHAR2,
    p_maternity CHAR,
    p_dental CHAR,
    p_optical CHAR
) IS
    v_policy_number VARCHAR2(10);
BEGIN
    -- Generate a new POLICY_NUMBER using the sequence
    v_policy_number := 'POL' || TO_CHAR(insurance_seq_new.NEXTVAL, 'FM000');

    INSERT INTO HOSPITAL.INSURANCE (
        POLICY_NUMBER, PROVIDER, INSURANCE_PLAN, CO_PAY, COVERAGE, MATERNITY, DENTAL, OPTICAL
    )
    VALUES (
        v_policy_number, p_provider, p_insurance_plan, p_co_pay, p_coverage, p_maternity, p_dental, p_optical
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into HOSPITAL_INSURANCE with POLICY_NUMBER ' || v_policy_number);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_hospital_insurance_new(
        'LLL Insurance', 'Premium Plan', 30, 'Partial Coverage', 'Y', 'Y', 'N'
    );
END;

-- Insert EmergencyContact
CREATE OR REPLACE PROCEDURE insert_emergency_contact_new (
    p_contact_name VARCHAR2,
    p_phone VARCHAR2,
    p_relation VARCHAR2,
    p_idpatient NUMBER
) IS
BEGIN
    INSERT INTO HOSPITAL.EMERGENCY_CONTACT (
        CONTACT_NAME, PHONE, RELATION, IDPATIENT
    )
    VALUES (
        p_contact_name, p_phone, p_relation, p_idpatient
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into HOSPITAL.EMERGENCY_CONTACT');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM || ' at ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;

BEGIN
    insert_emergency_contact_new(
        'Afonso Miguel', '444-555-7777', 'Brother', 91
    );
END;

---------------------------------------------------------------------------------------------------------------

-- UPDATES


---------------------------------------------------------------------------------------------------------------

-- DELETES

