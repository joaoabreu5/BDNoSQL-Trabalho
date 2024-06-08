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
-- All info about only Hospital.Episode
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

-- All info about Hospital.Episode + Hospital.Appointment 
CREATE OR REPLACE TYPE EpisodeRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  PATIENT_IDPATIENT NUMBER(38,0),
  SCHEDULED_ON DATE,
  APPOINTMENT_DATE DATE,
  APPOINTMENT_TIME VARCHAR2(5 BYTE),
  IDDOCTOR NUMBER(38,0)
);

CREATE OR REPLACE TYPE EpisodeTable IS TABLE OF EpisodeRow;

CREATE OR REPLACE FUNCTION AllInfoEpisode(id_episode IN NUMBER)
  RETURN EpisodeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT e.IDEPISODE, e.PATIENT_IDPATIENT, a.SCHEDULED_ON, a.APPOINTMENT_DATE, a.APPOINTMENT_TIME, a.IDDOCTOR
    FROM Hospital.Episode e
    JOIN Hospital.Appointment a ON e.IDEPISODE = a.IDEPISODE
    WHERE e.IDEPISODE = id_episode
  ) LOOP
    PIPE ROW (EpisodeRow(rec.IDEPISODE, rec.PATIENT_IDPATIENT, rec.SCHEDULED_ON, rec.APPOINTMENT_DATE, rec.APPOINTMENT_TIME, rec.IDDOCTOR));
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

-- 7)
-- All info about Hospital.Lab_Screening
CREATE OR REPLACE TYPE LabScreeningRow AS OBJECT (
  IDLAB NUMBER(38,0),
  TEST_COST NUMBER(10,2),
  TEST_DATE DATE,
  IDTECHNICIAN NUMBER(38,0),
  EPISODE_IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE LabScreeningTable IS TABLE OF LabScreeningRow;

CREATE OR REPLACE FUNCTION AllInfoLabScreening(id_labs IN NUMBER)
  RETURN LabScreeningTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT lab.LAB_ID, lab.TEST_COST, lab.TEST_DATE, lab.IDTECHNICIAN, lab.EPISODE_IDEPISODE
    FROM Hospital.Lab_Screening lab
    WHERE lab.LAB_ID = id_labs
  ) LOOP
    PIPE ROW (LabScreeningRow(rec.LAB_ID, rec.TEST_COST, rec.TEST_DATE, rec.IDTECHNICIAN,
                              rec.EPISODE_IDEPISODE));
  END LOOP;
  RETURN;
END AllInfoLabScreening;

SELECT * FROM TABLE(AllInfoLabScreening(1));

-- 8)
-- Information from all the tables
CREATE OR REPLACE TYPE EpisodeInfoRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  PATIENT_IDPATIENT NUMBER(38,0),
  SCHEDULED_ON DATE,
  APPOINTMENT_DATE DATE,
  APPOINTMENT_TIME VARCHAR2(5 BYTE),
  IDDOCTOR NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_IDROOM NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0),
  IDPRESCRIPTION NUMBER(38,0),
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER(38,0),
  IDMEDICINE NUMBER(38,0),
  IDBILL NUMBER(38,0),
  ROOM_COST NUMBER(10,2),
  TEST_COST NUMBER(10,2),
  OTHER_CHARGES NUMBER(10,2),
  TOTAL NUMBER(10,2),
  REGISTERED_AT DATE,
  PAYMENT_STATUS VARCHAR2(10 BYTE),
  LAB_ID NUMBER(38,0),
  LAB_TEST_COST NUMBER(10,2),
  IDTECHNICIAN NUMBER(38,0)
);

CREATE OR REPLACE TYPE EpisodeInfoTable IS TABLE OF EpisodeInfoRow;

CREATE OR REPLACE FUNCTION GetAllEpisodeInfo(id_episode IN NUMBER)
  RETURN EpisodeInfoTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT 
        e.IDEPISODE,
        e.PATIENT_IDPATIENT,
        a.SCHEDULED_ON,
        a.APPOINTMENT_DATE,
        a.APPOINTMENT_TIME,
        a.IDDOCTOR,
        h.ADMISSION_DATE,
        h.DISCHARGE_DATE,
        h.ROOM_IDROOM,
        h.RESPONSIBLE_NURSE,
        p.IDPRESCRIPTION,
        p.PRESCRIPTION_DATE,
        p.DOSAGE,
        p.IDMEDICINE,
        b.IDBILL,
        b.ROOM_COST,
        b.TEST_COST,
        b.OTHER_CHARGES,
        b.TOTAL,
        b.REGISTERED_AT,
        b.PAYMENT_STATUS,
        l.LAB_ID,
        l.TEST_COST AS LAB_TEST_COST,
        l.IDTECHNICIAN
    FROM 
        Hospital.Episode e
    LEFT JOIN 
        Hospital.Appointment a ON e.IDEPISODE = a.IDEPISODE
    LEFT JOIN 
        Hospital.Hospitalization h ON e.IDEPISODE = h.IDEPISODE
    LEFT JOIN 
        Hospital.Prescription p ON e.IDEPISODE = p.IDEPISODE
    LEFT JOIN 
        Hospital.Bill b ON e.IDEPISODE = b.IDEPISODE
    LEFT JOIN 
        Hospital.Lab_Screening l ON e.IDEPISODE = l.EPISODE_IDEPISODE
    WHERE 
        e.IDEPISODE = id_episode
  ) LOOP
    PIPE ROW (EpisodeInfoRow(
      rec.IDEPISODE,
      rec.PATIENT_IDPATIENT,
      rec.SCHEDULED_ON,
      rec.APPOINTMENT_DATE,
      rec.APPOINTMENT_TIME,
      rec.IDDOCTOR,
      rec.ADMISSION_DATE,
      rec.DISCHARGE_DATE,
      rec.ROOM_IDROOM,
      rec.RESPONSIBLE_NURSE,
      rec.IDPRESCRIPTION,
      rec.PRESCRIPTION_DATE,
      rec.DOSAGE,
      rec.IDMEDICINE,
      rec.IDBILL,
      rec.ROOM_COST,
      rec.TEST_COST,
      rec.OTHER_CHARGES,
      rec.TOTAL,
      rec.REGISTERED_AT,
      rec.PAYMENT_STATUS,
      rec.LAB_ID,
      rec.LAB_TEST_COST,
      rec.IDTECHNICIAN
    ));
  END LOOP;
  RETURN;
END GetAllEpisodeInfo;

SELECT * FROM TABLE(GetAllEpisodeInfo(2));


------------------------------------------------------------------------------------------------------------

-- Hospital.Medicine
-- 1) Listar por nome
SELECT M.M_NAME
FROM Hospital.Medicine M
ORDER BY M.NAME;

-- 2) Listar por quantidade
SELECT M.M_QUANTITY
FROM Hospital.Medicine M
ORDER BY M.M_QUANTITY;

-- 3) Listar por custo
SELECT M.M_COST
FROM Hospital.Medicine M
ORDER BY M.M_COST;

-- 4)
SELECT M.M_NAME, M.M_QUANTITY, M.M_COST
FROM Hospital.Medicine M
ORDER BY M.M_NAME;

-- 5) Listar medicação por quantidade disponível
SELECT M.M_NAME, M.M_QUANTITY
FROM Hospital.Medicine M
ORDER BY M.M_QUANTITY;

-- 6) Listar medicações por faixa de custo
SELECT M.M_NAME, M.M_COST,
       CASE 
           WHEN M.M_COST < 50 THEN 'Low'
           WHEN M.M_COST BETWEEN 50 AND 100 THEN 'Medium'
           ELSE 'High'
       END AS Cost_Range
FROM Hospital.Medicine M
ORDER BY M.M_COST;

-- 7) Listar todas as medicações que estão prestes a esgotar (quantidade baixa)
CREATE OR REPLACE TYPE MedicineRowNew AS OBJECT (
  M_NAME VARCHAR2(45),
  M_QUANTITY NUMBER(38,0)
);

CREATE OR REPLACE TYPE MedicineTableNew IS TABLE OF MedicineRowNew;

CREATE OR REPLACE FUNCTION LowStockMedicines(threshold IN NUMBER)
  RETURN MedicineTableNew PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT M.M_NAME, M.M_QUANTITY
    FROM Hospital.Medicine M
    WHERE M.M_QUANTITY <= threshold
    ORDER BY M.M_QUANTITY
  ) LOOP
    PIPE ROW (MedicineRowNew(rec.M_NAME, rec.M_QUANTITY));
  END LOOP;
  RETURN;
END LowStockMedicines;

SELECT * FROM TABLE(LowStockMedicines(25));

-- 8)
SELECT SUM(M.M_QUANTITY * M.M_COST) AS Total_Inventory_Cost
FROM Hospital.Medicine M;

------------------------------------------------------------------------------------------------------------

-- Hospital.Prescription

-- 2)
-- Listar prescrições por medicação
CREATE OR REPLACE TYPE PrescriptionRowNew AS OBJECT (
  IDPRESCRIPTION NUMBER(38,0),
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER(10,2),
  IDMEDICINE NUMBER(38,0),
  IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE PrescriptionTableNew IS TABLE OF PrescriptionRowNew;

CREATE OR REPLACE FUNCTION PrescriptionsByMedicine(medicine_id IN NUMBER)
  RETURN PrescriptionTableNew PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDMEDICINE, p.IDEPISODE
    FROM Hospital.Prescription p
    WHERE p.IDMEDICINE = medicine_id
  ) LOOP
    PIPE ROW (PrescriptionRowNew(rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE, rec.IDMEDICINE, rec.IDEPISODE));
  END LOOP;
  RETURN;
END PrescriptionsByMedicine;

SELECT * FROM TABLE(PrescriptionsByMedicine(1));

-- 3) 
-- Listar prescrições por intervalo de datas
CREATE OR REPLACE TYPE PrescriptionRow AS OBJECT (
  IDPRESCRIPTION NUMBER(38,0),
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER(10,2),
  IDMEDICINE NUMBER(38,0),
  IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE PrescriptionTable IS TABLE OF PrescriptionRow;

CREATE OR REPLACE FUNCTION PrescriptionsByDateRange(start_date IN DATE, end_date IN DATE)
  RETURN PrescriptionTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDMEDICINE, p.IDEPISODE
    FROM Hospital.Prescription p
    WHERE p.PRESCRIPTION_DATE BETWEEN start_date AND end_date
  ) LOOP
    PIPE ROW (PrescriptionRow(rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE, rec.IDMEDICINE, rec.IDEPISODE));
  END LOOP;
  RETURN;
END PrescriptionsByDateRange;

SELECT * FROM TABLE(PrescriptionsByDateRange(TO_DATE('23.08.16', 'YY.MM.DD'), TO_DATE('23.08.29', 'YY.MM.DD')));

-- 4)
-- Listar prescrições por médico responsável
CREATE OR REPLACE FUNCTION PrescriptionsByDoctor(doctor_id IN NUMBER)
  RETURN PrescriptionTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDMEDICINE, p.IDEPISODE
    FROM Hospital.Prescription p
    JOIN Hospital.Appointment a ON p.IDEPISODE = a.IDEPISODE
    WHERE a.IDDOCTOR = doctor_id
  ) LOOP
    PIPE ROW (PrescriptionRow(rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE, rec.IDMEDICINE, rec.IDEPISODE));
  END LOOP;
  RETURN;
END PrescriptionsByDoctor;

SELECT * FROM TABLE(PrescriptionsByDoctor(1));

------------------------------------------------------------------------------------------------------------

-- Hospital.Room

-- 1)
-- List all rooms by type
CREATE OR REPLACE TYPE RoomTypeRow AS OBJECT (
  IDROOM NUMBER(38,0),
  ROOM_TYPE VARCHAR2(25),
  ROOM_COST NUMBER(10,2)
);

CREATE OR REPLACE TYPE RoomTypeTable IS TABLE OF RoomTypeRow;

CREATE OR REPLACE PROCEDURE ListRoomsByTypeProc (rooms OUT RoomTypeTable) IS
BEGIN
  rooms := RoomTypeTable(); -- Initialize the collection
  FOR rec IN (
    SELECT IDROOM, ROOM_TYPE, ROOM_COST
    FROM Hospital.Room
  ) LOOP
    rooms.EXTEND;
    rooms(rooms.COUNT) := RoomTypeRow(rec.IDROOM, rec.ROOM_TYPE, rec.ROOM_COST);
  END LOOP;
END ListRoomsByTypeProc;

DECLARE
  rooms RoomTypeTable;
BEGIN
  ListRoomsByTypeProc(rooms);
  FOR i IN 1..rooms.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('IDROOM: ' || rooms(i).IDROOM || ', ROOM_TYPE: ' || rooms(i).ROOM_TYPE || ', ROOM_COST: ' || rooms(i).ROOM_COST);
  END LOOP;
END;


-- 2)
-- List room occupations by date range
CREATE OR REPLACE TYPE RoomOccupationRow AS OBJECT (
  IDROOM NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  PATIENT_ID NUMBER(38,0)
);

CREATE OR REPLACE TYPE RoomOccupationTable IS TABLE OF RoomOccupationRow;

CREATE OR REPLACE FUNCTION ListRoomOccupationsByDateRange(start_date IN DATE, end_date IN DATE)
    RETURN RoomOccupationTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT r.IDROOM, h.ADMISSION_DATE, h.DISCHARGE_DATE, e.PATIENT_IDPATIENT
    FROM Hospital.Room r
    JOIN Hospital.Hospitalization h ON r.IDROOM = h.ROOM_IDROOM
    JOIN Hospital.Episode e ON h.IDEPISODE = e.IDEPISODE
    WHERE h.ADMISSION_DATE BETWEEN start_date AND end_date
    OR h.DISCHARGE_DATE BETWEEN start_date AND end_date
  ) LOOP
    PIPE ROW (RoomOccupationRow(rec.IDROOM, rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.PATIENT_IDPATIENT));
  END LOOP;
  RETURN;
END ListRoomOccupationsByDateRange;

SELECT * FROM TABLE(ListRoomOccupationsByDateRange(TO_DATE('19.04.17', 'YY.MM.DD'), TO_DATE( '19.04.20', 'YY.MM.DD')));

-- 3)
-- List currently occupied rooms
CREATE OR REPLACE TYPE OccupiedRoomRow AS OBJECT (
  IDROOM NUMBER(38,0),
  ROOM_TYPE VARCHAR2(25),
  ROOM_COST NUMBER(10,2),
  PATIENT_ID NUMBER(38,0)
);

CREATE OR REPLACE TYPE OccupiedRoomTable IS TABLE OF OccupiedRoomRow;

CREATE OR REPLACE PROCEDURE ListCurrentlyOccupiedRoomsProc (rooms OUT OccupiedRoomTable) IS
BEGIN
  rooms := OccupiedRoomTable();
  FOR rec IN (
    SELECT r.IDROOM, r.ROOM_TYPE, r.ROOM_COST, e.PATIENT_IDPATIENT
    FROM Hospital.Room r
    JOIN Hospital.Hospitalization h ON r.IDROOM = h.ROOM_IDROOM
    JOIN Hospital.Episode e ON h.IDEPISODE = e.IDEPISODE
    WHERE h.DISCHARGE_DATE IS NULL
  ) LOOP
    rooms.EXTEND;
    rooms(rooms.COUNT) := OccupiedRoomRow(rec.IDROOM, rec.ROOM_TYPE, rec.ROOM_COST, rec.PATIENT_IDPATIENT);
  END LOOP;
END ListCurrentlyOccupiedRoomsProc;


DECLARE
  rooms OccupiedRoomTable;
BEGIN
  ListCurrentlyOccupiedRoomsProc(rooms);
  FOR i IN 1..rooms.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('IDROOM: ' || rooms(i).IDROOM || 
                         ', ROOM_TYPE: ' || rooms(i).ROOM_TYPE || 
                         ', ROOM_COST: ' || rooms(i).ROOM_COST || 
                         ', PATIENT_ID: ' || rooms(i).PATIENT_ID);
  END LOOP;
END;


-- 5)
-- List All Distinct Room Types and Room Costs Ordered
CREATE OR REPLACE TYPE DistinctRoomTypeRow AS OBJECT (
  ROOM_TYPE VARCHAR2(25),
  ROOM_COST NUMBER(10,2)
);

CREATE OR REPLACE TYPE DistinctRoomTypeTable IS TABLE OF DistinctRoomTypeRow;

CREATE OR REPLACE PROCEDURE ListDistinctRoomTypesAndCostsProc (rooms OUT DistinctRoomTypeTable) IS
BEGIN
  rooms := DistinctRoomTypeTable();
  FOR rec IN (
    SELECT DISTINCT ROOM_TYPE, MIN(ROOM_COST) AS ROOM_COST
    FROM Hospital.Room
    GROUP BY ROOM_TYPE
    ORDER BY ROOM_COST
  ) LOOP
    rooms.EXTEND;
    rooms(rooms.COUNT) := DistinctRoomTypeRow(rec.ROOM_TYPE, rec.ROOM_COST);
  END LOOP;
END ListDistinctRoomTypesAndCostsProc;


DECLARE
  rooms DistinctRoomTypeTable;
BEGIN
  ListDistinctRoomTypesAndCostsProc(rooms);
  FOR i IN 1..rooms.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('ROOM_TYPE: ' || rooms(i).ROOM_TYPE || ', ROOM_COST: ' || rooms(i).ROOM_COST);
  END LOOP;
END;


------------------------------------------------------------------------------------------------------------

-- Hospital.Hospitalization

-- 2)
-- List Hospitalizations by Date Range
CREATE OR REPLACE TYPE HospitalizationByDateRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_ID NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0)
);

CREATE OR REPLACE TYPE HospitalizationByDateTable IS TABLE OF HospitalizationByDateRow;

CREATE OR REPLACE FUNCTION ListHospitalizationsByDateRange(start_date IN DATE, end_date IN DATE)
    RETURN HospitalizationByDateTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT IDEPISODE, ADMISSION_DATE, DISCHARGE_DATE, ROOM_IDROOM, RESPONSIBLE_NURSE
    FROM Hospital.Hospitalization
    WHERE ADMISSION_DATE BETWEEN start_date AND end_date
    OR DISCHARGE_DATE BETWEEN start_date AND end_date
  ) LOOP
    PIPE ROW (HospitalizationByDateRow(rec.IDEPISODE, rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.ROOM_IDROOM, rec.RESPONSIBLE_NURSE));
  END LOOP;
  RETURN;
END ListHospitalizationsByDateRange;

SELECT * FROM TABLE(ListHospitalizationsByDateRange(TO_DATE('19.04.17', 'YY.MM.DD'), TO_DATE( '19.04.20', 'YY.MM.DD')));

-- 3)
-- Listar hospitalizações por tipo de sala.
CREATE OR REPLACE TYPE HospitalizationByRoomTypeRow AS OBJECT (
  IDEPISODE NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_ID NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0),
  ROOM_TYPE VARCHAR2(25)
);

CREATE OR REPLACE TYPE HospitalizationByRoomTypeTable IS TABLE OF HospitalizationByRoomTypeRow;

CREATE OR REPLACE FUNCTION ListHospitalizationsByRoomType(room_type IN VARCHAR2)
    RETURN HospitalizationByRoomTypeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT h.IDEPISODE, h.ADMISSION_DATE, h.DISCHARGE_DATE, h.ROOM_IDROOM, h.RESPONSIBLE_NURSE, r.ROOM_TYPE
    FROM Hospital.Hospitalization h
    JOIN Hospital.Room r ON h.ROOM_IDROOM = r.IDROOM
    WHERE r.ROOM_TYPE = room_type
  ) LOOP
    PIPE ROW (HospitalizationByRoomTypeRow(rec.IDEPISODE, rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.ROOM_IDROOM, rec.RESPONSIBLE_NURSE, rec.ROOM_TYPE));
  END LOOP;
  RETURN;
END ListHospitalizationsByRoomType;

SELECT * FROM TABLE(ListHospitalizationsByRoomType('ICU'));

------------------------------------------------------------------------------------------------------------

-- Hospital.Appointment:

-- Listar consultas por intervalo de datas.
SELECT 
    *
FROM 
    Hospital.Appointment
WHERE 
    SCHEDULED_ON BETWEEN TO_DATE('13.11.20', 'YY.MM.DD') AND TO_DATE('21.05.21', 'YY.MM.DD');

-- Lista de Total de Appointments (Numero) 
CREATE OR REPLACE FUNCTION GetTotalAppointments RETURN NUMBER IS
  total_appointments NUMBER;
BEGIN
  SELECT COUNT(*) INTO total_appointments FROM Hospital.Appointment;
  RETURN total_appointments;
END GetTotalAppointments;

-- Test the function
SELECT GetTotalAppointments FROM DUAL;

------------------------------------------------------------------------------------------------------------

-- Hospital.Bill:

-- 3)
-- Find total billing amount for a given episode:
CREATE OR REPLACE FUNCTION GetTotalBillingForEpisode(p_episode_id IN NUMBER)RETURN VARCHAR2 IS
  v_room_cost NUMBER;
  v_test_cost NUMBER;
  v_other_charges NUMBER;
  v_total NUMBER;
  v_result VARCHAR2(4000);
BEGIN
  SELECT SUM(ROOM_COST), SUM(TEST_COST), SUM(OTHER_CHARGES), SUM(TOTAL)
  INTO v_room_cost, v_test_cost, v_other_charges, v_total
  FROM Bill
  WHERE IDEPISODE = p_episode_id;

  v_result := 'Room Cost: ' || NVL(TO_CHAR(v_room_cost), '0') ||
              ', Test Cost: ' || NVL(TO_CHAR(v_test_cost), '0') ||
              ', Other Charges: ' || NVL(TO_CHAR(v_other_charges), '0') ||
              ', Total: ' || NVL(TO_CHAR(v_total), '0');

  RETURN v_result;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'No billing records found';
END GetTotalBillingForEpisode;

SELECT GetTotalBillingForEpisode(1) AS TotalBilling FROM DUAL;

-- Listar faturas por intervalo de datas.
SELECT *
FROM HOSPITAL.BILL
WHERE REGISTERED_AT BETWEEN TO_TIMESTAMP('2024-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND TO_TIMESTAMP('2024-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS');

-- Listar faturas por status de pagamento (ex: pendente).
CREATE OR REPLACE TYPE BillRowNew AS OBJECT (
  IDBILL NUMBER,
  ROOM_COST NUMBER,
  TEST_COST NUMBER,
  OTHER_CHARGES NUMBER,
  TOTAL NUMBER,
  IDEPISODE NUMBER,
  REGISTERED_AT TIMESTAMP,
  PAYMENT_STATUS VARCHAR2(10)
);

CREATE OR REPLACE TYPE BillTableNew IS TABLE OF BillRowNew;

CREATE OR REPLACE FUNCTION ListBillsByPaymentStatus(payment_status IN VARCHAR2)
    RETURN BillTableNew PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT IDBILL, ROOM_COST, TEST_COST, OTHER_CHARGES, TOTAL, IDEPISODE, REGISTERED_AT, PAYMENT_STATUS
    FROM HOSPITAL.BILL
    WHERE PAYMENT_STATUS = payment_status
  ) LOOP
    PIPE ROW (BillRowNew(rec.IDBILL, rec.ROOM_COST, rec.TEST_COST, rec.OTHER_CHARGES, rec.TOTAL, rec.IDEPISODE, rec.REGISTERED_AT, rec.PAYMENT_STATUS));
  END LOOP;
  RETURN;
END ListBillsByPaymentStatus;

SELECT * FROM TABLE(ListBillsByPaymentStatus('Pending'));

-- Custo Total entre Timestamps
CREATE OR REPLACE FUNCTION GetTotalCostByRegisteredDate(
  start_date IN TIMESTAMP,
  end_date IN TIMESTAMP
) RETURN NUMBER IS
  total_cost NUMBER := 0;
BEGIN
  SELECT COALESCE(SUM(TOTAL), 0)
  INTO total_cost
  FROM HOSPITAL.BILL
  WHERE REGISTERED_AT BETWEEN start_date AND end_date;

  RETURN total_cost;
END GetTotalCostByRegisteredDate;

SET SERVEROUTPUT ON;

DECLARE
  v_total_cost NUMBER;
BEGIN
  v_total_cost := GetTotalCostByRegisteredDate(
    TO_TIMESTAMP('2024-04-27 15:22:34.121765', 'YYYY-MM-DD HH24:MI:SS.FF'),
    TO_TIMESTAMP('2024-04-27 15:22:34.236851', 'YYYY-MM-DD HH24:MI:SS.FF')
  );
  DBMS_OUTPUT.PUT_LINE('Total Cost: ' || v_total_cost);
END;

-- Sum the total costs of all the bills
CREATE OR REPLACE FUNCTION GetTotalCostOfAllBills
RETURN NUMBER IS
  total_cost NUMBER := 0;
BEGIN
  SELECT COALESCE(SUM(TOTAL), 0)
  INTO total_cost
  FROM HOSPITAL.BILL;

  RETURN total_cost;
END GetTotalCostOfAllBills;

SET SERVEROUTPUT ON;

DECLARE
  v_total_cost NUMBER;
BEGIN
  v_total_cost := GetTotalCostOfAllBills();
  DBMS_OUTPUT.PUT_LINE('Total Cost of All Bills: ' || v_total_cost);
END;

------------------------------------------------------------------------------------------------------------

-- Hospital.Lab_Screening:

-- Listar exames por intervalo de datas.
SELECT *
FROM HOSPITAL.LAB_SCREENING
WHERE TEST_DATE BETWEEN TO_DATE('22.05.24', 'YY.MM.DD') AND TO_DATE('23.09.09', 'YY.MM.DD');

-- Listar testes por custo
SELECT *
FROM HOSPITAL.LAB_SCREENING
ORDER BY TEST_COST ASC;

-- Buscar LabScreening por IDEpisode
CREATE OR REPLACE TYPE LabScreeningRowNew AS OBJECT (
  IDLAB NUMBER(38,0),
  TEST_COST NUMBER(10,2),
  TEST_DATE DATE,
  IDTECHNICIAN NUMBER(38,0),
  EPISODE_IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE LabScreeningTableNew IS TABLE OF LabScreeningRowNew;


CREATE OR REPLACE FUNCTION GetLabScreeningsByEpisode(idepisode IN NUMBER)
  RETURN LabScreeningTableNew PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT LAB_ID, TEST_COST, TEST_DATE, IDTECHNICIAN, EPISODE_IDEPISODE
    FROM Hospital.Lab_Screening
    WHERE EPISODE_IDEPISODE = idepisode
  ) LOOP
    PIPE ROW (LabScreeningRowNew(rec.LAB_ID, rec.TEST_COST, rec.TEST_DATE, rec.IDTECHNICIAN, rec.EPISODE_IDEPISODE));
  END LOOP;
  RETURN;
END GetLabScreeningsByEpisode;

SELECT * FROM TABLE(GetLabScreeningsByEpisode(1));


-- Dado um Episode buscar todos as prescriptions e medicamentos
CREATE OR REPLACE TYPE MedicinePrescriptionRow AS OBJECT (
  IDMEDICINE NUMBER(38,0),
  M_NAME VARCHAR2(45),
  M_QUANTITY NUMBER(38,0),
  M_COST NUMBER(10,2),
  IDPRESCRIPTION NUMBER(38,0),
  PRESCRIPTION_DATE DATE,
  DOSAGE NUMBER(38,0),
  IDEPISODE NUMBER(38,0)
);

CREATE OR REPLACE TYPE MedicinePrescriptionTable IS TABLE OF MedicinePrescriptionRow;

CREATE OR REPLACE FUNCTION GetMedicinesAndPrescriptionsByEpisode(idepisode IN NUMBER)
  RETURN MedicinePrescriptionTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT m.IDMEDICINE, m.M_NAME, m.M_QUANTITY, m.M_COST,
           p.IDPRESCRIPTION, p.PRESCRIPTION_DATE, p.DOSAGE, p.IDEPISODE
    FROM Hospital.Medicine m
    JOIN Hospital.Prescription p ON m.IDMEDICINE = p.IDMEDICINE
    WHERE p.IDEPISODE = idepisode
  ) LOOP
    PIPE ROW (MedicinePrescriptionRow(
      rec.IDMEDICINE, rec.M_NAME, rec.M_QUANTITY, rec.M_COST,
      rec.IDPRESCRIPTION, rec.PRESCRIPTION_DATE, rec.DOSAGE, rec.IDEPISODE
    ));
  END LOOP;
  RETURN;
END GetMedicinesAndPrescriptionsByEpisode;

SELECT * FROM TABLE(GetMedicinesAndPrescriptionsByEpisode(1));


-- GetTotalBillingForPacient
CREATE OR REPLACE TYPE BillInfoRow AS OBJECT (
  IDBILL NUMBER(38,0),
  ROOM_COST NUMBER(10,2),
  TEST_COST NUMBER(10,2),
  OTHER_CHARGES NUMBER(10,2),
  TOTAL NUMBER(10,2),
  IDEPISODE NUMBER(38,0),
  REGISTERED_AT TIMESTAMP,
  PAYMENT_STATUS VARCHAR2(10),
  TOTAL_COST_SUM NUMBER(10,2)
);

CREATE OR REPLACE TYPE BillInfoTable IS TABLE OF BillInfoRow;

CREATE OR REPLACE FUNCTION GetBillInfoByPatient(idpatient IN NUMBER)
  RETURN BillInfoTable PIPELINED IS
  total_cost_sum NUMBER(10,2);
BEGIN
  SELECT SUM(TOTAL) INTO total_cost_sum
  FROM Hospital.Bill b
  JOIN Hospital.Episode e ON b.IDEPISODE = e.IDEPISODE
  WHERE e.PATIENT_IDPATIENT = idpatient;

  FOR rec IN (
    SELECT b.IDBILL, b.ROOM_COST, b.TEST_COST, b.OTHER_CHARGES, b.TOTAL, 
           b.IDEPISODE, b.REGISTERED_AT, b.PAYMENT_STATUS
    FROM Hospital.Bill b
    JOIN Hospital.Episode e ON b.IDEPISODE = e.IDEPISODE
    WHERE e.PATIENT_IDPATIENT = idpatient
  ) LOOP
    PIPE ROW (BillInfoRow(
      rec.IDBILL, rec.ROOM_COST, rec.TEST_COST, rec.OTHER_CHARGES, rec.TOTAL,
      rec.IDEPISODE, rec.REGISTERED_AT, rec.PAYMENT_STATUS, total_cost_sum
    ));
  END LOOP;
  RETURN;
END GetBillInfoByPatient;

SELECT * FROM TABLE(GetBillInfoByPatient(1));

-- Listar Hospitalazion por Ordem de Preço
CREATE OR REPLACE TYPE HospitalizationWithCostRow AS OBJECT (
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  ROOM_IDROOM NUMBER(38,0),
  IDEPISODE NUMBER(38,0),
  RESPONSIBLE_NURSE NUMBER(38,0),
  TOTAL_COST NUMBER(10,2)
);

CREATE OR REPLACE TYPE HospitalizationWithCostTable IS TABLE OF HospitalizationWithCostRow;

CREATE OR REPLACE PROCEDURE ListHospitalizationsOrderedByCost (hospitalizations OUT HospitalizationWithCostTable) IS
BEGIN
  hospitalizations := HospitalizationWithCostTable();
  
  FOR rec IN (
    SELECT h.ADMISSION_DATE, h.DISCHARGE_DATE, h.ROOM_IDROOM, h.IDEPISODE, h.RESPONSIBLE_NURSE, b.TOTAL
    FROM Hospital.Hospitalization h
    JOIN Hospital.Bill b ON h.IDEPISODE = b.IDEPISODE
    ORDER BY b.TOTAL DESC
  ) LOOP
    hospitalizations.EXTEND;
    hospitalizations(hospitalizations.COUNT) := HospitalizationWithCostRow(
      rec.ADMISSION_DATE, rec.DISCHARGE_DATE, rec.ROOM_IDROOM, rec.IDEPISODE, rec.RESPONSIBLE_NURSE, rec.TOTAL
    );
  END LOOP;
END ListHospitalizationsOrderedByCost;

DECLARE
  hospitalizations HospitalizationWithCostTable;
BEGIN
  ListHospitalizationsOrderedByCost(hospitalizations);
  FOR i IN 1..hospitalizations.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE('ADMISSION_DATE: ' || hospitalizations(i).ADMISSION_DATE ||
                         ', DISCHARGE_DATE: ' || hospitalizations(i).DISCHARGE_DATE ||
                         ', ROOM_IDROOM: ' || hospitalizations(i).ROOM_IDROOM ||
                         ', IDEPISODE: ' || hospitalizations(i).IDEPISODE ||
                         ', RESPONSIBLE_NURSE: ' || hospitalizations(i).RESPONSIBLE_NURSE ||
                         ', TOTAL_COST: ' || hospitalizations(i).TOTAL_COST);
  END LOOP;
END;


---------------------------------------------------------------------------------------------------------------

-- INSERTS

-- 1)
-- Insert Episode, Bill, Appointment, Lab Screening, Hospitalization and Prescription
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDEPISODE value
    SELECT COALESCE(MAX(IDEPISODE), 0) INTO max_id FROM Hospital.EPISODE;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE episode_seq_new';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                RAISE;
            END IF;
    END;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE episode_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_episode (
    p_patient_idpatient IN NUMBER,
    p_room_cost         IN NUMBER,
    p_test_cost         IN NUMBER,
    p_other_charges     IN NUMBER,
    p_total             IN NUMBER,
    p_payment_status    IN VARCHAR2,
    p_scheduled_on      IN DATE,
    p_appointment_date  IN DATE,
    p_appointment_time  IN VARCHAR2,
    p_iddoctor          IN NUMBER,
    p_test_date         IN DATE,
    p_idtechnician      IN NUMBER,
    p_admission_date    IN DATE,
    p_discharge_date    IN DATE,
    p_room_idroom       IN NUMBER,
    p_responsible_nurse IN NUMBER,
    p_prescription_date IN DATE,
    p_dosage            IN NUMBER,
    p_idmedicine        IN NUMBER
) IS
    v_idepisode NUMBER;
BEGIN
    -- Insert into Episode table and get the new IDEPISODE
    INSERT INTO Hospital.EPISODE (
        IDEPISODE, PATIENT_IDPATIENT
    )
    VALUES (
        episode_seq_new.NEXTVAL, p_patient_idpatient
    )
    RETURNING IDEPISODE INTO v_idepisode;

    -- Insert into Bill table
    INSERT INTO Hospital.BILL (
        IDBILL, ROOM_COST, TEST_COST, OTHER_CHARGES, TOTAL, IDEPISODE, REGISTERED_AT, PAYMENT_STATUS
    )
    VALUES (
        episode_seq_new.NEXTVAL, p_room_cost, p_test_cost, p_other_charges, p_total, v_idepisode, SYSTIMESTAMP, p_payment_status
    );

    -- Insert into Appointment table
    INSERT INTO Hospital.APPOINTMENT (
        SCHEDULED_ON, APPOINTMENT_DATE, APPOINTMENT_TIME, IDDOCTOR, IDEPISODE
    )
    VALUES (
        p_scheduled_on, p_appointment_date, p_appointment_time, p_iddoctor, v_idepisode
    );

    -- Insert into Lab Screening table
    INSERT INTO Hospital.LAB_SCREENING (
        LAB_ID, TEST_COST, TEST_DATE, IDTECHNICIAN, EPISODE_IDEPISODE
    )
    VALUES (
        episode_seq_new.NEXTVAL, p_test_cost, p_test_date, p_idtechnician, v_idepisode
    );

    -- Insert into Hospitalisation table
    INSERT INTO Hospital.HOSPITALIZATION (
        ADMISSION_DATE, DISCHARGE_DATE, ROOM_IDROOM, IDEPISODE, RESPONSIBLE_NURSE
    )
    VALUES (
        p_admission_date, p_discharge_date, p_room_idroom, v_idepisode, p_responsible_nurse
    );

    -- Insert into Prescription table
    INSERT INTO Hospital.PRESCRIPTION (
        IDPRESCRIPTION, PRESCRIPTION_DATE, DOSAGE, IDMEDICINE, IDEPISODE
    )
    VALUES (
        episode_seq_new.NEXTVAL, p_prescription_date, p_dosage, p_idmedicine, v_idepisode
    );

    DBMS_OUTPUT.PUT_LINE('Episode and related records inserted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE TABLE Hospital.New_Episode_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    patient_idpatient NUMBER,
    room_cost NUMBER,
    test_cost NUMBER,
    other_charges NUMBER,
    total NUMBER,
    payment_status VARCHAR2(10),
    scheduled_on DATE,
    appointment_date DATE,
    appointment_time VARCHAR2(5),
    iddoctor NUMBER,
    test_date DATE,
    idtechnician NUMBER,
    admission_date DATE,
    discharge_date DATE,
    room_idroom NUMBER,
    responsible_nurse NUMBER,
    prescription_date DATE,
    dosage NUMBER,
    idmedicine NUMBER
);


-- Trigger to Insert Episode, Bill, Appointment, Lab Screening, Hospitalization and Prescription
CREATE OR REPLACE TRIGGER trg_insert_episode_and_related
AFTER INSERT ON Hospital.New_Episode_Requests
FOR EACH ROW
BEGIN
    insert_episode(
        :NEW.patient_idpatient,
        :NEW.room_cost,
        :NEW.test_cost,
        :NEW.other_charges,
        :NEW.total,
        :NEW.payment_status,
        :NEW.scheduled_on,
        :NEW.appointment_date,
        :NEW.appointment_time,
        :NEW.iddoctor,
        :NEW.test_date,
        :NEW.idtechnician,
        :NEW.admission_date,
        :NEW.discharge_date,
        :NEW.room_idroom,
        :NEW.responsible_nurse,
        :NEW.prescription_date,
        :NEW.dosage,
        :NEW.idmedicine
    );
END;

INSERT INTO Hospital.New_Episode_Requests (
    patient_idpatient, room_cost, test_cost, other_charges, total, payment_status,
    scheduled_on, appointment_date, appointment_time, iddoctor, test_date, idtechnician,
    admission_date, discharge_date, room_idroom, responsible_nurse, prescription_date,
    dosage, idmedicine
) VALUES (
    543, 500, 200, 100, 800, 'PENDING',
    TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2023-07-10', 'YYYY-MM-DD'), '10:00', 101, TO_DATE('2023-07-05', 'YYYY-MM-DD'), 202,
    TO_DATE('2023-07-01', 'YYYY-MM-DD'), TO_DATE('2023-07-15', 'YYYY-MM-DD'), 303, 404, TO_DATE('2023-07-02', 'YYYY-MM-DD'),
    2, 505
);


-- 2)
-- Insert Room
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDROOM value
    SELECT COALESCE(MAX(IDROOM), 0) INTO max_id FROM Hospital.ROOM;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE room_seq_new';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                RAISE;
            END IF;
    END;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE room_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_room (
    p_room_type IN VARCHAR2,
    p_room_cost IN NUMBER
) IS
    v_idroom NUMBER;
BEGIN
    -- Insert into Room table and get the new IDROOM
    INSERT INTO Hospital.ROOM (
        IDROOM, ROOM_TYPE, ROOM_COST
    )
    VALUES (
        room_seq_new.NEXTVAL, p_room_type, p_room_cost
    )
    RETURNING IDROOM INTO v_idroom;

    DBMS_OUTPUT.PUT_LINE('Room inserted successfully with ID: ' || v_idroom);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE TABLE Hospital.New_Room_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    room_type VARCHAR2(45),
    room_cost NUMBER
);

-- Trigger to Insert Room
CREATE OR REPLACE TRIGGER trg_insert_room
AFTER INSERT ON Hospital.New_Room_Requests
FOR EACH ROW
BEGIN
    insert_room(
        :NEW.room_type,
        :NEW.room_cost
    );
END;

INSERT INTO Hospital.New_Room_Requests (
    room_type, room_cost
) VALUES (
    'Deluxe', 1500
);


-- 3)
-- Insert Medicine
DECLARE
    max_id NUMBER;
BEGIN
    -- Determine the current maximum IDMEDICINE value
    SELECT COALESCE(MAX(IDMEDICINE), 0) INTO max_id FROM Hospital.MEDICINE;

    -- Drop the existing sequence if it exists
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE medicine_seq_new';
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -2289 THEN -- ORA-02289: sequence does not exist
                RAISE;
            END IF;
    END;

    -- Create the sequence starting from the next value
    EXECUTE IMMEDIATE 'CREATE SEQUENCE medicine_seq_new START WITH ' || (max_id + 1) || ' INCREMENT BY 1 NOCACHE NOCYCLE';
END;

CREATE OR REPLACE PROCEDURE insert_medicine (
    p_m_name     IN VARCHAR2,
    p_m_quantity IN NUMBER,
    p_m_cost     IN NUMBER
) IS
    v_idmedicine NUMBER;
BEGIN
    -- Insert into Medicine table and get the new IDMEDICINE
    INSERT INTO Hospital.MEDICINE (
        IDMEDICINE, M_NAME, M_QUANTITY, M_COST
    )
    VALUES (
        medicine_seq_new.NEXTVAL, p_m_name, p_m_quantity, p_m_cost
    )
    RETURNING IDMEDICINE INTO v_idmedicine;

    DBMS_OUTPUT.PUT_LINE('Medicine inserted successfully with ID: ' || v_idmedicine);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

CREATE TABLE Hospital.New_Medicine_Requests (
    request_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    m_name VARCHAR2(45),
    m_quantity NUMBER,
    m_cost NUMBER
);

-- Trigger to Insert Medicine
CREATE OR REPLACE TRIGGER trg_insert_medicine
AFTER INSERT ON Hospital.New_Medicine_Requests
FOR EACH ROW
BEGIN
    insert_medicine(
        :NEW.m_name,
        :NEW.m_quantity,
        :NEW.m_cost
    );
END;

INSERT INTO Hospital.New_Medicine_Requests (
    m_name, m_quantity, m_cost
) VALUES (
    'Paracetamol', 100, 500
);


---------------------------------------------------------------------------------------------------------------

-- UPDATES


-- 1)
-- Update a Bill
CREATE OR REPLACE PROCEDURE update_bill (
    p_idbill         IN NUMBER,
    p_room_cost      IN NUMBER,
    p_test_cost      IN NUMBER,
    p_other_charges  IN NUMBER,
    p_total          IN NUMBER,
    p_payment_status IN VARCHAR2
) IS
BEGIN
    UPDATE Hospital.BILL
    SET room_cost = p_room_cost,
        test_cost = p_test_cost,
        other_charges = p_other_charges,
        total = p_total,
        payment_status = p_payment_status
    WHERE idbill = p_idbill;

    DBMS_OUTPUT.PUT_LINE('Bill record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Bill
CREATE OR REPLACE TRIGGER trg_update_bill
BEFORE UPDATE ON Hospital.BILL
FOR EACH ROW
BEGIN
    update_bill(
        p_idbill         => :OLD.idbill,
        p_room_cost      => :NEW.room_cost,
        p_test_cost      => :NEW.test_cost,
        p_other_charges  => :NEW.other_charges,
        p_total          => :NEW.total,
        p_payment_status => :NEW.payment_status
    );
END;

-- Update the bill information
BEGIN
    UPDATE Hospital.BILL
    SET room_cost = 600,
        test_cost = 250,
        other_charges = 150,
        total = 1000,
        payment_status = 'PROCESSED'
    WHERE idbill = 1001;
END;


-- 2)
-- Update a Lab Screening
CREATE OR REPLACE PROCEDURE update_lab_screening (
    p_lab_id       IN NUMBER,
    p_test_cost    IN NUMBER,
    p_test_date    IN DATE,
    p_idtechnician IN NUMBER
) IS
BEGIN
    UPDATE Hospital.LAB_SCREENING
    SET test_cost = p_test_cost,
        test_date = p_test_date,
        idtechnician = p_idtechnician
    WHERE lab_id = p_lab_id;

    DBMS_OUTPUT.PUT_LINE('Lab screening record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Lab Screening
CREATE OR REPLACE TRIGGER trg_update_lab_screening
BEFORE UPDATE ON Hospital.LAB_SCREENING
FOR EACH ROW
BEGIN
    update_lab_screening(
        p_lab_id       => :OLD.lab_id,
        p_test_cost    => :NEW.test_cost,
        p_test_date    => :NEW.test_date,
        p_idtechnician => :NEW.idtechnician
    );
END;

-- Update the lab screening information
BEGIN
    UPDATE Hospital.LAB_SCREENING
    SET test_cost = 300,
        test_date = TO_DATE('2023-07-10', 'YYYY-MM-DD'),
        idtechnician = 102
    WHERE lab_id = 2001;
END;


-- 3)
-- Update an Appointment
CREATE OR REPLACE PROCEDURE update_appointment (
    p_idepisode        IN NUMBER,
    p_scheduled_on     IN DATE,
    p_appointment_date IN DATE,
    p_appointment_time IN VARCHAR2,
    p_iddoctor         IN NUMBER
) IS
BEGIN
    UPDATE Hospital.APPOINTMENT
    SET scheduled_on = p_scheduled_on,
        appointment_date = p_appointment_date,
        appointment_time = p_appointment_time,
        iddoctor = p_iddoctor
    WHERE idepisode = p_idepisode;

    DBMS_OUTPUT.PUT_LINE('Appointment record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Appointment
CREATE OR REPLACE TRIGGER trg_update_appointment
BEFORE UPDATE ON Hospital.APPOINTMENT
FOR EACH ROW
BEGIN
    update_appointment(
        p_idepisode        => :OLD.idepisode,
        p_scheduled_on     => :NEW.scheduled_on,
        p_appointment_date => :NEW.appointment_date,
        p_appointment_time => :NEW.appointment_time,
        p_iddoctor         => :NEW.iddoctor
    );
END;

-- Update the appointment information
BEGIN
    UPDATE Hospital.APPOINTMENT
    SET scheduled_on = TO_DATE('2023-06-30', 'YYYY-MM-DD'),
        appointment_date = TO_DATE('2023-07-10', 'YYYY-MM-DD'),
        appointment_time = '14:00',
        iddoctor = 101
    WHERE idepisode = 3001;
END;


-- 4)
-- Update an Hospitalization
CREATE OR REPLACE PROCEDURE update_hospitalization (
    p_idepisode           IN NUMBER,
    p_admission_date      IN DATE,
    p_discharge_date      IN DATE,
    p_room_idroom         IN NUMBER,
    p_responsible_nurse   IN NUMBER
) IS
BEGIN
    UPDATE Hospital.HOSPITALIZATION
    SET admission_date = p_admission_date,
        discharge_date = p_discharge_date,
        room_idroom = p_room_idroom,
        responsible_nurse = p_responsible_nurse
    WHERE idepisode = p_idepisode;

    DBMS_OUTPUT.PUT_LINE('Hospitalization record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Hospitalization
CREATE OR REPLACE TRIGGER trg_update_hospitalization
BEFORE UPDATE ON Hospital.HOSPITALIZATION
FOR EACH ROW
BEGIN
    update_hospitalization(
        p_idepisode           => :OLD.idepisode,
        p_admission_date      => :NEW.admission_date,
        p_discharge_date      => :NEW.discharge_date,
        p_room_idroom         => :NEW.room_idroom,
        p_responsible_nurse   => :NEW.responsible_nurse
    );
END;

-- Update the hospitalization information
BEGIN
    UPDATE Hospital.HOSPITALIZATION
    SET admission_date = TO_DATE('2023-07-01', 'YYYY-MM-DD'),
        discharge_date = TO_DATE('2023-07-15', 'YYYY-MM-DD'),
        room_idroom = 303,
        responsible_nurse = 404
    WHERE idepisode = 4001;
END;

-- 5)
-- Update a Room
CREATE OR REPLACE PROCEDURE update_room (
    p_idroom    IN NUMBER,
    p_room_type IN VARCHAR2,
    p_room_cost IN NUMBER
) IS
BEGIN
    UPDATE Hospital.ROOM
    SET room_type = p_room_type,
        room_cost = p_room_cost
    WHERE idroom = p_idroom;

    DBMS_OUTPUT.PUT_LINE('Room record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Room
CREATE OR REPLACE TRIGGER trg_update_room
BEFORE UPDATE ON Hospital.ROOM
FOR EACH ROW
BEGIN
    update_room(
        p_idroom    => :OLD.idroom,
        p_room_type => :NEW.room_type,
        p_room_cost => :NEW.room_cost
    );
END;

-- Update the room information
BEGIN
    UPDATE Hospital.ROOM
    SET room_type = 'Standard',
        room_cost = 800
    WHERE idroom = 5001;
END;


-- 6)
-- Update a Prescription
CREATE OR REPLACE PROCEDURE update_prescription (
    p_idprescription    IN NUMBER,
    p_prescription_date IN DATE,
    p_dosage            IN NUMBER,
    p_idmedicine        IN NUMBER
) IS
BEGIN
    UPDATE Hospital.PRESCRIPTION
    SET prescription_date = p_prescription_date,
        dosage = p_dosage,
        idmedicine = p_idmedicine
    WHERE idprescription = p_idprescription;

    DBMS_OUTPUT.PUT_LINE('Prescription record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Prescription
CREATE OR REPLACE TRIGGER trg_update_prescription
BEFORE UPDATE ON Hospital.PRESCRIPTION
FOR EACH ROW
BEGIN
    update_prescription(
        p_idprescription    => :OLD.idprescription,
        p_prescription_date => :NEW.prescription_date,
        p_dosage            => :NEW.dosage,
        p_idmedicine        => :NEW.idmedicine
    );
END;

-- Update the prescription information
BEGIN
    UPDATE Hospital.PRESCRIPTION
    SET prescription_date = TO_DATE('2023-07-02', 'YYYY-MM-DD'),
        dosage = 3,
        idmedicine = 505
    WHERE idprescription = 6001;
END;


-- 7)
-- Update a Medicine
CREATE OR REPLACE PROCEDURE update_medicine (
    p_idmedicine IN NUMBER,
    p_m_name     IN VARCHAR2,
    p_m_quantity IN NUMBER,
    p_m_cost     IN NUMBER
) IS
BEGIN
    UPDATE Hospital.MEDICINE
    SET m_name = p_m_name,
        m_quantity = p_m_quantity,
        m_cost = p_m_cost
    WHERE idmedicine = p_idmedicine;

    DBMS_OUTPUT.PUT_LINE('Medicine record updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Update Medicine
CREATE OR REPLACE TRIGGER trg_update_medicine
BEFORE UPDATE ON Hospital.MEDICINE
FOR EACH ROW
BEGIN
    update_medicine(
        p_idmedicine => :OLD.idmedicine,
        p_m_name     => :NEW.m_name,
        p_m_quantity => :NEW.m_quantity,
        p_m_cost     => :NEW.m_cost
    );
END;

-- Update the medicine information
BEGIN
    UPDATE Hospital.MEDICINE
    SET m_name = 'Ibuprofen',
        m_quantity = 200,
        m_cost = 600
    WHERE idmedicine = 7001;
END;


---------------------------------------------------------------------------------------------------------------

-- DELETES


-- 1)
-- Delete an Episode
CREATE OR REPLACE PROCEDURE delete_episode_and_update_related (
    p_idepisode IN NUMBER
) IS
BEGIN
    -- Set IDEPISODE to 0 in Prescription table
    UPDATE Hospital.PRESCRIPTION
    SET idepisode = 0
    WHERE idepisode = p_idepisode;

    -- Set IDEPISODE to 0 in Hospitalisation table
    UPDATE Hospital.HOSPITALIZATION
    SET idepisode = 0
    WHERE idepisode = p_idepisode;

    -- Set IDEPISODE to 0 in Appointment table
    UPDATE Hospital.APPOINTMENT
    SET idepisode = 0
    WHERE idepisode = p_idepisode;

    -- Set EPISODE_IDEPISODE to 0 in Lab Screening table
    UPDATE Hospital.LAB_SCREENING
    SET episode_idepisode = 0
    WHERE episode_idepisode = p_idepisode;

    -- Set IDEPISODE to 0 in Bill table
    UPDATE Hospital.BILL
    SET idepisode = 0
    WHERE idepisode = p_idepisode;

    -- Delete from Episode table
    DELETE FROM Hospital.EPISODE
    WHERE idepisode = p_idepisode;

    DBMS_OUTPUT.PUT_LINE('Episode and related records updated and episode deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Episode
CREATE OR REPLACE TRIGGER trg_delete_episode
BEFORE DELETE ON Hospital.EPISODE
FOR EACH ROW
BEGIN
    delete_episode_and_update_related(:OLD.idepisode);
END;

DELETE FROM Hospital.EPISODE WHERE idepisode = 1001;


-- 2)
-- Delete a Bill
CREATE OR REPLACE PROCEDURE delete_bill (
    p_idbill IN NUMBER
) IS
BEGIN
    -- Delete from Bill table
    DELETE FROM Hospital.BILL
    WHERE idbill = p_idbill;

    DBMS_OUTPUT.PUT_LINE('Bill deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Bill
CREATE OR REPLACE TRIGGER trg_delete_bill
BEFORE DELETE ON Hospital.BILL
FOR EACH ROW
BEGIN
    delete_bill(:OLD.idbill);
END;

DELETE FROM Hospital.BILL WHERE idbill = 1001;


-- 3)
-- Delete Lab Screening
CREATE OR REPLACE PROCEDURE delete_lab_screening (
    p_lab_id IN NUMBER
) IS
BEGIN
    -- Delete from Lab Screening table
    DELETE FROM Hospital.LAB_SCREENING
    WHERE lab_id = p_lab_id;

    DBMS_OUTPUT.PUT_LINE('Lab screening record deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Lab Screening
CREATE OR REPLACE TRIGGER trg_delete_lab_screening
BEFORE DELETE ON Hospital.LAB_SCREENING
FOR EACH ROW
BEGIN
    delete_lab_screening(:OLD.lab_id);
END;

DELETE FROM Hospital.LAB_SCREENING WHERE lab_id = 2001;


-- 4)
-- Delete an Appointment
CREATE OR REPLACE PROCEDURE delete_appointment (
    p_idepisode IN NUMBER
) IS
BEGIN
    -- Delete from Appointment table
    DELETE FROM Hospital.APPOINTMENT
    WHERE idepisode = p_idepisode;

    DBMS_OUTPUT.PUT_LINE('Appointment deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Appointment
CREATE OR REPLACE TRIGGER trg_delete_appointment
BEFORE DELETE ON Hospital.APPOINTMENT
FOR EACH ROW
BEGIN
    delete_appointment(:OLD.idepisode);
END;

DELETE FROM Hospital.APPOINTMENT WHERE idepisode = 3001;


-- 5)
-- Delete an Hospitalization
CREATE OR REPLACE PROCEDURE delete_hospitalization (
    p_idepisode IN NUMBER
) IS
BEGIN
    -- Delete from Hospitalisation table
    DELETE FROM Hospital.HOSPITALIZATION
    WHERE idepisode = p_idepisode;

    DBMS_OUTPUT.PUT_LINE('Hospitalization record deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Hospitalization
CREATE OR REPLACE TRIGGER trg_delete_hospitalization
BEFORE DELETE ON Hospital.HOSPITALIZATION
FOR EACH ROW
BEGIN
    delete_hospitalization(:OLD.idepisode);
END;

DELETE FROM Hospital.HOSPITALIZATION WHERE idepisode = 4001;


-- 6)
-- Delete a Room
CREATE OR REPLACE PROCEDURE delete_room (
    p_idroom IN NUMBER
) IS
BEGIN
    -- Delete from Room table
    DELETE FROM Hospital.ROOM
    WHERE idroom = p_idroom;

    DBMS_OUTPUT.PUT_LINE('Room deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Room
CREATE OR REPLACE TRIGGER trg_delete_room
BEFORE DELETE ON Hospital.ROOM
FOR EACH ROW
BEGIN
    delete_room(:OLD.idroom);
END;

DELETE FROM Hospital.ROOM WHERE idroom = 5001;


-- 7)
-- Delete a Prescription
CREATE OR REPLACE PROCEDURE delete_prescription (
    p_idprescription IN NUMBER
) IS
BEGIN
    -- Delete from Prescription table
    DELETE FROM Hospital.PRESCRIPTION
    WHERE idprescription = p_idprescription;

    DBMS_OUTPUT.PUT_LINE('Prescription record deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Prescription
CREATE OR REPLACE TRIGGER trg_delete_prescription
BEFORE DELETE ON Hospital.PRESCRIPTION
FOR EACH ROW
BEGIN
    delete_prescription(:OLD.idprescription);
END;

DELETE FROM Hospital.PRESCRIPTION WHERE idprescription = 6001;


-- 8)
-- Delete a Medicine
CREATE OR REPLACE PROCEDURE delete_medicine (
    p_idmedicine IN NUMBER
) IS
BEGIN
    -- Delete from Medicine table
    DELETE FROM Hospital.MEDICINE
    WHERE idmedicine = p_idmedicine;

    DBMS_OUTPUT.PUT_LINE('Medicine record deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;

-- Trigger to Delete Medicine
CREATE OR REPLACE TRIGGER trg_delete_medicine
BEFORE DELETE ON Hospital.MEDICINE
FOR EACH ROW
BEGIN
    delete_medicine(:OLD.idmedicine);
END;

DELETE FROM Hospital.MEDICINE WHERE idmedicine = 7001;