-- 1)
-- Listar todas as prescrições para um paciente específico
CREATE OR REPLACE TYPE PrescriptionRowNew AS OBJECT (
  IDPRESCRIPTION NUMBER(38,0),
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER(10,2),
  IDMEDICINE NUMBER(38,0),
  IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE PrescriptionTableNew IS TABLE OF PrescriptionRowNew;

CREATE OR REPLACE FUNCTION PrescriptionsForPatient(patient_id IN NUMBER)
  RETURN PrescriptionTableNew PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDMEDICINE, p.IDEPISODE
    FROM Hospital.Prescription p
    JOIN Hospital.Episode e ON p.IDEPISODE = e.IDEPISODE
    WHERE e.PATIENT_IDPATIENT = patient_id
  ) LOOP
    PIPE ROW (PrescriptionRowNew(rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE, rec.IDMEDICINE, rec.IDEPISODE));
  END LOOP;
  RETURN;
END PrescriptionsForPatient;

SELECT * FROM TABLE(PrescriptionsForPatient(25));

-- 4)
-- List patients allocated to a specific room
CREATE OR REPLACE TYPE RoomPatientsRow AS OBJECT (
  IDPATIENT NUMBER(38,0),
  PATIENT_NAME VARCHAR2(45),
  ROOM_ID NUMBER(38,0)
);

CREATE OR REPLACE TYPE RoomPatientsTable IS TABLE OF RoomPatientsRow;

CREATE OR REPLACE FUNCTION ListPatientsInRoom(
  room_id IN NUMBER
) RETURN RoomPatientsTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPATIENT, p.PATIENT_FNAME || ' ' || p.PATIENT_LNAME AS PATIENT_NAME, r.IDROOM
    FROM Hospital.Patient p
    JOIN Hospital.Episode e ON p.IDPATIENT = e.PATIENT_IDPATIENT
    JOIN Hospital.Hospitalization h ON e.IDEPISODE = h.IDEPISODE
    JOIN Hospital.Room r ON h.ROOM_IDROOM = r.IDROOM
    WHERE r.IDROOM = room_id
  ) LOOP
    PIPE ROW (RoomPatientsRow(rec.IDPATIENT, rec.PATIENT_NAME, rec.IDROOM));
  END LOOP;
  RETURN;
END ListPatientsInRoom;

SELECT * FROM TABLE(ListPatientsInRoom(1));

-- 1)
-- List All Hospitalizations for a Specific Patient
CREATE OR REPLACE TYPE HospitalizationRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_ID NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0)
);

CREATE OR REPLACE TYPE HospitalizationTable IS TABLE OF HospitalizationRow;

CREATE OR REPLACE FUNCTION ListHospitalizationsForPatient(
  patient_id IN NUMBER
) RETURN HospitalizationTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT h.IDEPISODE, h.ADMISSION_DATE, h.DISCHARGE_DATE, h.ROOM_IDROOM, h.RESPONSIBLE_NURSE
    FROM Hospital.Hospitalization h
    JOIN Hospital.Episode e ON h.IDEPISODE = e.IDEPISODE
    WHERE e.PATIENT_IDPATIENT = patient_id
  ) LOOP
    PIPE ROW (HospitalizationRow(rec.IDEPISODE, rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.ROOM_IDROOM, rec.RESPONSIBLE_NURSE));
  END LOOP;
  RETURN;
END ListHospitalizationsForPatient;

SELECT * FROM TABLE(ListHospitalizationsForPatient(25));

-- 4)
-- Listar hospitalizações por enfermeira responsável.
CREATE OR REPLACE TYPE HospitalizationByNurseRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_ID NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0),
  NURSE_NAME VARCHAR2(45)
);

CREATE OR REPLACE TYPE HospitalizationByNurseTable IS TABLE OF HospitalizationByNurseRow;

CREATE OR REPLACE FUNCTION ListHospitalizationsByNurse(
  nurse_id IN NUMBER
) RETURN HospitalizationByNurseTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT h.IDEPISODE, h.ADMISSION_DATE, h.DISCHARGE_DATE, h.ROOM_IDROOM, h.RESPONSIBLE_NURSE, 
           s.EMP_FNAME || ' ' || s.EMP_LNAME AS NURSE_NAME
    FROM Hospital.Hospitalization h
    JOIN Hospital.Nurse nur ON h.RESPONSIBLE_NURSE = nur.STAFF_EMP_ID
    JOIN Hospital.Staff s ON nur.STAFF_EMP_ID = s.EMP_ID
    WHERE h.RESPONSIBLE_NURSE = nurse_id
  ) LOOP
    PIPE ROW (HospitalizationByNurseRow(rec.IDEPISODE, rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.ROOM_IDROOM, rec.RESPONSIBLE_NURSE, rec.NURSE_NAME));
  END LOOP;
  RETURN;
END ListHospitalizationsByNurse;

SELECT * FROM TABLE(ListHospitalizationsByNurse(5));

-- 1)
-- Listar todos os episódios médicos de um paciente específico.
CREATE OR REPLACE TYPE EpisodeRowNew AS OBJECT (
  IDEPISODE NUMBER(38,0),
  PATIENT_IDPATIENT NUMBER(38,0)
);

CREATE OR REPLACE TYPE EpisodeTableNew IS TABLE OF EpisodeRowNew;

CREATE OR REPLACE FUNCTION ListEpisodesForPatient(
  patient_id IN NUMBER
) RETURN EpisodeTableNew PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT IDEPISODE, PATIENT_IDPATIENT
    FROM Hospital.Episode
    WHERE PATIENT_IDPATIENT = patient_id
  ) LOOP
    PIPE ROW (EpisodeRowNew(rec.IDEPISODE, rec.PATIENT_IDPATIENT));
  END LOOP;
  RETURN;
END ListEpisodesForPatient;

SELECT * FROM TABLE(ListEpisodesForPatient(25));

-- 2)
-- Listar episódios médicos por tipo de condição.
CREATE OR REPLACE TYPE EpisodeByConditionRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  PATIENT_IDPATIENT NUMBER(38,0),
  PATIENT_NAME VARCHAR2(50 BYTE),
  CONDITION VARCHAR2(25 BYTE)
);

CREATE OR REPLACE TYPE EpisodeByConditionTable IS TABLE OF EpisodeByConditionRow;

CREATE OR REPLACE FUNCTION ListEpisodesByCondition(
  condition_type IN VARCHAR2
) RETURN EpisodeByConditionTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT e.IDEPISODE, e.PATIENT_IDPATIENT, p.PATIENT_FNAME || ' ' || p.PATIENT_LNAME AS PATIENT_NAME, mh.CONDITION
    FROM HOSPITAL.EPISODE e
    JOIN HOSPITAL.PATIENT p ON e.PATIENT_IDPATIENT = p.IDPATIENT
    JOIN HOSPITAL.MEDICAL_HISTORY mh ON p.IDPATIENT = mh.IDPATIENT
    WHERE mh.CONDITION = condition_type
  ) LOOP
    PIPE ROW (EpisodeByConditionRow(rec.IDEPISODE, rec.PATIENT_IDPATIENT, rec.PATIENT_NAME, rec.CONDITION));
  END LOOP;
  RETURN;
END ListEpisodesByCondition;

-- Example usage:
SELECT * FROM TABLE(ListEpisodesByCondition('Diabetes'));

-- 3)
-- Listar todos os episódios médicos tratados por um médico específico.
CREATE OR REPLACE TYPE EpisodeByDoctorRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  PATIENT_IDPATIENT NUMBER(38,0),
  DOCTOR_ID NUMBER(38,0),
  DOCTOR_NAME VARCHAR2(50 BYTE),
  QUALIFICATIONS VARCHAR2(50 BYTE)
);

CREATE OR REPLACE TYPE EpisodeByDoctorTable IS TABLE OF EpisodeByDoctorRow;

CREATE OR REPLACE FUNCTION ListEpisodesByDoctor(
  doctor_id IN NUMBER
) RETURN EpisodeByDoctorTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT e.IDEPISODE, e.PATIENT_IDPATIENT, d.EMP_ID AS DOCTOR_ID, 
           s.EMP_FNAME || ' ' || s.EMP_LNAME AS DOCTOR_NAME, 
           d.QUALIFICATIONS
    FROM HOSPITAL.EPISODE e
    JOIN HOSPITAL.APPOINTMENT a ON e.IDEPISODE = a.IDEPISODE
    JOIN HOSPITAL.DOCTOR d ON a.IDDOCTOR = d.EMP_ID
    JOIN HOSPITAL.STAFF s ON d.EMP_ID = s.EMP_ID
    WHERE d.EMP_ID = doctor_id
  ) LOOP
    PIPE ROW (EpisodeByDoctorRow(rec.IDEPISODE, rec.PATIENT_IDPATIENT, rec.DOCTOR_ID, rec.DOCTOR_NAME, rec.QUALIFICATIONS));
  END LOOP;
  RETURN;
END ListEpisodesByDoctor;

-- Example usage:
SELECT * FROM TABLE(ListEpisodesByDoctor(1));


-- Listar todos os exames laboratoriais para um paciente específico.
-- Listar exames baseados no técnico responsável.
-- Listar todas as faturas para um paciente específico.
-- Listar todas as faturas emitidas por um médico específico.
-- Listar todas as consultas agendadas para um paciente específico.
-- Listar consultas baseadas no médico responsável.
-- Listar os Appointment para um dado Medico (por dia)

