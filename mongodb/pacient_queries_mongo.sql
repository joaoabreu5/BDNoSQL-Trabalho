-- PACIENT VISION

-- SELECTS

-- 1) Buscar o Pacient para um dado ID
function getPatientById(id) {
  return db.patients.findOne({ id_patient: id });
}

getPatientById(1);

-- 2) Buscar Medical_History para um dado ID
function getMedicalHistoryById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      id_patient: 1,
      "medical_history.record_id": 1,
      "medical_history.condition": 1,
      "medical_history.record_date": 1
    }
  );
}

getMedicalHistoryById(1);

function getFullMedicalHistoryById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      medical_history: 1
    }
  );
}

getFullMedicalHistoryById(1);

-- 3) Buscar Insurance para um dado ID
function getInsuranceById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      insurance: 1
    }
  );
}

getInsuranceById(1);

-- 4) Buscar Emergency_Contact para um dado ID
function getEmergencyContactById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      emergency_contact: 1
    }
  );
}

getEmergencyContactById(1);

-- 5) Buscar Patient por Blood-Type
function getPatientsByBloodType(bloodType) {
  return db.patients.find(
    { blood_type: bloodType },
    {
      _id: 0,
      id_patient: 1,
      patient_fname: 1,
      patient_lname: 1,
      blood_type: 1
    }
  ).toArray();
}

getPatientsByBloodType("A+");

-- 6) Buscar Patient por Gender
function getPatientsByGender(gender) {
  return db.patients.find(
    { gender: gender },
    {
      _id: 0,
      id_patient: 1,
      patient_fname: 1,
      patient_lname: 1,
      gender: 1
    }
  ).toArray();
}

getPatientsByGender("Male");

-- 7) Buscar Patients pela Condição Médica
function getPatientsByCondition(condition) {
  return db.patients.find(
    { "medical_history.condition": condition },
    {
      _id: 0,
      id_patient: 1,
      patient_fname: 1,
      patient_lname: 1,
      "medical_history.record_id": 1,
      "medical_history.condition": 1,
      "medical_history.record_date": 1
    }
  ).toArray();
}

getPatientsByCondition("Diabetes");

-- 8) Buscar Todos os Tipos de Relações em Contatos de Emergência
db.patients.aggregate([
  { $unwind: "$emergency_contact" },
  { $group: { _id: "$emergency_contact.relation" } },
  { $project: { _id: 0, relation: "$_id" } }
]);

-- 9) Buscar Todos os Tipos de Provedores de Seguro
db.patients.aggregate([
  { $group: { _id: "$insurance" } },
  { $project: { _id: 0, insurance: "$_id" } }
]);

-- 10) Buscar Todos os Tipos de Planos de Seguro
db.patients.aggregate([
  { $group: { _id: "$insurance.insurance_plan" } },
  { $project: { _id: 0, insurance_plan: "$_id" } }
]);

-- 11) Buscar Todos os Tipos de Provedores de Seguro
db.patients.aggregate([
  { $group: { _id: "$insurance.provider" } },
  { $project: { _id: 0, provider: "$_id" } }
]);

-- 12) Buscar Todos os Tipos de Coverage
db.patients.aggregate([
  { $group: { _id: "$insurance.coverage" } },
  { $project: { _id: 0, coverage: "$_id" } }
]);

-- 13) Buscar Todos os Tipos de Condições Médicas
db.patients.aggregate([
  { $unwind: "$medical_history" },
  { $group: { _id: "$medical_history.condition" } },
  { $project: { _id: 0, condition: "$_id" } }
]);

-- 14) Buscar Todos os Tipos Sanguíneos
db.patients.aggregate([
  { $group: { _id: "$blood_type" } },
  { $project: { _id: 0, blood_type: "$_id" } }
]);

-- 15) Buscar quantos Pacientes existem para cada BloodType
db.patients.aggregate([
    { $group: { _id: "$blood_type", count: { $sum: 1 } } }
])

-- 16) Buscar quantos Pacientes existem para cada Condition
db.patients.aggregate([
    { $unwind: "$medical_history" },
    { $group: { _id: "$medical_history.condition", count: { $sum: 1 } } } 
])

-- 17) Buscar Pacientes com Registros Médico em uma Data Específica
function getPatientsByMedicalRecordDate(date) {
  return db.patients.aggregate([
    { $unwind: "$medical_history" },
    { $match: { "medical_history.record_date": date } },
    {
      $project: {
        _id: 0,
        id_patient: 1,
        patient_fname: 1,
        patient_lname: 1,
        "medical_history.condition": 1,
        "medical_history.record_date": 1
      }
    }
  ]).toArray();
}

getPatientsByMedicalRecordDate(new ISODate("2024-07-15T00:00:00.000Z"));

-- 18) Buscar Pacientes com Registros Médico em um intervalo de datas
function getPatientsByMedicalRecordDateRange(startDate, endDate) {
  return db.patients.find({
    "medical_history.record_date": {
      $gte: startDate,
      $lte: endDate
    }
  }).toArray();
}

getPatientsByMedicalRecordDateRange(
  new ISODate("2023-01-01T00:00:00.000Z"),
  new ISODate("2023-12-31T23:59:59.999Z")
);

--  19) Buscar Pacientes com a data de aniversário
function getPatientsByBirthday(birthday) {
  return db.patients.find({
    "birthday": birthday
  }).toArray();
}

getPatientsByBirthday(new ISODate("1998-03-14T00:00:00.000Z"));

--  20) Buscar Pacientes por InsuranceProvider
function getPatientsByInsuranceProvider(provider) {
  return db.patients.find({
    "insurance.provider": provider
  }).toArray();
}

getPatientsByInsuranceProvider("VWX Insurance");

-- 21) Buscar Pacientes por InsurancePlan
function getPatientsByInsurancePlan(plan) {
  return db.patients.find({
    "insurance.insurance_plan": plan
  }).toArray();
}

getPatientsByInsurancePlan("Corporate Plan");

--  22) Buscar Pacientes por Coverage
function getPatientsByCoverage(coverage) {
  return db.patients.find({
    "insurance.coverage": coverage
  }).toArray();
}

getPatientsByCoverage("Full Coverage");

-- 23) Buscar Pacientes por um intervalo de Idades
function listPatientsByAgeRange(minAge, maxAge) {
  var today = new Date();
  var minBirthdate = new Date(today.getFullYear() - maxAge, today.getMonth(), today.getDate());
  var maxBirthdate = new Date(today.getFullYear() - minAge, today.getMonth(), today.getDate());

  return db.patients.find({
    "birthday": { $gte: minBirthdate, $lte: maxBirthdate }
  });
}

listPatientsByAgeRange(1, 30);

-- 24) Buscar Pacientes com Maternity Coverage
function listPatientsWithMaternityCoverage(maternity) {
  return db.patients.find({
    "insurance.maternity": maternity  
  }).toArray();
}

listPatientsWithMaternityCoverage(true);

-- 25) Buscar Pacientes com Dental Coverage
function listPatientsWithDentalCoverage(dental) {
  return db.patients.find({
    "insurance.dental": dental  
  }).toArray();
}

listPatientsWithDentalCoverage(false);

-- 26) Buscar Pacientes com Optical Coverage
function listPatientsWithOpticalyCoverage(optical) {
  return db.patients.find({
    "insurance.optical": optical  
  }).toArray();
}

listPatientsWithOpticalyCoverage(false);

---------------------------------------------------------------------------------------------------------------

-- INSERTS

---------------------------------------------------------------------------------------------------------------

-- DELETES

---------------------------------------------------------------------------------------------------------------

-- UPDATES
