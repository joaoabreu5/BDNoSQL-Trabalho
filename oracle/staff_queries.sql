-- Delete 
-- Check for existing dependencies first
-- SELECT * FROM USER_DEPENDENCIES WHERE REFERENCED_NAME = 'STAFFROW';

-- Drop the table type if it exists
-- DROP TYPE StaffTable;

-- Drop the object type if it exists
-- DROP TYPE StaffRow;

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

CREATE OR REPLACE FUNCTION GetEmployeeCountPerDepartment
  RETURN DepartmentEmployeeCountTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS EMPLOYEE_COUNT
    FROM Hospital.Staff s
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentEmployeeCountRow(rec.DEPARTMENT_ID, rec.EMPLOYEE_COUNT));
  END LOOP;
  RETURN;
END GetEmployeeCountPerDepartment;

SELECT * FROM TABLE(GetEmployeeCountPerDepartment());

-- 16)
-- Get the number of Nurses per Department
CREATE OR REPLACE TYPE DepartmentNurseCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    NURSE_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentNurseCountTable IS TABLE OF DepartmentNurseCountRow;

CREATE OR REPLACE FUNCTION GetNurseCountPerDepartment
  RETURN DepartmentNurseCountTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS NURSE_COUNT
    FROM Hospital.Nurse n
    JOIN Hospital.Staff s ON n.STAFF_EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentNurseCountRow(rec.DEPARTMENT_ID, rec.NURSE_COUNT));
  END LOOP;
  RETURN;
END GetNurseCountPerDepartment;

SELECT * FROM TABLE(GetNurseCountPerDepartment());


-- 17)
-- Get the number of Doctors per Department
CREATE OR REPLACE TYPE DepartmentDoctorCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    DOCTOR_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentDoctorCountTable IS TABLE OF DepartmentDoctorCountRow;

CREATE OR REPLACE FUNCTION GetDoctorCountPerDepartment
  RETURN DepartmentDoctorCountTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS DOCTOR_COUNT
    FROM Hospital.Doctor d
    JOIN Hospital.Staff s ON d.EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentDoctorCountRow(rec.DEPARTMENT_ID, rec.DOCTOR_COUNT));
  END LOOP;
  RETURN;
END GetDoctorCountPerDepartment;

SELECT * FROM TABLE(GetDoctorCountPerDepartment());

-- 18)
-- Get the number of Technicians per Department
CREATE OR REPLACE TYPE DepartmentTechniciansCountRow AS OBJECT (
    DEPARTMENT_ID NUMBER,
    TECHNICIANS_COUNT NUMBER
);

CREATE OR REPLACE TYPE DepartmentTechniciansCountTable IS TABLE OF DepartmentTechniciansCountRow;

CREATE OR REPLACE FUNCTION GetTechniciansCountPerDepartment
  RETURN DepartmentTechniciansCountTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.IDDEPARTMENT AS DEPARTMENT_ID, COUNT(*) AS TECHNICIANS_COUNT
    FROM Hospital.Technician t
    JOIN Hospital.Staff s ON t.STAFF_EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentTechniciansCountRow(rec.DEPARTMENT_ID, rec.TECHNICIANS_COUNT));
  END LOOP;
  RETURN;
END GetTechniciansCountPerDepartment;

SELECT * FROM TABLE(GetTechniciansCountPerDepartment());

---------------------------------------------------------------------------------------------------------------

-- INSERTS

-- Insert Staff Member
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDPATIENT value
    SELECT COALESCE(MAX(EMP_ID), 0) INTO max_id FROM Admin.STAFF;

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
    INSERT INTO Admin.STAFF (
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
    -- Determine the current maximum IDPATIENT value
    SELECT COALESCE(MAX(IDDEPARTMENT), 0) INTO max_id FROM Admin.DEPARTMENT;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE department_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_hospital_department (
    dept_head VARCHAR2,
    dept_name VARCHAR2,
    emp_count NUMBER
) IS
BEGIN
    INSERT INTO Admin.DEPARTMENT (
        IDDEPARTMENT, DEPT_HEAD, DEPT_NAME, EMP_COUNT
    )
    VALUES (
        department_seq_new.NEXTVAL, dept_head, dept_name,emp_count
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Admin.DEPARTMENT');
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
    SELECT COALESCE(MAX(STAFF_EMP_ID), 0) INTO max_id FROM Admin.NURSE;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE nurse_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_nurse (
    staff_emp_id NUMBER
) IS
BEGIN
    INSERT INTO Admin.NURSE (
        STAFF_EMP_ID
    )
    VALUES (
        staff_emp_id
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Admin.NURSE');
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
    SELECT COALESCE(MAX(EMP_ID), 0) INTO max_id FROM Admin.DOCTOR;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE doctor_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_doctor (
    emp_id NUMBER,
    qualifications VARCHAR2
) IS
BEGIN
    INSERT INTO Admin.DOCTOR (
        EMP_ID, QUALIFICATIONS
    )
    VALUES (
        emp_id, qualifications
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Admin.DOCTOR');
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
    SELECT COALESCE(MAX(STAFF_EMP_ID), 0) INTO max_id FROM Admin.TECHNICIAN;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE technician_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_technician (
    staff_emp_id NUMBER
) IS
BEGIN
    INSERT INTO Admin.TECHNICIAN (
        STAFF_EMP_ID
    )
    VALUES (
        staff_emp_id
    );
    DBMS_OUTPUT.PUT_LINE('Record inserted successfully into Admin.TECHNICIAN');
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
    INSERT INTO Admin.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert into nurse table
    INSERT INTO Admin.NURSE (STAFF_EMP_ID) VALUES (emp_id);

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
    INSERT INTO Admin.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert into doctor table
    INSERT INTO Admin.DOCTOR (EMP_ID, QUALIFICATIONS) VALUES (emp_id, qualifications);

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
    INSERT INTO Admin.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert into technician table
    INSERT INTO Admin.TECHNICIAN (STAFF_EMP_ID) VALUES (emp_id);

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
CREATE TABLE Admin.STAFF_ROLES (
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
    INSERT INTO Admin.STAFF (
        EMP_ID, EMP_FNAME, EMP_LNAME, DATE_JOINING, DATE_SEPERATION, EMAIL, ADDRESS, SSN, IDDEPARTMENT, IS_ACTIVE_STATUS
    )
    VALUES (
        staff_seq_new.NEXTVAL, emp_fname, emp_lname, date_joining, date_seperation, email, address, ssn, iddepartment, is_active_status
    )
    RETURNING EMP_ID INTO emp_id;

    -- Insert role information into the STAFF_ROLES table
    INSERT INTO Admin.STAFF_ROLES (EMP_ID, ROLE_TYPE) VALUES (emp_id, role_type);

    DBMS_OUTPUT.PUT_LINE('Staff member and role inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger for Inserting a Staff Member and a Nurse
CREATE OR REPLACE TRIGGER trg_insert_staff_and_nurse
AFTER INSERT ON Admin.STAFF
FOR EACH ROW
DECLARE
    role_type VARCHAR2(10);
BEGIN
    -- Get the role type from the STAFF_ROLES table
    SELECT ROLE_TYPE INTO role_type FROM Admin.STAFF_ROLES WHERE EMP_ID = :NEW.EMP_ID;

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
AFTER INSERT ON Admin.STAFF
FOR EACH ROW
DECLARE
    role_type VARCHAR2(10);
BEGIN
    -- Get the role type from the STAFF_ROLES table
    SELECT ROLE_TYPE INTO role_type FROM Admin.STAFF_ROLES WHERE EMP_ID = :NEW.EMP_ID;

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
AFTER INSERT ON Admin.STAFF
FOR EACH ROW
DECLARE
    role_type VARCHAR2(10);
BEGIN
    -- Get the role type from the STAFF_ROLES table
    SELECT ROLE_TYPE INTO role_type FROM Admin.STAFF_ROLES WHERE EMP_ID = :NEW.EMP_ID;

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


---------------------------------------------------------------------------------------------------------------

-- DELETES