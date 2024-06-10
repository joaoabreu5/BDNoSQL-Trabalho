db = db.getSiblingDB('hospital');

// PACIENT VISION

// 1) Buscar o Pacient para um dado ID
function getPatientById(id) {
  return db.patients.findOne({ id_patient: id });
}

console.log('\n\nAll info about patient id 1:');
console.log(getPatientById(1));


// 2) Buscar Medical_History para um dado ID
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

console.log('\n\nMedical history for patient id 1:');
console.log(getMedicalHistoryById(1));


function getFullMedicalHistoryById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      medical_history: 1
    }
  );
}

console.log('\n\nFull medical history for patient id 1:');
console.log(getFullMedicalHistoryById(1));


// 3) Buscar Insurance para um dado ID
function getInsuranceById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      insurance: 1
    }
  );
}

console.log('\n\nInsurance info for patient id 1:');
console.log(getInsuranceById(1));


//  4) Buscar Emergency_Contact para um dado ID
function getEmergencyContactById(id) {
  return db.patients.findOne(
    { id_patient: id },
    {
      _id: 0,
      emergency_contact: 1
    }
  );
}

console.log('\n\nEmergency contact info for patient id 1:');
console.log(getEmergencyContactById(1));


//  5) Buscar Patient por Blood-Type
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

console.log('\n\nAll patients with blood type A+:');
console.log(getPatientsByBloodType("A+"));


//  6) Buscar Patient por Gender
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

console.log('\n\nAll male patients:');
console.log(getPatientsByGender("Male"));


//  7) Buscar Patients pela Condição Médica
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

console.log('\n\nAll patients with diabetes:');
console.log(getPatientsByCondition("Diabetes"));


//  8) Buscar Todos os Tipos de Relações em Contatos de Emergência
const emergencyContactRelations = db.patients.aggregate([
  { $unwind: "$emergency_contact" },
  { $group: { _id: "$emergency_contact.relation" } },
  { $project: { _id: 0, relation: "$_id" } }
]).toArray();

console.log('\n\nAll types of emergency contact relations:');
console.log(emergencyContactRelations);


// 9) Buscar Todos os Tipos de Provedores de Seguro
const insuranceProviders = db.patients.aggregate([
  { $group: { _id: "$insurance" } },
  { $project: { _id: 0, insurance: "$_id" } }
]).toArray();

console.log('\n\nAll types of insurance providers:');
console.log(insuranceProviders);


//  10) Buscar Todos os Tipos de Planos de Seguro
const insurancePlans = db.patients.aggregate([
  { $group: { _id: "$insurance.insurance_plan" } },
  { $project: { _id: 0, insurance_plan: "$_id" } }
]).toArray();

console.log('\n\nAll types of insurance plans:');
console.log(insurancePlans);


//  11) Buscar Todos os Tipos de Provedores de Seguro
const insuranceProvidersAgain = db.patients.aggregate([
  { $group: { _id: "$insurance.provider" } },
  { $project: { _id: 0, provider: "$_id" } }
]).toArray();

console.log('\n\nAll types of insurance providers:');
console.log(insuranceProvidersAgain);


//  12) Buscar Todos os Tipos de Coverage
const coverages = db.patients.aggregate([
  { $group: { _id: "$insurance.coverage" } },
  { $project: { _id: 0, coverage: "$_id" } }
]).toArray();

console.log('\n\nAll types of coverage:');
console.log(coverages);


//  13) Buscar Todos os Tipos de Condições Médicas
const medicalConditions = db.patients.aggregate([
  { $unwind: "$medical_history" },
  { $group: { _id: "$medical_history.condition" } },
  { $project: { _id: 0, condition: "$_id" } }
]).toArray();

console.log('\n\nAll types of medical conditions:');
console.log(medicalConditions);


//  14) Buscar Todos os Tipos Sanguíneos
const bloodTypes = db.patients.aggregate([
  { $group: { _id: "$blood_type" } },
  { $project: { _id: 0, blood_type: "$_id" } }
]).toArray();

console.log('\n\nAll types of blood types:');
console.log(bloodTypes);


//  15) Buscar quantos Pacientes existem para cada BloodType
const patientsByBloodType = db.patients.aggregate([
    { $group: { _id: "$blood_type", count: { $sum: 1 } } }
]).toArray();

console.log('\n\nCount of patients by blood type:');
console.log(patientsByBloodType);


//  16) Buscar quantos Pacientes existem para cada Condition
const patientsByCondition = db.patients.aggregate([
    { $unwind: "$medical_history" },
    { $group: { _id: "$medical_history.condition", count: { $sum: 1 } } } 
]).toArray();

console.log('\n\nCount of patients by condition:');
console.log(patientsByCondition);


//  17) Buscar Pacientes com Registros Médico em uma Data Específica
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

console.log('\n\nPatients with medical records on 2024-07-15:');
console.log(getPatientsByMedicalRecordDate(new ISODate("2024-07-15T00:00:00.000Z")));


//  18) Buscar Pacientes com Registros Médico em um intervalo de datas
function getPatientsByMedicalRecordDateRange(startDate, endDate) {
  return db.patients.find({
    "medical_history.record_date": {
      $gte: startDate,
      $lte: endDate
    }
  }).toArray();
}

console.log('\n\nPatients with medical records between 2023-01-01 and 2023-12-31:');
console.log(getPatientsByMedicalRecordDateRange(
  new ISODate("2023-01-01T00:00:00.000Z"),
  new ISODate("2023-12-31T23:59:59.999Z")
));

//  19) Buscar Pacientes com a data de aniversário
function getPatientsByBirthday(birthday) {
  return db.patients.find({
    "birthday": birthday
  }).toArray();
}

console.log('\n\nPatients with birthday on 1998-03-14:');
console.log(getPatientsByBirthday(new ISODate("1998-03-14T00:00:00.000Z")));


// 20) Buscar Pacientes por InsuranceProvider
function getPatientsByInsuranceProvider(provider) {
  return db.patients.find({
    "insurance.provider": provider
  }).toArray();
}

console.log('\n\nPatients with VWX Insurance provider:');
console.log(getPatientsByInsuranceProvider("VWX Insurance"));


//  21) Buscar Pacientes por InsurancePlan
function getPatientsByInsurancePlan(plan) {
  return db.patients.find({
    "insurance.insurance_plan": plan
  }).toArray();
}

console.log('\n\nPatients with Corporate Plan insurance:');
console.log(getPatientsByInsurancePlan("Corporate Plan"));


// 22) Buscar Pacientes por Coverage
function getPatientsByCoverage(coverage) {
  return db.patients.find({
    "insurance.coverage": coverage
  }).toArray();
}

console.log('\n\nPatients with Full Coverage:');
console.log(getPatientsByCoverage("Full Coverage"));


//  23) Buscar Pacientes por um intervalo de Idades
function listPatientsByAgeRange(minAge, maxAge) {
  var today = new Date();
  var minBirthdate = new Date(today.getFullYear() - maxAge, today.getMonth(), today.getDate());
  var maxBirthdate = new Date(today.getFullYear() - minAge, today.getMonth(), today.getDate());

  return db.patients.find({
    "birthday": { $gte: minBirthdate, $lte: maxBirthdate }
  }).toArray();
}

console.log('\n\nPatients aged between 1 and 30 years:');
console.log(listPatientsByAgeRange(1, 30));


// 24) Buscar Pacientes com Maternity Coverage
function listPatientsWithMaternityCoverage(maternity) {
  return db.patients.find({
    "insurance.maternity": maternity  
  }).toArray();
}

console.log('\n\nPatients with maternity coverage:');
console.log(listPatientsWithMaternityCoverage(true));


// 25) Buscar Pacientes com Dental Coverage
function listPatientsWithDentalCoverage(dental) {
  return db.patients.find({
    "insurance.dental": dental  
  }).toArray();
}

console.log('\n\nPatients without dental coverage:');
console.log(listPatientsWithDentalCoverage(false));

// 26) Buscar Pacientes com Optical Coverage
function listPatientsWithOpticalCoverage(optical) {
  return db.patients.find({
    "insurance.optical": optical  
  }).toArray();
}

console.log('\n\nPatients without optical coverage:');
console.log(listPatientsWithOpticalCoverage(false));


// 27) Buscar Patients pela Relação
function findPatientsByEmergencyContactRelation(relation) {
  return db.patients.find(
    {
      emergency_contact: {
        $elemMatch: { relation: relation }
      }
    },
    {
      _id: 0,
      id_patient: 1,
      patient_fname: 1,
      patient_lname: 1,
      emergency_contact: 1
    }
  ).toArray();
}

console.log('\n\nPatients with emergency contact relation as Sibling:');
console.log(findPatientsByEmergencyContactRelation('Sibling'));


// 28) Buscar um Paciente pelo Primeiro Nome e Sobrenome
function getPatientByName(firstName, lastName) {
  return db.patients.findOne({
      patient_fname: firstName,
      patient_lname: lastName
  });
}

var firstName = "John";
var lastName = "Doe";

console.log(`\n\nPatient with name ${firstName} ${lastName}:`);
console.log(getPatientByName(firstName, lastName));


// 29) Buscar um Paciente pelo Número de Telefone
function getPatientByPhone(phone) {
  return db.patients.findOne({ phone: phone });
}

var phone = "123-456-7892";

console.log(`\n\nPatient with phone number ${phone}:`);
console.log(getPatientByPhone(phone));


// 30) Contar o Número de Pacientes
console.log('\n\nCount of all patients:');
console.log(db.patients.countDocuments());


// 31) Buscar Pacientes com um Contato de Emergência Específico
function getPatientsByEmergencyContact(firstName, lastName) {
  const contactName = `${firstName} ${lastName}`;
  return db.patients.aggregate([
      { $unwind: "$emergency_contact" },
      { $match: { "emergency_contact.contact_name": contactName } },
      { $group: {
          _id: "$_id",
          patient_info: { $first: "$$ROOT" }
      }},
      { $project: {
          _id: 0,
          id_patient: "$patient_info.id_patient",
          patient_fname: "$patient_info.patient_fname",
          patient_lname: "$patient_info.patient_lname",
          phone: "$patient_info.phone",
          email: "$patient_info.email",
          gender: "$patient_info.gender",
          emergency_contact: "$patient_info.emergency_contact"
      }}
  ]).toArray();
}

var firstName = "Emma";
var lastName = "Thompson";

console.log(`\n\nPatients with emergency contact named ${firstName} ${lastName}:`);
console.log(getPatientsByEmergencyContact(firstName, lastName));


// 32) Buscar Pacientes pelo record_id
function getPatientsByRecordId(recordId) {
  return db.patients.aggregate([
      { $unwind: "$medical_history" },
      { $match: { "medical_history.record_id": recordId } },
      { $group: {
          _id: "$_id",
          patient_info: { $first: "$$ROOT" }
      }},
      { $project: {
          _id: 0,
          id_patient: "$patient_info.id_patient",
          patient_fname: "$patient_info.patient_fname",
          patient_lname: "$patient_info.patient_lname",
          phone: "$patient_info.phone",
          email: "$patient_info.email",
          gender: "$patient_info.gender",
          medical_history: "$patient_info.medical_history"
      }}
  ]).toArray();
}

var recordId = 21;

console.log(`\n\nPatients with medical history record id ${recordId}:`);
console.log(getPatientsByRecordId(recordId));


// 33) Listar episódios médicos por tipo de condição
function getEpisodesByCondition(condition) {
  return db.patients.aggregate([
      {
          $unwind: "$medical_history"
      },
      {
          $match: { "medical_history.condition": condition }
      },
      {
          $lookup: {
              from: "episodes",
              localField: "_id",
              foreignField: "id_patient",
              as: "episodes"
          }
      },
      {
          $unwind: "$episodes"
      },
      {
          $project: {
              _id: 0,
              id_episode: "$episodes.id_episode",
              id_patient: "$id_patient",
              patient_fname: "$patient_fname",
              patient_lname: "$patient_lname",
              condition: "$medical_history.condition",
          }
      }
  ]).toArray();
}

console.log('\n\nAll episodes for patients with diabetes:');
console.log(getEpisodesByCondition("Diabetes"));
