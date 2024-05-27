-- 1)
-- All info about Hospital.Medicine
CREATE OR REPLACE TYPE MedicineRow AS OBJECT (
  IDMEDICINE NUMBER(38,0),
  MEDICINE_NAME VARCHAR2(45),
  QUANTITY NUMBER(38,0),
  UNIT_COST NUMBER(10,2)
);

CREATE OR REPLACE TYPE MedicineTable IS TABLE OF MedicineRow;

CREATE OR REPLACE FUNCTION AllInfoMedicine(id_medicine IN NUMBER)
  RETURN MedicineTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT m.IDMEDICINE, m.M_NAME, m.M_QUANTITY, m.M_COST
    FROM Hospital.Medicine m
    WHERE m.IDMEDICINE = id_medicine
  ) LOOP
    PIPE ROW (MedicineRow(rec.IDMEDICINE, rec.M_NAME, rec.M_QUANTITY, rec.M_COST));
  END LOOP;
  RETURN;
END AllInfoMedicine;

SELECT * FROM TABLE(AllInfoMedicine(1));

-- 2)
-- All info about Hospital.Prescription
CREATE OR REPLACE TYPE PrescriptionRow AS OBJECT (
  IDPRESCRIPTION NUMBER(38,0),
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER(38,0),
  IDPATIENT NUMBER(38,0),
  IDMEDICINE NUMBER(38,0)
);

CREATE OR REPLACE TYPE PrescriptionTable IS TABLE OF PrescriptionRow;

CREATE OR REPLACE FUNCTION AllInfoPrescription(id_prescription IN NUMBER)
  RETURN PrescriptionTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDMEDICINE, p.IDEPISODE
    FROM Hospital.Prescription p
    WHERE p.IDPRESCRIPTION = id_prescription
  ) LOOP
    PIPE ROW (PrescriptionRow(rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE,
                              rec.IDEPISODE, rec.IDMEDICINE));
  END LOOP;
  RETURN;
END AllInfoPrescription;

SELECT * FROM TABLE(AllInfoPrescription(1));

-- 3)
-- All info about Hospital.Episode
CREATE OR REPLACE TYPE EpisodeRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  PATIENT_IDPATIENT NUMBER(38,0)
);

CREATE OR REPLACE TYPE EpisodeTable IS TABLE OF EpisodeRow;

CREATE OR REPLACE FUNCTION AllInfoEpisode(id_episode IN NUMBER)
  RETURN EpisodeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT e.IDEPISODE, e.PATIENT_IDPATIENT
    FROM Hospital.Episode e
    WHERE e.IDEPISODE = id_episode
  ) LOOP
    PIPE ROW (EpisodeRow(rec.IDEPISODE, rec.PATIENT_IDPATIENT));
  END LOOP;
  RETURN;
END AllInfoEpisode;

SELECT * FROM TABLE(AllInfoEpisode(1));

-- 4)
-- All info about Hospital.Bill
CREATE OR REPLACE TYPE BillRow AS OBJECT (
  IDBILL NUMBER(38,0),
  ROOM_COST NUMBER(10,2),
  TEST_COST NUMBER(10,2),
  OTHER_CHARGES NUMBER(10,2),
  TOTAL NUMBER(10,2),
  IDEPISODE NUMBER(38,0),
  REGISTERED_AT TIMESTAMP(6),
  PAYMENT_STATUS VARCHAR2(10)
);

CREATE OR REPLACE TYPE BillTable IS TABLE OF BillRow;

CREATE OR REPLACE FUNCTION AllInfoBill(id_bill IN NUMBER)
  RETURN BillTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT b.IDBILL, b.ROOM_COST, b.TEST_COST, b.OTHER_CHARGES, b.TOTAL, b.IDEPISODE, b.REGISTERED_AT, b.PAYMENT_STATUS
    FROM Hospital.Bill b
    WHERE b.IDBILL = id_bill
  ) LOOP
    PIPE ROW (BillRow(rec.IDBILL, rec.ROOM_COST, rec.TEST_COST, rec.OTHER_CHARGES, rec.TOTAL, rec.IDEPISODE, rec.REGISTERED_AT, rec.PAYMENT_STATUS));
  END LOOP;
  RETURN;
END AllInfoBill;

SELECT * FROM TABLE(AllInfoBill(1));

-- 5)
-- All info about Hospital.Room
CREATE OR REPLACE TYPE RoomRow AS OBJECT (
  IDROOM NUMBER(38,0),
  ROOM_TYPE VARCHAR2(45),
  ROOM_COST NUMBER(10,2)
);

CREATE OR REPLACE TYPE RoomTable IS TABLE OF RoomRow;

CREATE OR REPLACE FUNCTION AllInfoRoom(id_room IN NUMBER)
  RETURN RoomTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT r.IDROOM, r.ROOM_TYPE, r.ROOM_COST
    FROM Hospital.Room r
    WHERE r.IDROOM = id_room
  ) LOOP
    PIPE ROW (RoomRow(rec.IDROOM, rec.ROOM_TYPE, rec.ROOM_COST));
  END LOOP;
  RETURN;
END AllInfoRoom;

SELECT * FROM TABLE(AllInfoRoom(1));

-- 6)
-- All info about Hospital.Hospitalization
CREATE OR REPLACE TYPE HospitalizationRow AS OBJECT (
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_IDROOM NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0),
  IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE HospitalizationTable IS TABLE OF HospitalizationRow;

CREATE OR REPLACE FUNCTION AllInfoHospitalization(id_episode IN NUMBER)
  RETURN HospitalizationTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT h.ADMISSION_DATE, h.DISCHARGE_DATE, h.ROOM_IDROOM, h.RESPONSIBLE_NURSE, h.IDEPISODE
    FROM Hospital.Hospitalization h
    WHERE h.IDEPISODE = id_episode
  ) LOOP
    PIPE ROW (HospitalizationRow(rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.ROOM_IDROOM, rec.RESPONSIBLE_NURSE, rec.IDEPISODE));
  END LOOP;
  RETURN;
END AllInfoHospitalization;

SELECT * FROM TABLE(AllInfoHospitalization(3));

-- TODO
-- 7)
-- All info about Hospital.Appointment
-- CREATE OR REPLACE TYPE AppointmentRow AS OBJECT (
--   IDAPPOINTMENT NUMBER(10,0),
--   SCHEDULED_DATE DATE,
--   APPOINTMENT_DATE DATE,
--   APPOINTMENT_TIME VARCHAR2(8),
--   IDEPISODE NUMBER(10,0),
--   IDDOCTOR NUMBER(10,0)
-- );

-- CREATE OR REPLACE TYPE AppointmentTable IS TABLE OF AppointmentRow;

-- CREATE OR REPLACE FUNCTION AllInfoAppointment(id_appointment IN NUMBER)
--   RETURN AppointmentTable PIPELINED IS
-- BEGIN
--   FOR rec IN (
--     SELECT a.IDAPPOINTMENT, a.SCHEDULED_DATE, a.APPOINTMENT_DATE, a.APPOINTMENT_TIME,
--            a.IDEPISODE, a.IDDOCTOR
--     FROM Hospital.Appointment a
--     WHERE a.IDAPPOINTMENT = id_appointment
--   ) LOOP
--     PIPE ROW (AppointmentRow(rec.IDAPPOINTMENT, rec.SCHEDULED_DATE, rec.APPOINTMENT_DATE,
--                              rec.APPOINTMENT_TIME, rec.IDEPISODE, rec.IDDOCTOR));
--   END LOOP;
--   RETURN;
-- END AllInfoAppointment;

-- SELECT * FROM TABLE(AllInfoAppointment(1));

-- 8)
-- All info about Hospital.Lab_Screening
-- CREATE OR REPLACE TYPE LabScreeningRow AS OBJECT (
--   IDLAB NUMBER(38,0),
--   TEST_COST NUMBER(10,2),
--   TEST_DATE DATE,
--   IDTECHNICIAN NUMBER(38,0),
--   EPISODE_IDEPISODE NUMBER(38,0)
-- );

-- CREATE OR REPLACE TYPE LabScreeningTable IS TABLE OF LabScreeningRow;

-- CREATE OR REPLACE FUNCTION AllInfoLabScreening(id_labs IN NUMBER)
--   RETURN LabScreeningTable PIPELINED IS
-- BEGIN
--   FOR rec IN (
--     SELECT lab.ID_LAB, lab.TEST_COST, lab.TEST_DATE, lab.ID_TECHNICIAN AS IDTECHNICIAN, lab.EPISODE_ID AS EPISODE_IDEPISODE
--     FROM Hospital.Lab_Screening lab
--     WHERE lab.ID_LAB = id_labs
--   ) LOOP
--     PIPE ROW (LabScreeningRow(rec.IDLAB, rec.TEST_COST, rec.TEST_DATE, rec.IDTECHNICIAN,
--                               rec.EPISODE_IDEPISODE));
--   END LOOP;
--   RETURN;
-- END AllInfoLabScreening;

-- SELECT * FROM TABLE(AllInfoLabScreening(1));

