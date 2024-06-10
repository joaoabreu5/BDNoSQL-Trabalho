-- 1)
-- All info about Hospital.Patient
CREATE OR REPLACE TYPE StaffRow AS OBJECT (
    EMP_ID NUMBER(38, 0),
    EMP_FNAME VARCHAR2(45 BYTE),
    EMP_LNAME VARCHAR2(45 BYTE),
    DATE_JOINING DATE,
    DATE_SEPERATION DATE,
    EMAIL VARCHAR2(50 BYTE),
    ADDRESS VARCHAR2(50 BYTE),
    SSN NUMBER(38, 0),
    IDDEPARTMENT NUMBER(38, 0),
    IS_ACTIVE_STATUS VARCHAR2(1)
);

CREATE OR REPLACE TYPE StaffTable IS TABLE OF StaffRow;

CREATE OR REPLACE FUNCTION AllInfoStaff(id_emp IN NUMBER)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT 
        s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM 
        Hospital.Staff s
    WHERE
        s.emp_id = id_emp
  ) LOOP
    PIPE ROW (StaffRow(rec.emp_id, rec.emp_fname, rec.emp_lname,
        rec.date_joining, rec.date_seperation, rec.email, rec.address,
        rec.ssn, rec.iddepartment, rec.is_active_status));
  END LOOP;
  RETURN;
END AllInfoStaff;

SELECT * FROM TABLE(AllInfoStaff(1));

-- 2) 
-- All info about Hospital.Department
CREATE OR REPLACE TYPE DepartmentRow AS OBJECT (
    IDDEPARTMENT NUMBER(38, 0),
    DEPT_HEAD    VARCHAR2(45 BYTE),
    DEPT_NAME    VARCHAR2(45 BYTE),
    EMP_COUNT    NUMBER(38, 0)
);

CREATE OR REPLACE TYPE DepartmentTable IS TABLE OF DepartmentRow;

CREATE OR REPLACE FUNCTION AllInfoDepartment(emp_id IN NUMBER)
  RETURN DepartmentTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT d.IDDEPARTMENT, d.DEPT_HEAD, d.DEPT_NAME, d.EMP_COUNT
    FROM Hospital.Department d
    JOIN Hospital.Staff s ON d.IDDEPARTMENT = s.IDDEPARTMENT
    WHERE s.EMP_ID = emp_id
  ) LOOP
    PIPE ROW (DepartmentRow(rec.IDDEPARTMENT, rec.DEPT_HEAD, rec.DEPT_NAME, rec.EMP_COUNT));
  END LOOP;
  RETURN;
END AllInfoDepartment;

SELECT * FROM TABLE(AllInfoDepartment(82));

-- 3)
-- All info about Hospital.Nurse
CREATE OR REPLACE TYPE NurseRow AS OBJECT (
    EMP_ID NUMBER(38, 0),
    EMP_FNAME VARCHAR2(45 BYTE),
    EMP_LNAME VARCHAR2(45 BYTE),
    DATE_JOINING DATE,
    DATE_SEPERATION DATE,
    EMAIL VARCHAR2(50 BYTE),
    ADDRESS VARCHAR2(50 BYTE),
    SSN NUMBER(38, 0),
    IS_ACTIVE_STATUS VARCHAR2(1),
    IDDEPARTMENT NUMBER(38, 0),
    DEPT_HEAD    VARCHAR2(45 BYTE),
    DEPT_NAME    VARCHAR2(45 BYTE),
    EMP_COUNT    NUMBER(38, 0)
);

CREATE OR REPLACE TYPE NurseTable IS TABLE OF NurseRow;

CREATE OR REPLACE FUNCTION AllInfoNurse(emp_id IN NUMBER)
  RETURN NurseTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.EMP_ID, s.EMP_FNAME, s.EMP_LNAME, s.DATE_JOINING, s.DATE_SEPERATION,
           s.EMAIL, s.ADDRESS, s.SSN, s.IS_ACTIVE_STATUS,
           d.IDDEPARTMENT, d.DEPT_HEAD, d.DEPT_NAME, d.EMP_COUNT
    FROM Hospital.Staff s
    LEFT JOIN Hospital.Department d ON s.IDDEPARTMENT = d.IDDEPARTMENT
    LEFT JOIN Hospital.Nurse n ON s.EMP_ID = n.STAFF_EMP_ID
    WHERE n.STAFF_EMP_ID = emp_id
  ) LOOP
    PIPE ROW (NurseRow(
      rec.EMP_ID, rec.EMP_FNAME, rec.EMP_LNAME, rec.DATE_JOINING, rec.DATE_SEPERATION,
      rec.EMAIL, rec.ADDRESS, rec.SSN, rec.IS_ACTIVE_STATUS, rec.IDDEPARTMENT,
      rec.DEPT_HEAD, rec.DEPT_NAME, rec.EMP_COUNT
      ));
  END LOOP;
  RETURN;
END AllInfoNurse;

SELECT * FROM TABLE(AllInfoNurse(1));

-- 4)
-- All info about Hospital.Doctor
CREATE OR REPLACE TYPE DoctorRow AS OBJECT (
    EMP_ID NUMBER(38, 0),
    EMP_FNAME VARCHAR2(45 BYTE),
    EMP_LNAME VARCHAR2(45 BYTE),
    DATE_JOINING DATE,
    DATE_SEPERATION DATE,
    EMAIL VARCHAR2(50 BYTE),
    ADDRESS VARCHAR2(50 BYTE),
    SSN NUMBER(38, 0),
    IS_ACTIVE_STATUS VARCHAR2(1),
    IDDEPARTMENT NUMBER(38, 0),
    DEPT_HEAD    VARCHAR2(45 BYTE),
    DEPT_NAME    VARCHAR2(45 BYTE),
    EMP_COUNT    NUMBER(38, 0),
    QUALIFICATIONS VARCHAR2(45 BYTE)
);

CREATE OR REPLACE TYPE DoctorTable IS TABLE OF DoctorRow;

CREATE OR REPLACE FUNCTION AllInfoDoctor(doctor_id IN NUMBER)
  RETURN DoctorTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.EMP_ID, s.EMP_FNAME, s.EMP_LNAME, s.DATE_JOINING, s.DATE_SEPERATION,
           s.EMAIL, s.ADDRESS, s.SSN, s.IS_ACTIVE_STATUS,
           d.IDDEPARTMENT, d.DEPT_HEAD, d.DEPT_NAME, d.EMP_COUNT, m.QUALIFICATIONS
    FROM Hospital.Staff s
    LEFT JOIN Hospital.Department d ON s.IDDEPARTMENT = d.IDDEPARTMENT
    LEFT JOIN Hospital.Doctor m ON s.EMP_ID = m.EMP_ID
    WHERE m.EMP_ID = doctor_id
  ) LOOP
    PIPE ROW (DoctorRow(
      rec.EMP_ID, rec.EMP_FNAME, rec.EMP_LNAME, rec.DATE_JOINING, rec.DATE_SEPERATION,
      rec.EMAIL, rec.ADDRESS, rec.SSN, rec.IS_ACTIVE_STATUS, rec.IDDEPARTMENT,
      rec.DEPT_HEAD, rec.DEPT_NAME, rec.EMP_COUNT, rec.QUALIFICATIONS
    ));
  END LOOP;
  RETURN;
END AllInfoDoctor;

SELECT * FROM TABLE(AllInfoDoctor(1));

-- 5)
-- All info about Hospital.Technician
CREATE OR REPLACE TYPE TechnicianRow AS OBJECT (
    EMP_ID NUMBER(38, 0),
    EMP_FNAME VARCHAR2(45 BYTE),
    EMP_LNAME VARCHAR2(45 BYTE),
    DATE_JOINING DATE,
    DATE_SEPERATION DATE,
    EMAIL VARCHAR2(50 BYTE),
    ADDRESS VARCHAR2(50 BYTE),
    SSN NUMBER(38, 0),
    IS_ACTIVE_STATUS VARCHAR2(1),
    IDDEPARTMENT NUMBER(38, 0),
    DEPT_HEAD    VARCHAR2(45 BYTE),
    DEPT_NAME    VARCHAR2(45 BYTE),
    EMP_COUNT    NUMBER(38, 0)
);

CREATE OR REPLACE TYPE TechnicianTable IS TABLE OF TechnicianRow;

CREATE OR REPLACE FUNCTION AllInfoTechnician(emp_id IN NUMBER)
  RETURN TechnicianTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.EMP_ID, s.EMP_FNAME, s.EMP_LNAME, s.DATE_JOINING, s.DATE_SEPERATION,
           s.EMAIL, s.ADDRESS, s.SSN, s.IS_ACTIVE_STATUS,
           d.IDDEPARTMENT, d.DEPT_HEAD, d.DEPT_NAME, d.EMP_COUNT
    FROM Hospital.Staff s
    LEFT JOIN Hospital.Department d ON s.IDDEPARTMENT = d.IDDEPARTMENT
    LEFT JOIN Hospital.Technician t ON s.EMP_ID = t.STAFF_EMP_ID
    WHERE t.STAFF_EMP_ID = emp_id
  ) LOOP
    PIPE ROW (TechnicianRow(
      rec.EMP_ID, rec.EMP_FNAME, rec.EMP_LNAME, rec.DATE_JOINING, rec.DATE_SEPERATION,
      rec.EMAIL, rec.ADDRESS, rec.SSN, rec.IS_ACTIVE_STATUS, rec.IDDEPARTMENT,
      rec.DEPT_HEAD, rec.DEPT_NAME, rec.EMP_COUNT
    ));
  END LOOP;
  RETURN;
END AllInfoTechnician;

SELECT * FROM TABLE(AllInfoTechnician(1));

-- 6)
-- Get Staff Members by Date_Joining
CREATE OR REPLACE FUNCTION AllInfoStaffByDateJoining(date_joining IN DATE)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM Hospital.Staff s
    WHERE s.date_joining = date_joining
  ) LOOP
    PIPE ROW (StaffRow(rec.emp_id, rec.emp_fname, rec.emp_lname,
        rec.date_joining, rec.date_seperation, rec.email, rec.address,
        rec.ssn, rec.iddepartment, rec.is_active_status));
  END LOOP;
  RETURN;
END AllInfoStaffByDateJoining;

-- Query to retrieve staff information for a specific date joining
SELECT * FROM TABLE(AllInfoStaffByDateJoining(to_date('18.08.25','RR.MM.DD')));


-- 7)
-- Get Staff Members by Date_Seperation
CREATE OR REPLACE FUNCTION AllInfoStaffByDateSeperation(date_seperation IN DATE)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM Hospital.Staff s
    WHERE s.date_seperation = date_seperation
  ) LOOP
    PIPE ROW (StaffRow(rec.emp_id, rec.emp_fname, rec.emp_lname,
        rec.date_joining, rec.date_seperation, rec.email, rec.address,
        rec.ssn, rec.iddepartment, rec.is_active_status));
  END LOOP;
  RETURN;
END AllInfoStaffByDateSeperation;

-- Query to retrieve staff information for a specific date seperation
SELECT * FROM TABLE(AllInfoStaffByDateSeperation(to_date('18.08.25','RR.MM.DD')));

-- 8)
-- Get Staff Members that are active or inactive
CREATE OR REPLACE FUNCTION AllInfoStaffByStatus(is_active_status IN VARCHAR2)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM Hospital.Staff s
    WHERE s.is_active_status = is_active_status
  ) LOOP
    PIPE ROW (StaffRow(rec.emp_id, rec.emp_fname, rec.emp_lname,
        rec.date_joining, rec.date_seperation, rec.email, rec.address,
        rec.ssn, rec.iddepartment, rec.is_active_status));
  END LOOP;
  RETURN;
END AllInfoStaffByStatus;

-- Query to retrieve staff information for status active
SELECT * FROM TABLE(AllInfoStaffByStatus('Y'));
-- Query to retrieve staff information for status inactive
SELECT * FROM TABLE(AllInfoStaffByStatus('N'));

-- 9)
-- Get the number of Nurses
SELECT COUNT(*) AS nurse_count FROM Hospital.Nurse;

-- 10)
-- Get the number of Doctors
SELECT COUNT(*) AS doctor_count FROM Hospital.Doctor;

-- 11)
-- Get the number of Technicians
SELECT COUNT(*) AS technician_count FROM Hospital.Technician;

-- 12)
-- Get all the diferent qualifications
SELECT DISTINCT QUALIFICATIONS FROM Hospital.Doctor;

-- 13)
-- Get all the diferent qualifications for a specific Doctor
CREATE OR REPLACE TYPE QualificationRow AS OBJECT (
    QUALIFICATIONS VARCHAR2(45 BYTE)
);

CREATE OR REPLACE TYPE QualificationTable IS TABLE OF QualificationRow;

CREATE OR REPLACE FUNCTION GetDoctorQualifications(doctor_id IN NUMBER)
  RETURN QualificationTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT d.QUALIFICATIONS
    FROM Hospital.Doctor d
    WHERE d.EMP_ID = doctor_id
  ) LOOP
    PIPE ROW (QualificationRow(rec.QUALIFICATIONS));
  END LOOP;
  RETURN;
END GetDoctorQualifications;

-- Query to retrieve all qualifications from a specific doctor
SELECT * FROM TABLE(GetDoctorQualifications(1));


-- 14)
-- Get the number of Departments
SELECT COUNT(*) AS department_count FROM Hospital.Department;

-- 15)
-- Get the number of Employers per Department
CREATE OR REPLACE TYPE DepartmentEmployeeCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    EMPLOYEE_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentEmployeeCountTable IS TABLE OF DepartmentEmployeeCountRow;

CREATE OR REPLACE PROCEDURE GetEmployeeCountPerDepartmentProc (departments OUT DepartmentEmployeeCountTable) IS
BEGIN
  departments := DepartmentEmployeeCountTable();
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
    FROM Hospital.Staff s
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    departments.EXTEND;
    departments(departments.COUNT) := DepartmentEmployeeCountRow(
      rec.DEPARTMENT_ID, rec.EMPLOYEE_COUNT
    );
  END LOOP;
END GetEmployeeCountPerDepartmentProc;

DECLARE
  departments DepartmentEmployeeCountTable;
BEGIN
  GetEmployeeCountPerDepartmentProc(departments);
  FOR i IN 1..departments.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('DEPARTMENT_ID: ' || departments(i).DEPARTMENT_ID ||
                         ', EMPLOYEE_COUNT: ' || departments(i).EMPLOYEE_COUNT);
  END LOOP;
END;

-- 16)
-- Get the number of Nurses per Department
CREATE OR REPLACE TYPE DepartmentNurseCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    NURSE_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentNurseCountTable IS TABLE OF DepartmentNurseCountRow;

CREATE OR REPLACE PROCEDURE GetNurseCountPerDepartmentProc (departments OUT DepartmentNurseCountTable) IS
BEGIN
  departments := DepartmentNurseCountTable(); -- Initialize the collection
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS NURSE_COUNT
    FROM Hospital.Nurse n
    JOIN Hospital.Staff s ON n.STAFF_EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    departments.EXTEND;
    departments(departments.COUNT) := DepartmentNurseCountRow(
      rec.DEPARTMENT_ID, rec.NURSE_COUNT
    );
  END LOOP;
END GetNurseCountPerDepartmentProc;

DECLARE
  departments DepartmentNurseCountTable;
BEGIN
  GetNurseCountPerDepartmentProc(departments);
  FOR i IN 1..departments.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('DEPARTMENT_ID: ' || departments(i).DEPARTMENT_ID ||
                         ', NURSE_COUNT: ' || departments(i).NURSE_COUNT);
  END LOOP;
END;

-- 17)
-- Get the number of Doctors per Department
CREATE OR REPLACE TYPE DepartmentDoctorCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    DOCTOR_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentDoctorCountTable IS TABLE OF DepartmentDoctorCountRow;

CREATE OR REPLACE PROCEDURE GetDoctorCountPerDepartmentProc (departments OUT DepartmentDoctorCountTable) IS
BEGIN
  departments := DepartmentDoctorCountTable(); -- Initialize the collection
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS DOCTOR_COUNT
    FROM Hospital.Doctor d
    JOIN Hospital.Staff s ON d.EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    departments.EXTEND;
    departments(departments.COUNT) := DepartmentDoctorCountRow(
      rec.DEPARTMENT_ID, rec.DOCTOR_COUNT
    );
  END LOOP;
END GetDoctorCountPerDepartmentProc;

DECLARE
  departments DepartmentDoctorCountTable;
BEGIN
  GetDoctorCountPerDepartmentProc(departments);
  FOR i IN 1..departments.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('DEPARTMENT_ID: ' || departments(i).DEPARTMENT_ID ||
                         ', DOCTOR_COUNT: ' || departments(i).DOCTOR_COUNT);
  END LOOP;
END;

-- 18)
-- Get the number of Technicians per Department
CREATE OR REPLACE TYPE DepartmentTechniciansCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    TECHNICIANS_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentTechniciansCountTable IS TABLE OF DepartmentTechniciansCountRow;

CREATE OR REPLACE PROCEDURE GetTechniciansCountPerDepartmentProc (departments OUT DepartmentTechniciansCountTable) IS
BEGIN
  departments := DepartmentTechniciansCountTable(); -- Initialize the collection
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS TECHNICIANS_COUNT
    FROM Hospital.Technician t
    JOIN Hospital.Staff s ON t.STAFF_EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    departments.EXTEND;
    departments(departments.COUNT) := DepartmentTechniciansCountRow(
      rec.DEPARTMENT_ID, rec.TECHNICIANS_COUNT
    );
  END LOOP;
END GetTechniciansCountPerDepartmentProc;

DECLARE
  departments DepartmentTechniciansCountTable;
BEGIN
  GetTechniciansCountPerDepartmentProc(departments);
  FOR i IN 1..departments.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('DEPARTMENT_ID: ' || departments(i).DEPARTMENT_ID ||
                         ', TECHNICIANS_COUNT: ' || departments(i).TECHNICIANS_COUNT);
  END LOOP;
END;

---------------------------------------------------------------------------------------------------------------

-- INSERTS

-- 1)
-- Insert Staff Member who is a Nurse with a Trigger associated
DECLARE
    max_id NUMBER;
BEGIN
    SELECT COALESCE(MAX(EMP_ID), 0) INTO max_id FROM Hospital.STAFF;

    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE staff_seq_new';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                RAISE;
            END IF;
    END;

    EXECUTE IMMEDIATE 'CREATE SEQUENCE staff_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_staff_and_nurse (
    emp_fname VARCHAR2,
    emp_lname VARCHAR2,
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2,
    address VARCHAR2,
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2
) IS
    emp_id NUMBER;
BEGIN
    -- Insert staff member and get the new EMP_ID
    INSERT INTO Hospital.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert into nurse table
    INSERT INTO Hospital.NURSE (STAFF_EMP_ID) VALUES (emp_id);

    -- Increment the employee count in the Department table
    UPDATE Hospital.DEPARTMENT
    SET emp_count = emp_count + 1
    WHERE iddepartment = iddepartment;

    DBMS_OUTPUT.PUT_LINE('Staff member and nurse inserted successfully, department count updated.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_staff_and_nurse(
        'Francisco', 'Claudino', TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 'claudino@gmail.com', 'A minha casa', 123456789, 5, 'Y'
    );
END;

-- Logs Request Table for Nurse
CREATE TABLE Hospital.New_Staff_Nurse_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    emp_fname VARCHAR2(45),
    emp_lname VARCHAR2(45),
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2(50),
    address VARCHAR2(100),
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2(1)
);

-- Trigger
CREATE OR REPLACE TRIGGER trg_insert_staff_and_nurse
AFTER INSERT ON Hospital.New_Staff_Nurse_Requests
FOR EACH ROW
BEGIN
    insert_staff_and_nurse(
        :NEW.emp_fname,
        :NEW.emp_lname,
        :NEW.date_joining,
        :NEW.date_seperation,
        :NEW.email,
        :NEW.address,
        :NEW.ssn,
        :NEW.iddepartment,
        :NEW.is_active_status
    );
END;

INSERT INTO Hospital.New_Staff_Nurse_Requests (
    emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
) VALUES (
    'Francisco', 'Claudino', TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 'claudino@gmail.com', 'A minha casa', 123456789, 5, 'Y'
);


-- 2)
-- Insert Staff Member who is a Doctor with a Trigger associated
CREATE OR REPLACE PROCEDURE insert_staff_and_doctor (
    emp_fname VARCHAR2,
    emp_lname VARCHAR2,
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2,
    address VARCHAR2,
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2,
    qualifications VARCHAR2
) IS
    emp_id NUMBER;
BEGIN
    -- Insert staff member and get the new EMP_ID
    INSERT INTO Hospital.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert into doctor table
    INSERT INTO Hospital.DOCTOR (EMP_ID, QUALIFICATIONS) VALUES (emp_id, qualifications);

    -- Increment the employee count in the Department table
    UPDATE Hospital.DEPARTMENT
    SET emp_count = emp_count + 1
    WHERE iddepartment = iddepartment;

    DBMS_OUTPUT.PUT_LINE('Staff member and doctor inserted successfully, department count updated.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Logs Request Table for Doctor
CREATE TABLE Hospital.New_Staff_Doctor_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    emp_fname VARCHAR2(45),
    emp_lname VARCHAR2(45),
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2(50),
    address VARCHAR2(100),
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2(1),
    qualifications VARCHAR2(100)
);

-- Trigger
CREATE OR REPLACE TRIGGER trg_insert_staff_and_doctor
AFTER INSERT ON Hospital.New_Staff_Doctor_Requests
FOR EACH ROW
BEGIN
    insert_staff_and_doctor(
        :NEW.emp_fname,
        :NEW.emp_lname,
        :NEW.date_joining,
        :NEW.date_seperation,
        :NEW.email,
        :NEW.address,
        :NEW.ssn,
        :NEW.iddepartment,
        :NEW.is_active_status,
        :NEW.qualifications
    );
END;

INSERT INTO Hospital.New_Staff_Doctor_Requests (
    emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status, qualifications
) VALUES (
    'Francisco', 'Claudino', TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 'claudino@gmail.com', 'A minha casa', 123456789, 5, 'Y', 'Cardiology'
);

-- 3)
-- Insert Staff Member who is a Technician with a Trigger associated
CREATE OR REPLACE PROCEDURE insert_staff_and_technician (
    emp_fname VARCHAR2,
    emp_lname VARCHAR2,
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2,
    address VARCHAR2,
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2
) IS
    emp_id NUMBER;
BEGIN
    -- Insert staff member and get the new EMP_ID
    INSERT INTO Hospital.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert into technician table
    INSERT INTO Hospital.TECHNICIAN (STAFF_EMP_ID) VALUES (emp_id);

    -- Increment the employee count in the Department table
    UPDATE Hospital.DEPARTMENT
    SET emp_count = emp_count + 1
    WHERE iddepartment = iddepartment;

    DBMS_OUTPUT.PUT_LINE('Staff member and technician inserted successfully, department count updated.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Logs Request Table for Technician
CREATE TABLE Hospital.New_Staff_Technician_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    emp_fname VARCHAR2(45),
    emp_lname VARCHAR2(45),
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2(50),
    address VARCHAR2(100),
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2(1)
);

CREATE OR REPLACE TRIGGER trg_insert_staff_and_technician
AFTER INSERT ON Hospital.New_Staff_Technician_Requests
FOR EACH ROW
BEGIN
    insert_staff_and_technician(
        :NEW.emp_fname,
        :NEW.emp_lname,
        :NEW.date_joining,
        :NEW.date_seperation,
        :NEW.email,
        :NEW.address,
        :NEW.ssn,
        :NEW.iddepartment,
        :NEW.is_active_status
    );
END;

INSERT INTO Hospital.New_Staff_Technician_Requests (
    emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
) VALUES (
    'Francisco', 'Claudino', TO_DATE('2023-06-01', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 'claudino@gmail.com', 'A minha casa', 123456789, 5, 'Y'
);

-- 4)
-- Insert Department
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDDEPARTMENT value
    SELECT COALESCE(MAX(IDDEPARTMENT), 0) INTO max_id FROM Hospital.DEPARTMENT;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE department_seq_new';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                RAISE;
            END IF;
    END;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE department_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_hospital_department (
    dept_head VARCHAR2,
    dept_name VARCHAR2,
    emp_count NUMBER
) IS
BEGIN
    INSERT INTO Hospital.DEPARTMENT (
        IDDEPARTMENT, DEPT_HEAD, DEPT_NAME, EMP_COUNT
    )
    VALUES (
        department_seq_new.NEXTVAL, dept_head, dept_name, emp_count
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Hospital.DEPARTMENT');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_hospital_department('Francisco', 'Informatica', 658);
END;

-- Trigger for Inserting a Deppartment
CREATE TABLE Hospital.New_Department_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    dept_head VARCHAR2(45),
    dept_name VARCHAR2(45),
    emp_count NUMBER
);

CREATE OR REPLACE TRIGGER trg_insert_department
AFTER INSERT ON Hospital.New_Department_Requests
FOR EACH ROW
BEGIN
    insert_hospital_department(:NEW.dept_head, :NEW.dept_name, :NEW.emp_count);
END;

INSERT INTO Hospital.New_Department_Requests (dept_head, dept_name, emp_count)
VALUES ('Francisco', 'Informatica', 658);


---------------------------------------------------------------------------------------------------------------

-- UPDATES

-- Update Staff Member
CREATE OR REPLACE PROCEDURE update_staff (
    p_emp_id          IN NUMBER,
    p_emp_fname       IN VARCHAR2,
    p_emp_lname       IN VARCHAR2,
    p_date_joining    IN DATE,
    p_date_seperation IN DATE,
    p_email           IN VARCHAR2,
    p_address         IN VARCHAR2,
    p_ssn             IN NUMBER,
    p_new_iddepartment IN NUMBER,
    p_is_active_status IN VARCHAR2
) IS
    v_old_iddepartment NUMBER;
BEGIN
    -- Get the old department ID of the staff member
    SELECT iddepartment INTO v_old_iddepartment
    FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Update the staff member's details
    UPDATE Hospital.STAFF
    SET emp_fname = p_emp_fname,
        emp_lname = p_emp_lname,
        date_joining = p_date_joining,
        date_seperation = p_date_seperation,
        email = p_email,
        address = p_address,
        ssn = p_ssn,
        iddepartment = p_new_iddepartment,
        is_active_status = p_is_active_status
    WHERE emp_id = p_emp_id;

    -- If the department has changed, update the department employee counts
    IF v_old_iddepartment != p_new_iddepartment THEN
        -- Decrement the employee count in the old department
        UPDATE Hospital.DEPARTMENT
        SET emp_count = emp_count - 1
        WHERE iddepartment = v_old_iddepartment;

        -- Increment the employee count in the new department
        UPDATE Hospital.DEPARTMENT
        SET emp_count = emp_count + 1
        WHERE iddepartment = p_new_iddepartment;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Staff member updated successfully, department counts updated if changed.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Staff Member
CREATE OR REPLACE TRIGGER trg_update_staff
BEFORE UPDATE ON Hospital.STAFF
FOR EACH ROW
BEGIN
    update_staff(
        p_emp_id          => :OLD.emp_id,
        p_emp_fname       => :NEW.emp_fname,
        p_emp_lname       => :NEW.emp_lname,
        p_date_joining    => :NEW.date_joining,
        p_date_seperation => :NEW.date_seperation,
        p_email           => :NEW.email,
        p_address         => :NEW.address,
        p_ssn             => :NEW.ssn,
        p_new_iddepartment => :NEW.iddepartment,
        p_is_active_status => :NEW.is_active_status
    );
END;

BEGIN
    UPDATE Hospital.STAFF
    SET emp_fname = 'Updated FirstName',
        emp_lname = 'Updated LastName',
        date_joining = TO_DATE('2023-01-01', 'YYYY-MM-DD'),
        date_seperation = TO_DATE('2023-12-31', 'YYYY-MM-DD'),
        email = 'updated.email@example.com',
        address = 'Updated Address',
        ssn = 123456789,
        iddepartment = 2,
        is_active_status = 'Y'
    WHERE emp_id = 1;
END;

-- Update Doctor
CREATE OR REPLACE PROCEDURE update_doctor (
    p_emp_id         IN NUMBER,
    p_qualifications IN VARCHAR2
) IS
BEGIN
    -- Update the doctor's qualifications
    UPDATE Hospital.DOCTOR
    SET qualifications = p_qualifications
    WHERE emp_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Doctor qualifications updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Doctor
CREATE OR REPLACE TRIGGER trg_update_doctor
BEFORE UPDATE ON Hospital.DOCTOR
FOR EACH ROW
BEGIN
    update_doctor(
        p_emp_id         => :OLD.emp_id,
        p_qualifications => :NEW.qualifications
    );
END;

BEGIN
    UPDATE Hospital.DOCTOR
    SET qualifications = 'Updated Qualification'
    WHERE emp_id = 1;
END;

-- Update Department
CREATE OR REPLACE PROCEDURE update_department (
    p_iddepartment IN NUMBER,
    p_dept_head    IN VARCHAR2,
    p_dept_name    IN VARCHAR2,
    p_emp_count    IN NUMBER
) IS
BEGIN
    UPDATE Hospital.DEPARTMENT
    SET dept_head = p_dept_head,
        dept_name = p_dept_name,
        emp_count = p_emp_count
    WHERE iddepartment = p_iddepartment;

    DBMS_OUTPUT.PUT_LINE('Department record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Department
CREATE OR REPLACE TRIGGER trg_update_department
BEFORE UPDATE ON Hospital.DEPARTMENT
FOR EACH ROW
BEGIN
    update_department(
        p_iddepartment => :OLD.iddepartment,
        p_dept_head    => :NEW.dept_head,
        p_dept_name    => :NEW.dept_name,
        p_emp_count    => :NEW.emp_count
    );
END;

-- Example update statement, assuming iddepartment 1 exists
BEGIN
    UPDATE Hospital.DEPARTMENT
    SET dept_head = 'New Head',
        dept_name = 'New Department Name',
        emp_count = 25
    WHERE iddepartment = 1;
END;

---------------------------------------------------------------------------------------------------------------

-- DELETES

-- 1)
-- Delete a Staff Member and Nurse
CREATE OR REPLACE PROCEDURE delete_staff_and_nurse (
    p_emp_id IN NUMBER
) IS
    v_iddepartment NUMBER;
BEGIN
    -- Get the department ID of the staff member
    SELECT iddepartment INTO v_iddepartment
    FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Delete from the Nurse table
    DELETE FROM Hospital.NURSE
    WHERE staff_emp_id = p_emp_id;

    -- Delete from the Staff table
    DELETE FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Decrement the employee count in the Department table
    UPDATE Hospital.DEPARTMENT
    SET emp_count = emp_count - 1
    WHERE iddepartment = v_iddepartment;

    -- Set responsible_nurse in the Hospitalisation table to 0
    UPDATE Hospital.HOSPITALIZATION
    SET responsible_nurse = 0
    WHERE responsible_nurse = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Staff member and nurse deleted successfully, department count updated, responsible nurse set to 0 in hospitalisation.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete a Staff Member and Nurse
CREATE OR REPLACE TRIGGER trg_delete_staff_and_nurse
BEFORE DELETE ON Hospital.STAFF
FOR EACH ROW
BEGIN
    delete_staff_and_nurse(:OLD.emp_id);
END;

DELETE FROM Hospital.STAFF WHERE emp_id = 1;


-- 2)
-- Delete a Staff Member and Doctor
CREATE OR REPLACE PROCEDURE delete_staff_and_doctor (
    p_emp_id IN NUMBER
) IS
    v_iddepartment NUMBER;
BEGIN
    -- Get the department ID of the staff member
    SELECT iddepartment INTO v_iddepartment
    FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Delete from the Doctor table
    DELETE FROM Hospital.DOCTOR
    WHERE emp_id = p_emp_id;

    -- Delete from the Staff table
    DELETE FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Decrement the employee count in the Department table
    UPDATE Hospital.DEPARTMENT
    SET emp_count = emp_count - 1
    WHERE iddepartment = v_iddepartment;

    -- Set iddoctor in the Appointment table to 0
    UPDATE Hospital.APPOINTMENT
    SET iddoctor = 0
    WHERE iddoctor = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Staff member and doctor deleted successfully, department count updated, iddoctor set to 0 in appointment.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete a Staff Member and Doctor
CREATE OR REPLACE TRIGGER trg_delete_staff_and_doctor
BEFORE DELETE ON Hospital.STAFF
FOR EACH ROW
BEGIN
    delete_staff_and_doctor(:OLD.emp_id);
END;

DELETE FROM Hospital.STAFF WHERE emp_id = 1;


-- 3)
-- Delete a Staff Member and Technician
CREATE OR REPLACE PROCEDURE delete_staff_and_technician (
    p_emp_id IN NUMBER
) IS
    v_iddepartment NUMBER;
BEGIN
    -- Get the department ID of the staff member
    SELECT iddepartment INTO v_iddepartment
    FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Delete from the Technician table
    DELETE FROM Hospital.TECHNICIAN
    WHERE staff_emp_id = p_emp_id;

    -- Delete from the Staff table
    DELETE FROM Hospital.STAFF
    WHERE emp_id = p_emp_id;

    -- Decrement the employee count in the Department table
    UPDATE Hospital.DEPARTMENT
    SET emp_count = emp_count - 1
    WHERE iddepartment = v_iddepartment;

    -- Set idtechnician in the Lab_Screening table to 0
    UPDATE Hospital.LAB_SCREENING
    SET idtechnician = 0
    WHERE idtechnician = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Staff member and technician deleted successfully, department count updated, idtechnician set to 0 in lab_screening.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete a Staff Member and Technician
CREATE OR REPLACE TRIGGER trg_delete_staff_and_technician
BEFORE DELETE ON Hospital.STAFF
FOR EACH ROW
BEGIN
    delete_staff_and_technician(:OLD.emp_id);
END;

DELETE FROM Hospital.STAFF WHERE emp_id = 1;


-- 4)
-- Delete a Department
CREATE OR REPLACE PROCEDURE DeleteDepartment (
    p_iddepartment IN NUMBER
) IS
BEGIN
    -- Update the staff members to set iddepartment to 0
    UPDATE Hospital.Staff
    SET iddepartment = 0
    WHERE iddepartment = p_iddepartment;

    -- Delete the department
    DELETE FROM Hospital.Department
    WHERE iddepartment = p_iddepartment;

    DBMS_OUTPUT.PUT_LINE('Department deleted and staff members updated successfully');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete a Department
CREATE OR REPLACE TRIGGER trg_delete_department
BEFORE DELETE ON Hospital.Department
FOR EACH ROW
BEGIN
    DeleteDepartment(:OLD.iddepartment);
END;

DELETE FROM Hospital.Department WHERE iddepartment = 1;