-- VISION PATIENT
-- 1) 
-- Find all patients with a particular medical condition:

-- SELECT *
-- FROM Patient
-- JOIN Medical_History ON Patient.IDPATIENT = Medical_History.IDPATIENT
-- WHERE Medical_History.CONDITION = 'Flu';

CREATE OR REPLACE TYPE PatientRow AS OBJECT (
  IDPATIENT NUMBER,
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

-- 2)
-- Find all episodes for a given patient including prescriptions:
-- SELECT Episode.*, Prescription.*
-- FROM Episode
-- JOIN Prescription ON Episode.IDEPISODE = Prescription.IDEPISODE
-- WHERE Episode.PATIENT_IDPATIENT = 1;

CREATE OR REPLACE TYPE EpisodePrescriptionRow AS OBJECT (
  IDEPISODE NUMBER,
  PATIENT_IDPATIENT NUMBER,
  IDPRESCRIPTION NUMBER,
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER,
  IDMEDICINE NUMBER
);

CREATE OR REPLACE TYPE EpisodePrescriptionTable IS TABLE OF EpisodePrescriptionRow;

CREATE OR REPLACE FUNCTION GetEpisodesWithPrescriptions(p_patient_id IN NUMBER)
  RETURN EpisodePrescriptionTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT e.IDEPISODE, e.PATIENT_IDPATIENT,
           p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDMEDICINE
    FROM Episode e
    JOIN Prescription p ON e.IDEPISODE = p.IDEPISODE
    WHERE e.PATIENT_IDPATIENT = p_patient_id
  ) LOOP
    PIPE ROW (EpisodePrescriptionRow(rec.IDEPISODE, rec.PATIENT_IDPATIENT,
                                     rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE, rec.IDMEDICINE));
  END LOOP;
  RETURN;
END GetEpisodesWithPrescriptions;

SELECT * FROM TABLE(GetEpisodesWithPrescriptions(1));

-- 3)
-- Find total billing amount for a given episode:
-- SELECT Episode.IDEPISODE, SUM(Bill.TOTAL) AS TotalAmount
-- FROM Episode
-- JOIN Bill ON Episode.IDEPISODE = Bill.IDEPISODE
-- WHERE Episode.IDEPISODE = 2
-- GROUP BY Episode.IDEPISODE;

CREATE OR REPLACE FUNCTION GetTotalBillingForEpisode(p_episode_id IN NUMBER) RETURN VARCHAR2 IS
  v_room_cost NUMBER;
  v_test_cost NUMBER;
  v_other_charges NUMBER;
  v_total NUMBER;
  v_result VARCHAR2(4000);  -- Adjust the size as necessary
BEGIN
  -- Calculate and gather all billing details
  SELECT SUM(ROOM_COST), SUM(TEST_COST), SUM(OTHER_CHARGES), SUM(TOTAL)
  INTO v_room_cost, v_test_cost, v_other_charges, v_total
  FROM Bill
  WHERE IDEPISODE = p_episode_id;

  -- Construct the result string
  v_result := 'Room Cost: ' || NVL(TO_CHAR(v_room_cost), '0') ||
              ', Test Cost: ' || NVL(TO_CHAR(v_test_cost), '0') ||
              ', Other Charges: ' || NVL(TO_CHAR(v_other_charges), '0') ||
              ', Total: ' || NVL(TO_CHAR(v_total), '0');

  -- Return the constructed string
  RETURN v_result;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No billing records found';  -- Return a clear message if no data is found
END GetTotalBillingForEpisode;

SELECT GetTotalBillingForEpisode(1) AS TotalBilling FROM DUAL;

-- 4)
-- Get all the info about pacient (view patient only)
CREATE OR REPLACE TYPE patient_row AS OBJECT (
IDPATIENT    NUMBER(38,0),
PATIENT_FNAME    VARCHAR2(45 BYTE),
PATIENT_LNAME    VARCHAR2(45 BYTE),
BLOOD_TYPE    VARCHAR2(3 BYTE),
PHONE    VARCHAR2(12 BYTE),
EMAIL    VARCHAR2(50 BYTE),
GENDER    VARCHAR2(10 BYTE),
POLICY_NUMBER    VARCHAR2(45 BYTE),
BIRTHDAY    DATE
);

CREATE OR REPLACE TYPE record_row AS OBJECT (
RECORD_ID    NUMBER(38,0),
CONDITION    VARCHAR2(45 BYTE),
RECORD_DATE    DATE,
IDPATIENT    NUMBER(38,0)
);

CREATE OR REPLACE TYPE insurance_row AS OBJECT (
POLICY_NUMBER    VARCHAR2(45 BYTE),
PROVIDERR    VARCHAR2(45 BYTE), -- mais um r para não dar erro
INSURANCE_PLAN    VARCHAR2(45 BYTE),
CO_PAY    NUMBER(10,2),
COVERAGE    VARCHAR2(20 BYTE),
MATERNITY    CHAR(1 BYTE),
DENTAL    CHAR(1 BYTE),
OPTICAL    CHAR(1 BYTE)
);

CREATE OR REPLACE TYPE emergency_contact_row AS OBJECT (
CONTACT_NAME    VARCHAR2(45 BYTE),
PHONE    VARCHAR2(30 BYTE),
RELATION    VARCHAR2(45 BYTE),
IDPATIENT    NUMBER(38,0)
);

CREATE TYPE patient_table IS TABLE OF patient_row;
CREATE TYPE record_table IS TABLE OF record_row;
CREATE TYPE insurance_table IS TABLE OF insurance_row;
CREATE TYPE emergency_contact_table IS TABLE OF emergency_contact_row;

CREATE OR REPLACE TYPE all_patient_details AS OBJECT (
    patient_details patient_table,
    record_details record_table,
    insurance_details insurance_table,
    emergency_contact_details emergency_contact_table
);

CREATE OR REPLACE FUNCTION GetPatientDetails(patientID IN NUMBER)
    RETURN all_patient_details IS
    -- Temporary variables to hold the data for each table.
    temp_patient patient_table := patient_table();
    temp_record record_table := record_table();
    temp_insurance insurance_table := insurance_table();
    temp_emergency_contact emergency_contact_table := emergency_contact_table();

BEGIN
    -- Populate the patient details
    FOR rec IN (
        SELECT p.idpatient, p.patient_fname, p.patient_lname, p.blood_type, p.phone AS patient_phone, 
               p.email, p.gender, p.policy_number AS patient_policy_number, p.birthday
        FROM hospital.patient p
        WHERE p.idpatient = patientID
    ) LOOP
        temp_patient.EXTEND;
        temp_patient(temp_patient.LAST) := patient_row(rec.idpatient, rec.patient_fname, rec.patient_lname, rec.blood_type, rec.patient_phone, 
                                                      rec.email, rec.gender, rec.patient_policy_number, rec.birthday);
    END LOOP;

    -- Populate the record details
    FOR rec IN (
        SELECT r.record_id, r.condition, r.record_date, r.idpatient
        FROM hospital.record r
        WHERE r.idpatient = patientID
    ) LOOP
        temp_record.EXTEND;
        temp_record(temp_record.LAST) := record_row(rec.record_id, rec.condition, rec.record_date, rec.idpatient);
    END LOOP;

    -- Populate the insurance details
    FOR rec IN (
        SELECT i.policy_number, i.provider, i.insurance_plan, i.co_pay, i.coverage, 
               i.maternity, i.dental, i.optical
        FROM hospital.insurance i
        WHERE i.policy_number = (SELECT policy_number FROM hospital.patient WHERE idpatient = patientID)
    ) LOOP
        temp_insurance.EXTEND;
        temp_insurance(temp_insurance.LAST) := insurance_row(rec.policy_number, rec.provider, rec.insurance_plan, 
                                                             rec.co_pay, rec.coverage, rec.maternity, rec.dental, rec.optical);
    END LOOP;

    -- Populate the emergency contact details
    FOR rec IN (
        SELECT e.contact_name, e.phone, e.relation, e.idpatient
        FROM hospital.emergency_contact e
        WHERE e.idpatient = patientID
    ) LOOP
        temp_emergency_contact.EXTEND;
        temp_emergency_contact(temp_emergency_contact.LAST) := emergency_contact_row(rec.contact_name, rec.phone, rec.relation, rec.idpatient);
    END LOOP;

    -- Return the composite object
    RETURN all_patient_details(temp_patient, temp_record, temp_insurance, temp_emergency_contact);
END GetPatientDetails;

-- CREATE OR REPLACE FUNCTION GetPatientDetails(patientID IN NUMBER)
--     RETURN patient_table PIPELINED IS
-- BEGIN
--     FOR rec IN (
--         SELECT p.idpatient, p.patient_fname, p.patient_lname, p.blood_type, p.phone AS patient_phone, 
--                p.email, p.gender, p.policy_number AS patient_policy_number, p.birthday
--         FROM hospital.patient p
--         WHERE p.idpatient = patientID
--     ) LOOP 
--         PIPE ROW(patient_row(patientID, p.patient_fname, p.patient_lname, p.blood_type, p.patient_phone, 
--                               p.email, p.gender, p.patient_policy_number, p.birthday));
--     END LOOP;

--     RETURN;
-- END GetPatientDetails;

SELECT * FROM TABLE(GetPatientDetails(1));

-- VISION STAFF
-- Get all the info about Staff
CREATE OR REPLACE TYPE hospital_staff AS OBJECT (
EMP_ID    NUMBER(38,0),
EMP_FNAME VARCHAR2(45 BYTE),
EMP_LNAME VARCHAR2(45 BYTE),
DATE_JOINING DATE
DATE_SEPERATION DATE
EMAIL VARCHAR2(50 BYTE),
ADDRESSS VARCHAR2(50 BYTE), -- Mais um S para não dar erro
SSN NUMBER(38,0),
IDDEPARTMENT NUMBER(38,0),
IS_ACTIVE_STATUS VARCHAR2(1 BYTE)
);

CREATE OR REPLACE TYPE hospital_department AS OBJECT (
IDDEPARTMENT    NUMBER(38,0),
DERT_HEAD    VARCHAR2(45 BYTE),
DEPT_NAME    VARCHAR2(45 BYTE),
EMP_COUNT    NUMBER(38,0)
);

CREATE OR REPLACE TYPE  AS OBJECT (
STAFF_EMP_ID    NUMBER(38,0)
);

CREATE OR REPLACE TYPE hospital_doctor AS OBJECT (
EMP_ID    NUMBER(38,0),
QUALIFICATIONS  VARCHAR2(45 BYTE)
);

CREATE OR REPLACE TYPE hospital_technician AS OBJECT (
STAFF_EMP_ID    NUMBER(38,0)
);

CREATE OR REPLACE TYPE all_staff_details AS OBJECT (
    staff_details hospital_staff,
    department_details hospital_department,
    nurse_details hospital_nurse,
    doctor_details hospital_doctor,
    technician_details hospital_technician
);

CREATE OR REPLACE FUNCTION GetStaffDetails(staffID IN NUMBER)
    RETURN all_staff_details IS

    -- Temporary variables to hold the data for each table.
    temp_staff hospital_staff;
    temp_department hospital_department;
    temp_nurse hospital_nurse;
    temp_doctor hospital_doctor;
    temp_technician hospital_technician;

BEGIN
    -- Populate the staff details
    SELECT 
        hospital_staff(emp_id, emp_fname, emp_lname, date_joining, date_separation, 
                       email, addresss, ssn, iddepartment, is_active_status)
    INTO temp_staff
    FROM hospital_staff
    WHERE emp_id = staffID;

    -- Populate the department details
    SELECT 
        hospital_department(iddepartment, dept_head, dept_name, emp_count)
    INTO temp_department
    FROM hospital_department
    WHERE iddepartment = temp_staff.iddepartment;

    -- Check if the staff is a nurse
    SELECT 
        hospital_nurse(staff_emp_id)
    INTO temp_nurse
    FROM hospital_nurse
    WHERE staff_emp_id = staffID;

    -- Check if the staff is a doctor
    SELECT 
        hospital_doctor(emp_id, qualifications)
    INTO temp_doctor
    FROM hospital_doctor
    WHERE emp_id = staffID;

    -- Check if the staff is a technician
    SELECT 
        hospital_technician(staff_emp_id)
    INTO temp_technician
    FROM hospital_technician
    WHERE staff_emp_id = staffID;

    -- Return the composite object
    RETURN all_staff_details(temp_staff, temp_department, temp_nurse, temp_doctor, temp_technician);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;  -- Handle cases where no data is available
END GetStaffDetails;

-------------------

-- Da todas as relacoes

CREATE OR REPLACE TYPE RelationInfoRow AS OBJECT (
  CONSTRAINT_NAME VARCHAR2(30),
  TABLE_NAME VARCHAR2(30),
  COLUMN_NAME VARCHAR2(30),
  REFERENCED_TABLE_NAME VARCHAR2(30),
  REFERENCED_COLUMN_NAME VARCHAR2(30)
);

CREATE OR REPLACE TYPE RelationInfoTable IS TABLE OF RelationInfoRow;

CREATE OR REPLACE FUNCTION ListAllRelations
  RETURN RelationInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT 
      a.CONSTRAINT_NAME,
      a.TABLE_NAME,
      a.COLUMN_NAME,
      c_pk.TABLE_NAME AS REFERENCED_TABLE_NAME,
      c_pk.COLUMN_NAME AS REFERENCED_COLUMN_NAME
    FROM 
      USER_CONS_COLUMNS a
    JOIN 
      USER_CONSTRAINTS c ON a.CONSTRAINT_NAME = c.CONSTRAINT_NAME
    JOIN 
      USER_CONS_COLUMNS c_pk ON c.R_CONSTRAINT_NAME = c_pk.CONSTRAINT_NAME
    WHERE 
      c.CONSTRAINT_TYPE = 'R'
  ) LOOP
    PIPE ROW (RelationInfoRow(
      rec.CONSTRAINT_NAME, rec.TABLE_NAME, rec.COLUMN_NAME, rec.REFERENCED_TABLE_NAME, rec.REFERENCED_COLUMN_NAME
    ));
  END LOOP;
  RETURN;
END ListAllRelations;

-- Query to retrieve all relationships
SELECT * FROM TABLE(ListAllRelations);

-- Output
-- APPOINTMENT_DOCTOR_FK	APPOINTMENT	IDDOCTOR	DOCTOR	EMP_ID
-- FK_BILL_EPISODE1	BILL	IDEPISODE	EPISODE	IDEPISODE
-- FK_APPOINTMENT_EPISODE1	APPOINTMENT	IDEPISODE	EPISODE	IDEPISODE
-- FK_DOCTOR_STAFF1	DOCTOR	EMP_ID	STAFF	EMP_ID
-- FK_EMERGENCY_CONTACT_PATIENT1	EMERGENCY_CONTACT	IDPATIENT	PATIENT	IDPATIENT
-- FK_EPISODE_PATIENT1	EPISODE	PATIENT_IDPATIENT	PATIENT	IDPATIENT
-- FK_HOSPITALIZATION_EPISODE1	HOSPITALIZATION	IDEPISODE	EPISODE	IDEPISODE
-- FK_HOSPITALIZATION_NURSE1	HOSPITALIZATION	RESPONSIBLE_NURSE	NURSE	STAFF_EMP_ID
-- FK_HOSPITALIZATION_ROOM1	HOSPITALIZATION	ROOM_IDROOM	ROOM	IDROOM
-- FK_LAB_SCREENING_EPISODE1	LAB_SCREENING	EPISODE_IDEPISODE	EPISODE	IDEPISODE
-- FK_LAB_SCREENING_TECHNICIAN1	LAB_SCREENING	IDTECHNICIAN	TECHNICIAN	STAFF_EMP_ID
-- FK_MEDICAL_HISTORY_PATIENT1	MEDICAL_HISTORY	IDPATIENT	PATIENT	IDPATIENT
-- FK_NURSE_STAFF1	NURSE	STAFF_EMP_ID	STAFF	EMP_ID
-- FK_PATIENT_INSURANCE	PATIENT	POLICY_NUMBER	INSURANCE	POLICY_NUMBER
-- FK_PRESCRIPTION_EPISODE1	PRESCRIPTION	IDEPISODE	EPISODE	IDEPISODE
-- FK_PRESCRIPTION_MEDICINE1	PRESCRIPTION	IDMEDICINE	MEDICINE	IDMEDICINE
-- FK_STAFF_DEPARTMENT1	STAFF	IDDEPARTMENT	DEPARTMENT	IDDEPARTMENT
-- FK_TECHNICIAN_STAFF1	TECHNICIAN	STAFF_EMP_ID	STAFF	EMP_ID