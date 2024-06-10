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

-- 1)
-- Insert Pacient, Insursance, Emergency Contact and Medical History
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDPATIENT value
    SELECT COALESCE(MAX(IDPATIENT), 0) INTO max_id FROM Hospital.PATIENT;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE patient_seq_new';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                RAISE;
            END IF;
    END;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE patient_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_patient (
    p_patient_fname VARCHAR2,
    p_patient_lname VARCHAR2,
    p_blood_type    VARCHAR2,
    p_phone         VARCHAR2,
    p_email         VARCHAR2,
    p_gender        VARCHAR2,
    p_birthday      DATE,
    p_policy_number VARCHAR2,
    p_condition     VARCHAR2,
    p_record_date   DATE,
    p_contact_name  VARCHAR2,
    p_contact_phone VARCHAR2,
    p_contact_relation VARCHAR2,
    p_provider      VARCHAR2,
    p_insurance_plan VARCHAR2,
    p_co_pay        NUMBER,
    p_coverage      VARCHAR2,
    p_maternity     CHAR,
    p_dental        CHAR,
    p_optical       CHAR
) IS
    v_idpatient NUMBER;
BEGIN
    -- Insert patient and get the new IDPATIENT
    INSERT INTO Hospital.PATIENT (
        IDPATIENT, PATIENT_FNAME, PATIENT_LNAME, BLOOD_TYPE, PHONE, EMAIL, GENDER, BIRTHDAY, POLICY_NUMBER
    )
    VALUES (
        patient_seq_new.NEXTVAL, p_patient_fname, p_patient_lname, p_blood_type, p_phone, p_email, p_gender, p_birthday, p_policy_number
    )
    RETURNING IDPATIENT INTO v_idpatient;

    -- Insert into medical_history
    INSERT INTO Hospital.MEDICAL_HISTORY (
        RECORD_ID, CONDITION, RECORD_DATE, IDPATIENT
    )
    VALUES (
        patient_seq_new.NEXTVAL, p_condition, p_record_date, v_idpatient
    );

    -- Insert into insurance
    INSERT INTO Hospital.INSURANCE (
        POLICY_NUMBER, PROVIDER, INSURANCE_PLAN, CO_PAY, COVERAGE, MATERNITY, DENTAL, OPTICAL
    )
    VALUES (
        p_policy_number, p_provider, p_insurance_plan, p_co_pay, p_coverage, p_maternity, p_dental, p_optical
    );

    -- Insert into emergency_contact
    INSERT INTO Hospital.EMERGENCY_CONTACT (
        CONTACT_NAME, PHONE, RELATION, IDPATIENT
    )
    VALUES (
        p_contact_name, p_contact_phone, p_contact_relation, v_idpatient
    );

    DBMS_OUTPUT.PUT_LINE('Patient and related records inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE TABLE Hospital.New_Patient_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    patient_fname VARCHAR2(45),
    patient_lname VARCHAR2(45),
    blood_type    VARCHAR2(3),
    phone         VARCHAR2(12),
    email         VARCHAR2(50),
    gender        VARCHAR2(10),
    birthday      DATE,
    policy_number VARCHAR2(45),
    condition     VARCHAR2(45),
    record_date   DATE,
    contact_name  VARCHAR2(45),
    contact_phone VARCHAR2(30),
    contact_relation VARCHAR2(45),
    provider      VARCHAR2(45),
    insurance_plan VARCHAR2(45),
    co_pay        NUMBER,
    coverage      VARCHAR2(20),
    maternity     CHAR(1),
    dental        CHAR(1),
    optical       CHAR(1)
);

-- Trigger to Insert a Patient
CREATE OR REPLACE TRIGGER trg_insert_patient
AFTER INSERT ON Hospital.New_Patient_Requests
FOR EACH ROW
BEGIN
    insert_patient(
        :NEW.patient_fname,
        :NEW.patient_lname,
        :NEW.blood_type,
        :NEW.phone,
        :NEW.email,
        :NEW.gender,
        :NEW.birthday,
        :NEW.policy_number,
        :NEW.condition,
        :NEW.record_date,
        :NEW.contact_name,
        :NEW.contact_phone,
        :NEW.contact_relation,
        :NEW.provider,
        :NEW.insurance_plan,
        :NEW.co_pay,
        :NEW.coverage,
        :NEW.maternity,
        :NEW.dental,
        :NEW.optical
    );
END;

INSERT INTO Hospital.New_Patient_Requests (
    patient_fname, patient_lname, blood_type, phone, email, gender, birthday, policy_number,
    condition, record_date, contact_name, contact_phone, contact_relation,
    provider, insurance_plan, co_pay, coverage, maternity, dental, optical
) VALUES (
    'Francisco', 'Claudino', 'O+', '123.456.7890', 'claudino@example.com', 'Male', TO_DATE('1980-01-01', 'YYYY-MM-DD'), 'POL123456',
    'Hypertension', TO_DATE('2023-06-01', 'YYYY-MM-DD'), 'Jane Doe', '123.456.7890', 'Spouse',
    'InsuranceCo', 'PlanA', 100, 'Full', 'Y', 'N', 'Y'
);

---------------------------------------------------------------------------------------------------------------

-- UPDATES


-- 1)
-- Update a Patient
CREATE OR REPLACE PROCEDURE update_patient (
    p_idpatient     IN NUMBER,
    p_patient_fname IN VARCHAR2,
    p_patient_lname IN VARCHAR2,
    p_blood_type    IN VARCHAR2,
    p_phone         IN VARCHAR2,
    p_email         IN VARCHAR2,
    p_gender        IN VARCHAR2,
    p_birthday      IN DATE,
    p_policy_number IN VARCHAR2
) IS
BEGIN
    UPDATE Hospital.PATIENT
    SET patient_fname = p_patient_fname,
        patient_lname = p_patient_lname,
        blood_type    = p_blood_type,
        phone         = p_phone,
        email         = p_email,
        gender        = p_gender,
        birthday      = p_birthday,
        policy_number = p_policy_number
    WHERE idpatient = p_idpatient;

    DBMS_OUTPUT.PUT_LINE('Patient record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Triger for Update Patient
CREATE OR REPLACE TRIGGER trg_update_patient
BEFORE UPDATE ON Hospital.PATIENT
FOR EACH ROW
BEGIN
    update_patient(
        p_idpatient     => :OLD.idpatient,
        p_patient_fname => :NEW.patient_fname,
        p_patient_lname => :NEW.patient_lname,
        p_blood_type    => :NEW.blood_type,
        p_phone         => :NEW.phone,
        p_email         => :NEW.email,
        p_gender        => :NEW.gender,
        p_birthday      => :NEW.birthday,
        p_policy_number => :NEW.policy_number
    );
END;

-- Update the patient information
BEGIN
    UPDATE Hospital.PATIENT
    SET patient_fname = 'Francisco Updated',
        patient_lname = 'Claudino Updated',
        blood_type = 'A+',
        phone = '987.654.3210',
        email = 'updated_claudino@example.com',
        gender = 'Male',
        birthday = TO_DATE('1981-01-01', 'YYYY-MM-DD'),
        policy_number = 'POL010'
    WHERE idpatient = 543;
END;

-- 2)
-- Update the Medical History
CREATE OR REPLACE PROCEDURE update_medical_history (
    p_record_id   IN NUMBER,
    p_condition   IN VARCHAR2,
    p_record_date IN DATE,
    p_idpatient   IN NUMBER
) IS
BEGIN
    UPDATE Hospital.MEDICAL_HISTORY
    SET condition = p_condition,
        record_date = p_record_date,
        idpatient = p_idpatient
    WHERE record_id = p_record_id;

    DBMS_OUTPUT.PUT_LINE('Medical history record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Triger for Update Medical History
CREATE OR REPLACE TRIGGER trg_update_medical_history
BEFORE UPDATE ON Hospital.MEDICAL_HISTORY
FOR EACH ROW
BEGIN
    update_medical_history(
        p_record_id   => :OLD.record_id,
        p_condition   => :NEW.condition,
        p_record_date => :NEW.record_date,
        p_idpatient   => :NEW.idpatient
    );
END;

-- Update the medical history record
BEGIN
    UPDATE Hospital.MEDICAL_HISTORY
    SET condition = 'Updated Condition',
        record_date = TO_DATE('2023-07-01', 'YYYY-MM-DD'),
        idpatient = 543
    WHERE record_id = 1001;
END;

-- 3)
-- Update the Insurance
CREATE OR REPLACE PROCEDURE update_insurance (
    p_policy_number  IN VARCHAR2,
    p_provider       IN VARCHAR2,
    p_insurance_plan IN VARCHAR2,
    p_co_pay         IN NUMBER,
    p_coverage       IN VARCHAR2,
    p_maternity      IN CHAR,
    p_dental         IN CHAR,
    p_optical        IN CHAR
) IS
BEGIN
    UPDATE Hospital.INSURANCE
    SET provider = p_provider,
        insurance_plan = p_insurance_plan,
        co_pay = p_co_pay,
        coverage = p_coverage,
        maternity = p_maternity,
        dental = p_dental,
        optical = p_optical
    WHERE policy_number = p_policy_number;

    DBMS_OUTPUT.PUT_LINE('Insurance record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE OR REPLACE TRIGGER trg_update_insurance
BEFORE UPDATE ON Hospital.INSURANCE
FOR EACH ROW
BEGIN
    update_insurance(
        p_policy_number  => :OLD.policy_number,
        p_provider       => :NEW.provider,
        p_insurance_plan => :NEW.insurance_plan,
        p_co_pay         => :NEW.co_pay,
        p_coverage       => :NEW.coverage,
        p_maternity      => :NEW.maternity,
        p_dental         => :NEW.dental,
        p_optical        => :NEW.optical
    );
END;

-- Update the insurance information
BEGIN
    UPDATE Hospital.INSURANCE
    SET provider = 'Updated InsuranceCo',
        insurance_plan = 'Updated Plan',
        co_pay = 200,
        coverage = 'Partial',
        maternity = 'N',
        dental = 'Y',
        optical = 'N'
    WHERE policy_number = 'POL123456';
END;

-- 4)
-- Update the Emergency Contact
CREATE OR REPLACE PROCEDURE update_emergency_contact (
    p_contact_name  IN VARCHAR2,
    p_phone         IN VARCHAR2,
    p_relation      IN VARCHAR2,
    p_idpatient     IN NUMBER,
    p_old_phone     IN VARCHAR2 -- To identify the old record for update
) IS
BEGIN
    UPDATE Hospital.EMERGENCY_CONTACT
    SET contact_name = p_contact_name,
        phone = p_phone,
        relation = p_relation,
        idpatient = p_idpatient
    WHERE idpatient = p_idpatient AND phone = p_old_phone;

    DBMS_OUTPUT.PUT_LINE('Emergency contact record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Emergency Contact
CREATE OR REPLACE TRIGGER trg_update_emergency_contact
BEFORE UPDATE ON Hospital.EMERGENCY_CONTACT
FOR EACH ROW
BEGIN
    update_emergency_contact(
        p_contact_name => :NEW.contact_name,
        p_phone        => :NEW.phone,
        p_relation     => :NEW.relation,
        p_idpatient    => :NEW.idpatient,
        p_old_phone    => :OLD.phone
    );
END;

-- Update the emergency contact information
BEGIN
    UPDATE Hospital.EMERGENCY_CONTACT
    SET contact_name = 'Jane Doe Updated',
        phone = '987.654.3210',
        relation = 'Updated Spouse',
        idpatient = 543
    WHERE idpatient = 543 AND phone = '123.456.7890';
END;

---------------------------------------------------------------------------------------------------------------

-- DELETES

-- 1)
-- Delete Pacient, Insursance, Emergency Contact and Medical History
CREATE OR REPLACE PROCEDURE delete_patient_and_related (
    p_idpatient IN NUMBER
) IS
BEGIN
    -- Delete from the Medical History table
    DELETE FROM Hospital.MEDICAL_HISTORY
    WHERE idpatient = p_idpatient;

    -- Delete from the Emergency Contact table
    DELETE FROM Hospital.EMERGENCY_CONTACT
    WHERE idpatient = p_idpatient;

    -- Delete from the Insurance table
    DELETE FROM Hospital.INSURANCE
    WHERE policy_number = (SELECT policy_number FROM Hospital.PATIENT WHERE idpatient = p_idpatient);

    -- Set patient_idpatient in the Episode table to 0
    UPDATE Hospital.EPISODE
    SET patient_idpatient = 0
    WHERE patient_idpatient = p_idpatient;

    -- Delete from the Patient table
    DELETE FROM Hospital.PATIENT
    WHERE idpatient = p_idpatient;

    DBMS_OUTPUT.PUT_LINE('Patient and related records deleted successfully, patient_id set to 0 in episode.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete a Patient
CREATE OR REPLACE TRIGGER trg_delete_patient_and_related
BEFORE DELETE ON Hospital.PATIENT
FOR EACH ROW
BEGIN
    delete_patient_and_related(:OLD.idpatient);
END;

DELETE FROM Hospital.PATIENT WHERE idpatient = 543;