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
        Admin.Staff s
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
    FROM Admin.Department d
    JOIN Admin.Staff s ON d.IDDEPARTMENT = s.IDDEPARTMENT
    WHERE s.EMP_ID = emp_id
  ) LOOP
    PIPE ROW (DepartmentRow(rec.IDDEPARTMENT, rec.DEPT_HEAD, rec.DEPT_NAME, rec.EMP_COUNT));
  END LOOP;
  RETURN;
END AllInfoDepartment;

SELECT * FROM TABLE(AllInfoDepartment(82));

-- 3)
-- ESTA NÃO FAZ MUITO SENTIDO
-- All info about Hospital.Nurse
CREATE OR REPLACE TYPE NurseRow AS OBJECT (
    STAFF_EMP_ID NUMBER(38, 0)
);

CREATE OR REPLACE TYPE NurseTable IS TABLE OF NurseRow;

CREATE OR REPLACE FUNCTION AllInfoNurse(emp_id IN NUMBER)
  RETURN NurseTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT n.staff_emp_id
    FROM Admin.Nurse n
    WHERE n.STAFF_EMP_ID = emp_id
  ) LOOP
    PIPE ROW (NurseRow(rec.STAFF_EMP_ID));
  END LOOP;
  RETURN;
END AllInfoNurse;

SELECT * FROM TABLE(AllInfoNurse(1));

-- 4)
-- All info about Hospital.Doctor
CREATE OR REPLACE TYPE DoctorRow AS OBJECT (
    EMP_ID NUMBER(38, 0),
    QUALIFICATIONS VARCHAR2(45 BYTE)
);

CREATE OR REPLACE TYPE DoctorTable IS TABLE OF DoctorRow;

CREATE OR REPLACE FUNCTION AllInfoDoctor(emp_id IN NUMBER)
  RETURN DoctorTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT D.emp_id, D.qualifications
    FROM Admin.Doctor d
    WHERE d.EMP_ID = emp_id
  ) LOOP
    PIPE ROW (DoctorRow(rec.EMP_ID, rec.QUALIFICATIONS));
  END LOOP;
  RETURN;
END AllInfoDoctor;

SELECT * FROM TABLE(AllInfoDoctor(1));

-- 5)
-- ESTA NÃO FAZ MUITO SENTIDO
-- All info about Hospital.Technician
CREATE OR REPLACE TYPE TechnicianRow AS OBJECT (
    STAFF_EMP_ID NUMBER(38, 0)
);

CREATE OR REPLACE TYPE TechnicianTable IS TABLE OF TechnicianRow;

CREATE OR REPLACE FUNCTION AllInfoTechnician(emp_id IN NUMBER)
  RETURN TechnicianTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT t.staff_emp_id
    FROM Admin.Technician t
    WHERE t.STAFF_EMP_ID = emp_id
  ) LOOP
    PIPE ROW (TechnicianRow(rec.STAFF_EMP_ID));
  END LOOP;
  RETURN;
END AllInfoTechnician;

SELECT * FROM TABLE(AllInfoTechnician(1));

-- 6)
-- Combined type for all staff information
CREATE OR REPLACE TYPE StaffAllInfoRow AS OBJECT (
    EMP_ID NUMBER(38, 0),
    EMP_FNAME VARCHAR2(45 BYTE),
    EMP_LNAME VARCHAR2(45 BYTE),
    DATE_JOINING DATE,
    DATE_SEPERATION DATE,
    EMAIL VARCHAR2(50 BYTE),
    ADDRESS VARCHAR2(50 BYTE),
    SSN NUMBER(38, 0),
    IDDEPARTMENT NUMBER(38, 0),
    IS_ACTIVE_STATUS VARCHAR2(1),
    DEPT_HEAD    VARCHAR2(45 BYTE),
    DEPT_NAME    VARCHAR2(45 BYTE),
    EMP_COUNT    NUMBER(38, 0),
    QUALIFICATIONS VARCHAR2(45 BYTE)
);

CREATE OR REPLACE TYPE StaffAllInfoTable IS TABLE OF StaffAllInfoRow;

CREATE OR REPLACE FUNCTION AllInfoStaff(emp_id IN NUMBER)
  RETURN StaffAllInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.EMP_ID, s.EMP_FNAME, s.EMP_LNAME, s.DATE_JOINING, s.DATE_SEPERATION,
           s.EMAIL, s.ADDRESS, s.SSN, s.IS_ACTIVE_STATUS,
           d.IDDEPARTMENT, d.DEPT_HEAD, d.DEPT_NAME, d.EMP_COUNT,
           m.QUALIFICATIONS
    FROM Admin.Staff s
    LEFT JOIN Admin.Department d ON s.IDDEPARTMENT = d.IDDEPARTMENT
    LEFT JOIN Admin.Nurse n ON s.EMP_ID = n.STAFF_EMP_ID
    LEFT JOIN Admin.Doctor m ON s.EMP_ID = m.EMP_ID
    LEFT JOIN Admin.Technician t ON s.EMP_ID = t.STAFF_EMP_ID
    WHERE s.EMP_ID = emp_id
  ) LOOP
    PIPE ROW (StaffAllInfoRow(
      rec.EMP_ID, rec.EMP_FNAME, rec.EMP_LNAME, rec.DATE_JOINING, rec.DATE_SEPERATION,
      rec.EMAIL, rec.ADDRESS, rec.SSN, rec.IDDEPARTMENT, rec.IS_ACTIVE_STATUS,
      rec.DEPT_HEAD, rec.DEPT_NAME, rec.EMP_COUNT, rec.QUALIFICATIONS
    ));
  END LOOP;
  RETURN;
END AllInfoStaff;

SELECT * FROM TABLE(AllInfoStaff(1));

-- 7)
-- Get Staff Members by Date_Joining
CREATE OR REPLACE FUNCTION AllInfoStaffByDateJoining(date_joining IN DATE)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM Admin.Staff s
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


-- 8)
-- Get Staff Members by Date_Seperation
CREATE OR REPLACE FUNCTION AllInfoStaffByDateSeperation(date_seperation IN DATE)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM Admin.Staff s
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

-- 9)
-- Get Staff Members that are active or inactive
CREATE OR REPLACE FUNCTION AllInfoStaffByStatus(is_active_status IN VARCHAR2)
  RETURN StaffTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT s.emp_id, s.emp_fname, s.emp_lname,
        s.date_joining, s.date_seperation, s.email, s.address,
        s.ssn, s.iddepartment, s.is_active_status
    FROM Admin.Staff s
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

-- 10)
-- Get the number of Nurses
SELECT COUNT(*) AS nurse_count FROM Admin.Nurse;

-- 11)
-- Get the number of Doctors
SELECT COUNT(*) AS doctor_count FROM Admin.Doctor;

-- 12)
-- Get the number of Technicians
SELECT COUNT(*) AS technician_count FROM Admin.Technician;

-- 13)
-- Get all the diferent qualifications
SELECT DISTINCT QUALIFICATIONS FROM Admin.Doctor;

-- 14)
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
    FROM Admin.Doctor d
    WHERE d.EMP_ID = doctor_id
  ) LOOP
    PIPE ROW (QualificationRow(rec.QUALIFICATIONS));
  END LOOP;
  RETURN;
END GetDoctorQualifications;

-- Query to retrieve all qualifications from a specific doctor
SELECT * FROM TABLE(GetDoctorQualifications(1));


-- 15)
-- Get the number of Departments
SELECT COUNT(*) AS department_count FROM Admin.Department;

-- 16)
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
    FROM Admin.Staff s
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentEmployeeCountRow(rec.DEPARTMENT_ID, rec.EMPLOYEE_COUNT));
  END LOOP;
  RETURN;
END GetEmployeeCountPerDepartment;

SELECT * FROM TABLE(GetEmployeeCountPerDepartment());

-- 17)
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
    FROM Admin.Nurse n
    JOIN Admin.Staff s ON n.STAFF_EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentNurseCountRow(rec.DEPARTMENT_ID, rec.NURSE_COUNT));
  END LOOP;
  RETURN;
END GetNurseCountPerDepartment;

SELECT * FROM TABLE(GetNurseCountPerDepartment());


-- 18)
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
    FROM Admin.Doctor d
    JOIN Admin.Staff s ON d.EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentDoctorCountRow(rec.DEPARTMENT_ID, rec.DOCTOR_COUNT));
  END LOOP;
  RETURN;
END GetDoctorCountPerDepartment;

SELECT * FROM TABLE(GetDoctorCountPerDepartment());

-- 19)
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
    FROM Admin.Technician t
    JOIN Admin.Staff s ON t.STAFF_EMP_ID = s.EMP_ID
    GROUP BY s.IDDEPARTMENT
  ) LOOP
    PIPE ROW (DepartmentTechniciansCountRow(rec.DEPARTMENT_ID, rec.TECHNICIANS_COUNT));
  END LOOP;
  RETURN;
END GetTechniciansCountPerDepartment;

SELECT * FROM TABLE(GetTechniciansCountPerDepartment());