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
-- Information from all the tables (TODO - Resultado Incorreto acho)
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
-- Define the object type for a medicine
CREATE OR REPLACE TYPE MedicineRowNew AS OBJECT (
  M_NAME VARCHAR2(45),
  M_QUANTITY NUMBER(38,0)
);

-- Define the table type for a collection of medicines
CREATE OR REPLACE TYPE MedicineTableNew IS TABLE OF MedicineRowNew;

-- Create the function to get low stock medicines
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

-- Example of using the function with a threshold of 10
SELECT * FROM TABLE(LowStockMedicines(25));

-- 8)
SELECT SUM(M.M_QUANTITY * M.M_COST) AS Total_Inventory_Cost
FROM Hospital.Medicine M;

------------------------------------------------------------------------------------------------------------

-- Hospital.Prescription

-- 2)
-- Listar prescrições por medicação
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

CREATE OR REPLACE FUNCTION ListRoomsByType
  RETURN RoomTypeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT IDROOM, ROOM_TYPE, ROOM_COST
    FROM Hospital.Room
  ) LOOP
    PIPE ROW (RoomTypeRow(rec.IDROOM, rec.ROOM_TYPE, rec.ROOM_COST));
  END LOOP;
  RETURN;
END ListRoomsByType;

SELECT * FROM TABLE(ListRoomsByType);

-- 2)
-- List room occupations by date range
CREATE OR REPLACE TYPE RoomOccupationRow AS OBJECT (
  IDROOM NUMBER(38,0),
  ADMISSION_DATE DATE,
  DISCHARGE_DATE DATE,
  PATIENT_ID NUMBER(38,0)
);

CREATE OR REPLACE TYPE RoomOccupationTable IS TABLE OF RoomOccupationRow;

CREATE OR REPLACE FUNCTION ListRoomOccupationsByDateRange(
  start_date IN DATE, end_date IN DATE
) RETURN RoomOccupationTable PIPELINED IS
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

CREATE OR REPLACE FUNCTION ListCurrentlyOccupiedRooms
  RETURN OccupiedRoomTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT r.IDROOM, r.ROOM_TYPE, r.ROOM_COST, e.PATIENT_IDPATIENT
    FROM Hospital.Room r
    JOIN Hospital.Hospitalization h ON r.IDROOM = h.ROOM_IDROOM
    JOIN Hospital.Episode e ON h.IDEPISODE = e.IDEPISODE
    WHERE h.DISCHARGE_DATE IS NULL
  ) LOOP
    PIPE ROW (OccupiedRoomRow(rec.IDROOM, rec.ROOM_TYPE, rec.ROOM_COST, rec.PATIENT_IDPATIENT));
  END LOOP;
  RETURN;
END ListCurrentlyOccupiedRooms;

SELECT * FROM TABLE(ListCurrentlyOccupiedRooms);

-- 5)
-- List All Distinct Room Types and Room Costs Ordered
CREATE OR REPLACE TYPE DistinctRoomTypeRow AS OBJECT (
  ROOM_TYPE VARCHAR2(25),
  ROOM_COST NUMBER(10,2)
);

CREATE OR REPLACE TYPE DistinctRoomTypeTable IS TABLE OF DistinctRoomTypeRow;

CREATE OR REPLACE FUNCTION ListDistinctRoomTypesAndCosts
  RETURN DistinctRoomTypeTable PIPELINED IS
BEGIN
  FOR rec IN (
    SELECT DISTINCT ROOM_TYPE, MIN(ROOM_COST) AS ROOM_COST
    FROM Hospital.Room
    GROUP BY ROOM_TYPE
    ORDER BY ROOM_COST
  ) LOOP
    PIPE ROW (DistinctRoomTypeRow(rec.ROOM_TYPE, rec.ROOM_COST));
  END LOOP;
  RETURN;
END ListDistinctRoomTypesAndCosts;

SELECT * FROM TABLE(ListDistinctRoomTypesAndCosts);

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

CREATE OR REPLACE FUNCTION ListHospitalizationsByDateRange(
  start_date IN DATE, end_date IN DATE
) RETURN HospitalizationByDateTable PIPELINED IS
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

CREATE OR REPLACE FUNCTION ListHospitalizationsByRoomType(
  room_type IN VARCHAR2
) RETURN HospitalizationByRoomTypeTable PIPELINED IS
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
-- Recuperar informações completas de uma consulta por ID Episode.
-- Lista de Total de Appointments / Listar ou Numero - Hora e Pacient?!
--

-- Hospital.Bill:

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


-- Listar faturas por intervalo de datas.
-- Listar faturas por status de pagamento (ex.: pago, pendente).

-- Hospital.Lab_Screening:
-- Listar exames por intervalo de datas.
-- Listar testes por custo (crescente)
-- Buscar LabScreening por IDEpisode

------------------

-- Dado um Episode buscar todos as prescriptions (dose, etc) e medicamentos (quantidade, custo e nome)
-- GetTotalBillingForPacient

-- Listar Hospitalazion por Ordem de Preço