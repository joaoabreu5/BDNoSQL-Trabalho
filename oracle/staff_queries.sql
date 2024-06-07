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

-- Insert Staff Member
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDPATIENT value
    SELECT COALESCE(MAX(EMP_ID), 0) INTO max_id FROM Hospital.STAFF;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE staff_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_hospital_staff_member (
    emp_fname VARCHAR2,
    emp_lname VARCHAR2,
    date_joining DATE,
    date_sepEration DATE,
    email VARCHAR2,
    adDress VARCHAR2,
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2
) IS
BEGIN
    INSERT INTO Hospital.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, TO_DATE(date_joining, 'YY.MM.DD'), TO_DATE(date_sepEration, 'YY.MM.DD'), email, adDress, ssn, iddepartment, is_active_status
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into HOSPITAL.STAFF');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_hospital_staff_member(
        'Francisco', 'Claudino', '', '', 'claudino@gmail.com', 'A minha casa', 658, 5, 'Y'
    );
END;

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

-- Insert Nurse
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum STAFF_EMP_ID value
    SELECT COALESCE(MAX(STAFF_EMP_ID), 0) INTO max_id FROM Hospital.NURSE;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE nurse_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_nurse (
    staff_emp_id NUMBER
) IS
BEGIN
    INSERT INTO Hospital.NURSE (
        STAFF_EMP_ID
    )
    VALUES (
        staff_emp_id
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Hospital.NURSE');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_nurse(1);
END;

-- Insert Doctor
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum EMP_ID value in the DOCTOR table
    SELECT COALESCE(MAX(EMP_ID), 0) INTO max_id FROM Hospital.DOCTOR;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE doctor_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_doctor (
    emp_id NUMBER,
    qualifications VARCHAR2
) IS
BEGIN
    INSERT INTO Hospital.DOCTOR (
        EMP_ID, QUALIFICATIONS
    )
    VALUES (
        emp_id, qualifications
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Hospital.DOCTOR');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_doctor(1,'Cardiology');
END;

-- Insert Technician
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum STAFF_EMP_ID value in the TECHNICIAN table
    SELECT COALESCE(MAX(STAFF_EMP_ID), 0) INTO max_id FROM Hospital.TECHNICIAN;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE technician_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_technician (
    staff_emp_id NUMBER
) IS
BEGIN
    INSERT INTO Hospital.TECHNICIAN (
        STAFF_EMP_ID
    )
    VALUES (
        staff_emp_id
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Hospital.TECHNICIAN');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_technician(1);
END;

-- Insert Staff and Nurse
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

    DBMS_OUTPUT.PUT_LINE('Staff member and nurse inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;


BEGIN
    insert_staff_and_nurse(
        'Francisco', 'Claudino', TO_DATE('23.06.01', 'YY.MM.DD'), TO_DATE('23.12.31', 'YY.MM.DD'), 'claudino@gmail.com', 'A minha casa', 123456789, 5, 'Y'
    );
END;

-- Insert Staff and Doctor
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

    DBMS_OUTPUT.PUT_LINE('Staff member and doctor inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;


BEGIN
    insert_staff_and_doctor(
        'John', 'Doe', TO_DATE('23.06.01', 'YY.MM.DD'), TO_DATE('23.12.31', 'YY.MM.DD'), 'john.doe@example.com', '123 Main St', 987654321, 3, 'Y', 'Cardiology'
    );
END;

-- Insert Staff and Techincian
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

    DBMS_OUTPUT.PUT_LINE('Staff member and technician inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    insert_staff_and_technician(
        'Jane', 'Smith', TO_DATE('23.06.01', 'YY.MM.DD'), TO_DATE('23.12.31', 'YY.MM.DD'), 'jane.smith@example.com', '456 Elm St', 111222333, 7, 'Y'
    );
END;

-- Creation of the Table to detect what role the staff member has
CREATE TABLE Hospital.STAFF_ROLES (
    EMP_ID NUMBER PRIMARY KEY,
    ROLE_TYPE VARCHAR2(10) NOT NULL
);

-- Procedure that inserts into both the Staff and Nurse tables as well as the Staff_Roles table created
CREATE OR REPLACE PROCEDURE insert_staff_with_role (
    emp_fname VARCHAR2,
    emp_lname VARCHAR2,
    date_joining DATE,
    date_seperation DATE,
    email VARCHAR2,
    address VARCHAR2,
    ssn NUMBER,
    iddepartment NUMBER,
    is_active_status VARCHAR2,
    role_type VARCHAR2
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

    -- Insert role information into the STAFF_ROLES table
    INSERT INTO Hospital.STAFF_ROLES (EMP_ID, ROLE_TYPE) VALUES (emp_id, role_type);

    DBMS_OUTPUT.PUT_LINE('Staff member and role inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
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

-- Trigger for Inserting a Staff Member and a Nurse
CREATE OR REPLACE TRIGGER trg_insert_staff_and_nurse
AFTER INSERT ON Hospital.STAFF
FOR EACH ROW
DECLARE
    role_type VARCHAR2(10);
BEGIN
    -- Get the role type from the STAFF_ROLES table
    SELECT ROLE_TYPE INTO role_type FROM Hospital.STAFF_ROLES WHERE EMP_ID = :NEW.EMP_ID;

    -- If the role type is 'NURSE', call the insert_staff_and_nurse procedure
    IF role_type = 'NURSE' THEN
        insert_staff_and_nurse(
            :NEW.EMP_FNAME,
            :NEW.EMP_LNAME,
            :NEW.DATE_JOINING,
            :NEW.DATE_SEPERATION,
            :NEW.EMAIL,
            :NEW.ADDRESS,
            :NEW.SSN,
            :NEW.IDDEPARTMENT,
            :NEW.IS_ACTIVE_STATUS
        );
    END IF;
END;


BEGIN
    insert_staff_with_role(
        'Francisco', 'Claudino', TO_DATE('23.06.01', 'YY.MM.DD'), TO_DATE('23.12.31', 'YY.MM.DD'), 'claudino@gmail.com', 'A minha casa', 123456789, 5, 'Y', 'NURSE'
    );
END;

-- Trigger to insert Staff and Doctor
CREATE OR REPLACE TRIGGER trg_insert_staff_and_doctor
AFTER INSERT ON Hospital.STAFF
FOR EACH ROW
DECLARE
    role_type VARCHAR2(10);
BEGIN
    -- Get the role type from the STAFF_ROLES table
    SELECT ROLE_TYPE INTO role_type FROM Hospital.STAFF_ROLES WHERE EMP_ID = :NEW.EMP_ID;

    -- If the role type is 'DOCTOR', call the insert_staff_and_doctor procedure
    IF role_type = 'DOCTOR' THEN
        insert_staff_and_doctor(
            :NEW.EMP_FNAME,
            :NEW.EMP_LNAME,
            :NEW.DATE_JOINING,
            :NEW.DATE_SEPERATION,
            :NEW.EMAIL,
            :NEW.ADDRESS,
            :NEW.SSN,
            :NEW.IDDEPARTMENT,
            :NEW.IS_ACTIVE_STATUS,
            'Qualifications'  -- Replace with actual qualifications
        );
    END IF;
END;

BEGIN
    insert_staff_with_role(
        'John', 'Doe', TO_DATE('23.06.01', 'YY.MM.DD'), TO_DATE('23.12.31', 'YY.MM.DD'), 'john.doe@example.com', '123 Main St', 987654321, 3, 'Y', 'DOCTOR'
    );
END;

-- Trigger to insert staff and technician
CREATE OR REPLACE TRIGGER trg_insert_staff_and_technician
AFTER INSERT ON Hospital.STAFF
FOR EACH ROW
DECLARE
    role_type VARCHAR2(10);
BEGIN
    -- Get the role type from the STAFF_ROLES table
    SELECT ROLE_TYPE INTO role_type FROM Hospital.STAFF_ROLES WHERE EMP_ID = :NEW.EMP_ID;

    -- If the role type is 'TECHNICIAN', call the insert_staff_and_technician procedure
    IF role_type = 'TECHNICIAN' THEN
        insert_staff_and_technician(
            :NEW.EMP_FNAME,
            :NEW.EMP_LNAME,
            :NEW.DATE_JOINING,
            :NEW.DATE_SEPERATION,
            :NEW.EMAIL,
            :NEW.ADDRESS,
            :NEW.SSN,
            :NEW.IDDEPARTMENT,
            :NEW.IS_ACTIVE_STATUS
        );
    END IF;
END;

BEGIN
    insert_staff_with_role(
        'Jane', 'Smith', TO_DATE('23.06.01', 'YY.MM.DD'), TO_DATE('23.12.31', 'YY.MM.DD'), 'jane.smith@example.com', '456 Elm St', 111222333, 7, 'Y', 'TECHNICIAN'
    );
END;

---------------------------------------------------------------------------------------------------------------

-- UPDATES

-- Update Staff Member
CREATE OR REPLACE PROCEDURE UpdateStaffInfoProc (
    p_emp_id          IN NUMBER,
    p_emp_fname       IN VARCHAR2,
    p_emp_lname       IN VARCHAR2,
    p_date_joining    IN DATE,
    p_date_seperation IN DATE,
    p_email           IN VARCHAR2,
    p_address         IN VARCHAR2,
    p_ssn             IN NUMBER,
    p_iddepartment    IN NUMBER,
    p_is_active_status IN VARCHAR2
) IS
BEGIN
  UPDATE Hospital.Staff
  SET emp_fname       = p_emp_fname,
      emp_lname       = p_emp_lname,
      date_joining    = p_date_joining,
      date_seperation = p_date_seperation,
      email           = p_email,
      address         = p_address,
      ssn             = p_ssn,
      iddepartment    = p_iddepartment,
      is_active_status = p_is_active_status
  WHERE emp_id = p_emp_id;
END UpdateStaffInfoProc;

BEGIN
  UpdateStaffInfoProc(
    p_emp_id          => 1,
    p_emp_fname       => 'John',
    p_emp_lname       => 'Doe',
    p_date_joining    => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
    p_date_seperation => TO_DATE('2023-12-31', 'YYYY-MM-DD'),
    p_email           => 'john.doe@example.com',
    p_address         => '123 Main St',
    p_ssn             => 123456789,
    p_iddepartment    => 2,
    p_is_active_status => 'Y'
  );
END;

-- Update Department
CREATE OR REPLACE PROCEDURE UpdateDepartmentInfoProc (
    p_iddepartment IN NUMBER,
    p_dept_head    IN VARCHAR2,
    p_dept_name    IN VARCHAR2,
    p_emp_count    IN NUMBER
) IS
BEGIN
  UPDATE Hospital.Department
  SET dept_head    = p_dept_head,
      dept_name    = p_dept_name,
      emp_count    = p_emp_count
  WHERE iddepartment = p_iddepartment;
END UpdateDepartmentInfoProc;

BEGIN
  UpdateDepartmentInfoProc(
    p_iddepartment => 1,
    p_dept_head    => 'Dr. Smith',
    p_dept_name    => 'Cardiology',
    p_emp_count    => 50
  );
END;

-- Update Nurse não faz sentido, pois a tabela só tem Id

-- Update Doctor
CREATE OR REPLACE PROCEDURE UpdateDoctorInfoProc (
    p_emp_id        IN NUMBER,
    p_qualifications IN VARCHAR2
) IS
BEGIN
  UPDATE Hospital.Doctor
  SET qualifications = p_qualifications
  WHERE emp_id = p_emp_id;
END UpdateDoctorInfoProc;

BEGIN
  UpdateDoctorInfoProc(
    p_emp_id        => 1,
    p_qualifications => 'Cardiology'
  );
END;

-- Update Technician não faz sentido, pois a tabela só tem Id

-- Update Staff and Nurse
CREATE OR REPLACE PROCEDURE UpdateStaffAndNurse (
    p_emp_id          IN NUMBER,
    p_emp_fname       IN VARCHAR2,
    p_emp_lname       IN VARCHAR2,
    p_date_joining    IN DATE,
    p_date_seperation IN DATE,
    p_email           IN VARCHAR2,
    p_address         IN VARCHAR2,
    p_ssn             IN NUMBER,
    p_iddepartment    IN NUMBER,
    p_is_active_status IN VARCHAR2,
    p_staff_emp_id    IN NUMBER
) IS
BEGIN
    -- Update the staff table
    UPDATE Hospital.Staff
    SET emp_fname       = p_emp_fname,
        emp_lname       = p_emp_lname,
        date_joining    = p_date_joining,
        date_seperation = p_date_seperation,
        email           = p_email,
        address         = p_address,
        ssn             = p_ssn,
        iddepartment    = p_iddepartment,
        is_active_status = p_is_active_status
    WHERE emp_id = p_emp_id;

    -- Update the nurse table
    UPDATE Hospital.Nurse
    SET staff_emp_id = p_staff_emp_id
    WHERE staff_emp_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Record updated successfully in Hospital.Staff and Hospital.Nurse');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
  UpdateStaffAndNurse(
    p_emp_id          => 1,
    p_emp_fname       => 'John',
    p_emp_lname       => 'Doe',
    p_date_joining    => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
    p_date_seperation => TO_DATE('2023-12-31', 'YYYY-MM-DD'),
    p_email           => 'john.doe@example.com',
    p_address         => '123 Main St',
    p_ssn             => 123456789,
    p_iddepartment    => 2,
    p_is_active_status => 'Y',
    p_staff_emp_id    => 1
  );
END;

-- Update Staff and Doctor
CREATE OR REPLACE PROCEDURE UpdateStaffAndDoctor (
    p_emp_id          IN NUMBER,
    p_emp_fname       IN VARCHAR2,
    p_emp_lname       IN VARCHAR2,
    p_date_joining    IN DATE,
    p_date_seperation IN DATE,
    p_email           IN VARCHAR2,
    p_address         IN VARCHAR2,
    p_ssn             IN NUMBER,
    p_iddepartment    IN NUMBER,
    p_is_active_status IN VARCHAR2
) IS
    v_qualifications VARCHAR2(45);
BEGIN
    -- Fetch qualifications from the Doctor table
    SELECT qualifications INTO v_qualifications
    FROM Hospital.Doctor
    WHERE emp_id = p_emp_id;

    -- Update the staff table
    UPDATE Hospital.Staff
    SET emp_fname       = p_emp_fname,
        emp_lname       = p_emp_lname,
        date_joining    = p_date_joining,
        date_seperation = p_date_seperation,
        email           = p_email,
        address         = p_address,
        ssn             = p_ssn,
        iddepartment    = p_iddepartment,
        is_active_status = p_is_active_status
    WHERE emp_id = p_emp_id;

    -- Update the doctor table
    UPDATE Hospital.Doctor
    SET qualifications = v_qualifications
    WHERE emp_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Record updated successfully in Hospital.Staff and Hospital.Doctor');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
  UpdateStaffAndDoctor(
    p_emp_id          => 1,
    p_emp_fname       => 'Jane',
    p_emp_lname       => 'Smith',
    p_date_joining    => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
    p_date_seperation => TO_DATE('2023-12-31', 'YYYY-MM-DD'),
    p_email           => 'jane.smith@example.com',
    p_address         => '456 Elm St',
    p_ssn             => 987654321,
    p_iddepartment    => 3,
    p_is_active_status => 'Y',
    p_qualifications  => 'Cardiology'
  );
END;

-- Update Staff and Technician
CREATE OR REPLACE PROCEDURE UpdateStaffAndTechnician (
    p_emp_id          IN NUMBER,
    p_emp_fname       IN VARCHAR2,
    p_emp_lname       IN VARCHAR2,
    p_date_joining    IN DATE,
    p_date_seperation IN DATE,
    p_email           IN VARCHAR2,
    p_address         IN VARCHAR2,
    p_ssn             IN NUMBER,
    p_iddepartment    IN NUMBER,
    p_is_active_status IN VARCHAR2,
    p_staff_emp_id    IN NUMBER
) IS
BEGIN
    -- Update the staff table
    UPDATE Hospital.Staff
    SET emp_fname       = p_emp_fname,
        emp_lname       = p_emp_lname,
        date_joining    = p_date_joining,
        date_seperation = p_date_seperation,
        email           = p_email,
        address         = p_address,
        ssn             = p_ssn,
        iddepartment    = p_iddepartment,
        is_active_status = p_is_active_status
    WHERE emp_id = p_emp_id;

    -- Update the technician table
    UPDATE Hospital.Technician
    SET staff_emp_id = p_staff_emp_id
    WHERE staff_emp_id = p_emp_id;

    DBMS_OUTPUT.PUT_LINE('Record updated successfully in Hospital.Staff and Hospital.Technician');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
  UpdateStaffAndTechnician(
    p_emp_id          => 1,
    p_emp_fname       => 'Michael',
    p_emp_lname       => 'Brown',
    p_date_joining    => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
    p_date_seperation => TO_DATE('2023-12-31', 'YYYY-MM-DD'),
    p_email           => 'michael.brown@example.com',
    p_address         => '789 Oak St',
    p_ssn             => 112233445,
    p_iddepartment    => 4,
    p_is_active_status => 'Y',
    p_staff_emp_id    => 1
  );
END;

-- Trigger to Update Department
CREATE OR REPLACE TRIGGER trg_update_department
BEFORE UPDATE ON Hospital.Department
FOR EACH ROW
BEGIN
    UpdateDepartmentInfoProc(
        p_iddepartment => :NEW.iddepartment,
        p_dept_head    => :NEW.dept_head,
        p_dept_name    => :NEW.dept_name,
        p_emp_count    => :NEW.emp_count
    );
END;

-- Assume there is a record in Hospital.Department with iddepartment = 1
UPDATE Hospital.Department
SET dept_head = 'New Head', dept_name = 'New Department Name', emp_count = 100
WHERE iddepartment = 1;

-- Trigger to Update Staff and Nurse
CREATE OR REPLACE TRIGGER trg_update_staff_and_nurse
BEFORE UPDATE ON Hospital.Staff
FOR EACH ROW
BEGIN
    -- Assuming a matching record in the Nurse table
    UpdateStaffAndNurse(
        p_emp_id          => :NEW.emp_id,
        p_emp_fname       => :NEW.emp_fname,
        p_emp_lname       => :NEW.emp_lname,
        p_date_joining    => :NEW.date_joining,
        p_date_seperation => :NEW.date_seperation,
        p_email           => :NEW.email,
        p_address         => :NEW.address,
        p_ssn             => :NEW.ssn,
        p_iddepartment    => :NEW.iddepartment,
        p_is_active_status => :NEW.is_active_status,
        p_staff_emp_id    => :NEW.emp_id
    );
END;

-- Assume there is a record in Hospital.Staff with emp_id = 1
UPDATE Hospital.Staff
SET emp_fname = 'Updated FirstName', emp_lname = 'Updated LastName', date_joining = TO_DATE('2023-01-01', 'YYYY-MM-DD'),
    date_seperation = TO_DATE('2023-12-31', 'YYYY-MM-DD'), email = 'updated.email@example.com', address = 'Updated Address',
    ssn = 123456789, iddepartment = 2, is_active_status = 'Y'
WHERE emp_id = 1;


-- Trigger to Update Staff and Doctor
CREATE OR REPLACE TRIGGER trg_update_staff_and_doctor
BEFORE UPDATE ON Hospital.Staff
FOR EACH ROW
BEGIN
    -- Assuming a matching record in the Doctor table
    UpdateStaffAndDoctor(
        p_emp_id          => :NEW.emp_id,
        p_emp_fname       => :NEW.emp_fname,
        p_emp_lname       => :NEW.emp_lname,
        p_date_joining    => :NEW.date_joining,
        p_date_seperation => :NEW.date_seperation,
        p_email           => :NEW.email,
        p_address         => :NEW.address,
        p_ssn             => :NEW.ssn,
        p_iddepartment    => :NEW.iddepartment,
        p_is_active_status => :NEW.is_active_status
    );
END;

-- Assume there is a record in Hospital.Staff with emp_id = 2, and a matching record in Hospital.Doctor
UPDATE Hospital.Staff
SET emp_fname = 'Updated Doctor FirstName', emp_lname = 'Updated Doctor LastName', date_joining = TO_DATE('2023-02-01', 'YYYY-MM-DD'),
    date_seperation = TO_DATE('2023-11-30', 'YYYY-MM-DD'), email = 'doctor.email@example.com', address = 'Doctor Address',
    ssn = 987654321, iddepartment = 3, is_active_status = 'N'
WHERE emp_id = 2;


-- Trigger to Update Staff and Technician
CREATE OR REPLACE TRIGGER trg_update_staff_and_technician
BEFORE UPDATE ON Hospital.Staff
FOR EACH ROW
BEGIN
    -- Assuming a matching record in the Technician table
    UpdateStaffAndTechnician(
        p_emp_id          => :NEW.emp_id,
        p_emp_fname       => :NEW.emp_fname,
        p_emp_lname       => :NEW.emp_lname,
        p_date_joining    => :NEW.date_joining,
        p_date_seperation => :NEW.date_seperation,
        p_email           => :NEW.email,
        p_address         => :NEW.address,
        p_ssn             => :NEW.ssn,
        p_iddepartment    => :NEW.iddepartment,
        p_is_active_status => :NEW.is_active_status,
        p_staff_emp_id    => :NEW.emp_id
    );
END;

-- Assume there is a record in Hospital.Staff with emp_id = 3, and a matching record in Hospital.Technician
UPDATE Hospital.Staff
SET emp_fname = 'Updated Technician FirstName', emp_lname = 'Updated Technician LastName', date_joining = TO_DATE('2023-03-01', 'YYYY-MM-DD'),
    date_seperation = TO_DATE('2023-10-31', 'YYYY-MM-DD'), email = 'technician.email@example.com', address = 'Technician Address',
    ssn = 123987456, iddepartment = 4, is_active_status = 'Y'
WHERE emp_id = 3;

---------------------------------------------------------------------------------------------------------------

-- DELETES

-- Delete a Staff Member and Nurse
CREATE OR REPLACE PROCEDURE DeleteStaffAndNurse (
    p_emp_id IN NUMBER
) IS
BEGIN
    -- Delete from Nurse table if exists
    DELETE FROM Hospital.Nurse
    WHERE staff_emp_id = p_emp_id;

    -- Delete from Staff table
    DELETE FROM Hospital.Staff
    WHERE emp_id = p_emp_id;

    -- Decrement the employee count in the Department table
    UPDATE Hospital.Department
    SET emp_count = emp_count - 1
    WHERE iddepartment = (
        SELECT iddepartment
        FROM Hospital.Staff
        WHERE emp_id = p_emp_id
    );

    DBMS_OUTPUT.PUT_LINE('Staff member and related nurse record deleted successfully, department count updated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    DeleteStaffAndNurse(p_emp_id => 1);
END;

-- Delete a Staff Member and Doctor
CREATE OR REPLACE PROCEDURE DeleteStaffAndDoctor (
    p_emp_id IN NUMBER
) IS
BEGIN
    -- Delete from Doctor table if exists
    DELETE FROM Hospital.Doctor
    WHERE emp_id = p_emp_id;

    -- Delete from Staff table
    DELETE FROM Hospital.Staff
    WHERE emp_id = p_emp_id;

    -- Decrement the employee count in the Department table
    UPDATE Hospital.Department
    SET emp_count = emp_count - 1
    WHERE iddepartment = (
        SELECT iddepartment
        FROM Hospital.Staff
        WHERE emp_id = p_emp_id
    );

    DBMS_OUTPUT.PUT_LINE('Staff member and related doctor record deleted successfully, department count updated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    DeleteStaffAndDoctor(p_emp_id => 2);
END;

-- Delete a Staff Member and Technician
CREATE OR REPLACE PROCEDURE DeleteStaffAndTechnician (
    p_emp_id IN NUMBER
) IS
BEGIN
    -- Delete from Technician table if exists
    DELETE FROM Hospital.Technician
    WHERE staff_emp_id = p_emp_id;

    -- Delete from Staff table
    DELETE FROM Hospital.Staff
    WHERE emp_id = p_emp_id;

    -- Decrement the employee count in the Department table
    UPDATE Hospital.Department
    SET emp_count = emp_count - 1
    WHERE iddepartment = (
        SELECT iddepartment
        FROM Hospital.Staff
        WHERE emp_id = p_emp_id
    );

    DBMS_OUTPUT.PUT_LINE('Staff member and related technician record deleted successfully, department count updated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

BEGIN
    DeleteStaffAndTechnician(p_emp_id => 3);
END;

-- Delete a Department
CREATE OR REPLACE PROCEDURE DeleteDepartmentAndUpdateStaff (
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

BEGIN
    DeleteDepartmentAndUpdateStaff(p_iddepartment => 1);
END;