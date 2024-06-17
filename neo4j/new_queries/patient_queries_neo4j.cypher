// 1) Get All Patients
MATCH (p:Patient)
RETURN p;

// 2) Get Patient by ID
MATCH (p:Patient {id_patient: 5})
RETURN p;

// 3) Buscar Medical_History para um dado ID
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory)
RETURN p, mh;

// 4) Buscar Insurance para um dado ID
MATCH (p:Patient {id_patient: 1})-[:HAS_INSURANCE]->(i:Insurance)
RETURN p, i;

// 5) Buscar Emergency_Contact para um dado ID
MATCH (p:Patient {id_patient: 1})-[:HAS_EMERGENCY_CONTACT]->(ec:EmergencyContact)
RETURN p, ec;

// 6) Buscar Patient por Blood-Type
MATCH (p:Patient {blood_type: 'A+'})
RETURN p;

// 7) Buscar Patient por Gender
MATCH (p:Patient {gender: 'Female'})
RETURN p;

MATCH (p:Patient {gender: 'Male'})
RETURN p;

// 8) Buscar Patients pela Condição Médica
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory {condition: 'Diabetes'})
RETURN p;

// 9) Buscar Todos os Tipos de Relações em Contatos de Emergência
MATCH (ec:EmergencyContact)
RETURN DISTINCT ec.relation AS relation;

// 10) Buscar Todos os Tipos de Provedores de Seguro
MATCH (i:Insurance)
RETURN DISTINCT i.provider AS provider;

// 11) Buscar Todos os Tipos de Planos de Seguro
MATCH (i:Insurance)
RETURN DISTINCT i.insurance_plan AS insurance_plan;

// 12)  Buscar Todos os Tipos de Coverage
MATCH (i:Insurance)
RETURN DISTINCT i.coverage AS coverage;

// 13) Buscar MedicalHistory
MATCH (mh:MedicalHistory)
RETURN mh;

// 14) Buscar Insurance
MATCH (i:Insurance)
RETURN i;

// 15) Buscar EmergencyContact
MATCH (ec:EmergencyContact)
RETURN ec;

// 16) Buscar Todos os Tipos de Condições Médicas
MATCH (mh:MedicalHistory)
RETURN DISTINCT mh.condition AS condition;

// 17) Buscar Todos os Tipos Sanguíneos
MATCH (p:Patient)
RETURN DISTINCT p.blood_type AS blood_type;

// 18) Buscar quantos Pacientes existem para cada BloodType
MATCH (p:Patient)
RETURN p.blood_type AS blood_type, COUNT(p) AS number_of_patients
ORDER BY number_of_patients DESC;

// 19) Buscar quantos Pacientes existem para cada Condition
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory)
RETURN mh.condition AS condition, COUNT(p) AS number_of_patients
ORDER BY number_of_patients DESC;

// 20) Buscar Pacientes com Registos Médicos em uma Data Específica
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory)
WHERE date(mh.record_date) = date('2023-12-10')
RETURN p, mh;

// 21) Buscar Pacientes com Registos Médicos em um intervalo de datas
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory)
WHERE date(mh.record_date) >= date('2023-01-15') AND date(mh.record_date) <= date('2023-12-10')
RETURN p, mh;

// 22) Buscar Pacientes com a data de aniversário
MATCH (p:Patient)
WHERE date(p.birthday) = date('1985-07-15')
RETURN p;

// 23) Buscar Pacientes por InsuranceProvider
MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance {provider: 'VWX Insurance'})
RETURN p, i;

// 24) Buscar Pacientes por InsurancePlan
MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance {insurance_plan: 'Student Plan'})
RETURN p, i;

// 25) Buscar Pacientes por Coverage
MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance {coverage: 'Full Coverage'})
RETURN p, i;

// 26) Buscar Pacientes por um intervalo de Idades
MATCH (p:Patient)
WHERE date(p.birthday) >= date('1980-01-01') AND date(p.birthday) <= date('1990-12-31')
RETURN p;

// 27) Buscar Pacientes com Maternity Coverage
MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance)
WHERE i.maternity = true
RETURN p, i;

// 28) Buscar Pacientes com Dental Coverage
MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance)
WHERE i.dental = true
RETURN p, i;

// 29) Buscar Pacientes com Optical Coverage
MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance)
WHERE i.optical = true
RETURN p, i;

MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance)
WHERE i.dental = true and i.optical = true
RETURN p, i;

MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance)
WHERE i.dental = true and i.maternity = true
RETURN p, i;

MATCH (p:Patient)-[:HAS_INSURANCE]->(i:Insurance)
WHERE i.maternity = true and i.optical = true
RETURN p, i;

// 30) Buscar Patients pela Relação
MATCH (p:Patient)-[:HAS_EMERGENCY_CONTACT]->(ec:EmergencyContact {relation: 'Father'})
RETURN p, ec;

//31) Buscar um Paciente pelo Primeiro Nome e Sobrenome
MATCH (p:Patient {patient_fname: 'Afonso', patient_lname: 'Bessa'})
RETURN p;

// 32) Buscar um Paciente pelo Número de Telefone
MATCH (p:Patient {phone: '123-456-7890'})
RETURN p;

// 33) Contar o Número de Pacientes
MATCH (p:Patient)
RETURN COUNT(p) AS number_of_patients;

// 34) Buscar Pacientes com um Contato de Emergência Específico
MATCH (p:Patient)-[:HAS_EMERGENCY_CONTACT]->(ec:EmergencyContact {contact_name: 'David Lee'})
RETURN p, ec;

// 35) Buscar Pacientes pelo record_id
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory {record_id: 24})
RETURN p, mh;
