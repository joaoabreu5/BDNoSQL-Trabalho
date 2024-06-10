// 1) Listar todas as prescrições para um paciente específico
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_PRESCRIPTION]->(pr:Prescription)
RETURN pr;

// 2) Listar os pacientes alocados a um específico quarto
MATCH (r:Room {id_room: 1})<-[:IN_ROOM]-(h:Hospitalization)<-[:HAS_HOSPITALIZATION]-(e:Episode)<-[:HAS_EPISODE]-(p:Patient)
RETURN p;

// 3) Listar todas os internamentos de um determinado paciente
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_HOSPITALIZATION]->(h:Hospitalization)
RETURN h;

// 4) Listar hospitalizações por enfermeira responsável.
MATCH (n:Staff {id_emp: 5})<-[:RESPONSIBLE_NURSE]-(h:Hospitalization)
RETURN h;

// 5) Listar todos os episódios médicos de um paciente específico.
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)
RETURN e;

// 6) Listar episódios médicos por tipo de condição.
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory {condition: 'Diabetes'})
MATCH (p)-[:HAS_EPISODE]->(e:Episode)
RETURN e;

// 7) Listar todos os episódios médicos tratados por um médico específico.
MATCH (d:Staff {id_emp: 1})<-[:CONDUCTED_BY]-(a:Appointment)<-[:HAS_APPOINTMENT]-(e:Episode)
RETURN e;

// 8) Listar todos os exames laboratoriais para um paciente específico.
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_LAB_SCREENING]->(ls:LabScreening)
RETURN ls;

// 9) Listar exames baseados no técnico responsável.
MATCH (t:Staff {id_emp: 46})<-[:PERFORMED_BY]-(ls:LabScreening)
RETURN ls;

// 10) Listar todas as faturas para um paciente específico.
MATCH (p:Patient {id_patient: 2})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(b:Bill)
RETURN b;

// 11) Listar todas as consultas agendadas para um paciente específico.
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_APPOINTMENT]->(a:Appointment)
RETURN a;

// 12) Listar consultas baseadas no médico responsável.
MATCH (d:Staff {id_emp: 1})<-[:CONDUCTED_BY]-(a:Appointment)
RETURN a;

// 13) Listar os Appointment para um dado Medico (por dia)
MATCH (d:Staff {id_emp: 1})<-[:CONDUCTED_BY]-(a:Appointment)
WHERE date(a.appointment_date) = date('2023-11-29')
RETURN a;

// 14) Buscar Appointment por data
MATCH (a:Appointment)
WHERE date(a.appointment_date) = date('2023-11-29')
RETURN a;

// 15) Buscar Appointment por data e depois por hora
MATCH (a:Appointment)
WHERE date(a.appointment_date) = date('2023-11-29') AND a.appointment_time = '18:11'
RETURN a;

// 16) Lista todos os episódios e o respetivo paciente
MATCH (p:Patient)-[:HAS_EPISODE]->(e:Episode)
RETURN e, p;

// 17) Lista os médicos com mais consultas marcadas, com informação detalhada do paciente
MATCH (d:Staff)-[:CONDUCTED_BY]-(a:Appointment)
WITH d, count(a) AS appointment_count
ORDER BY appointment_count DESC

MATCH (d:Staff)-[:CONDUCTED_BY]-(a:Appointment)<-[:HAS_APPOINTMENT]-(e:Episode)-[:HAS_EPISODE]-(p:Patient)
RETURN d.id_emp AS doctor_id, d.emp_fname AS doctor_first_name, d.emp_lname AS doctor_last_name, 
       d.email AS doctor_email, appointment_count, collect(p) AS patients
ORDER BY appointment_count DESC;
