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