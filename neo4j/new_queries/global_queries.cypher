// 1) Listar todas as prescrições para um paciente específico
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[pr:HAS_PRESCRIPTION]->(m:Medicine)
RETURN p,e,pr,m;

// 2) Listar os pacientes alocados a um específico quarto
MATCH (r:Room {id_room: 1})<-[:IN_ROOM]-(e:Episode)<-[:HAS_EPISODE]-(p:Patient)
RETURN p;

// 3) Listar todas os internamentos de um determinado paciente
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:IN_ROOM]->(r:Room)
RETURN e,r;

// 4) Listar hospitalizações por enfermeira responsável.
MATCH (n:Staff {id_emp: 5})<-[:HOSPITALIZATION_NURSE]-(e:Episode)
RETURN n,e;

// 5) Listar todos os episódios médicos de um paciente específico.
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)
RETURN e;

// 6) Listar episódios médicos por tipo de condição.
MATCH (p:Patient)-[:HAS_MEDICAL_HISTORY]->(mh:MedicalHistory {condition: 'Diabetes'})
MATCH (p)-[:HAS_EPISODE]->(e:Episode)
RETURN e;

// 7) Listar todos os episódios médicos tratados por um médico específico.
MATCH (d:Staff {id_emp: 1})<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
RETURN d,a,e;

// 8) Listar todos os exames laboratoriais para um paciente específico.
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[ls:LAB_SCREENING_TECHNICIAN]->(s:Staff)
RETURN p,e,ls,s;

// 9) Listar exames baseados no técnico responsável.
MATCH (s:Staff {id_emp: 46})<-[ls:LAB_SCREENING_TECHNICIAN]-(e:Episode)
RETURN s,ls,e;

// 10) Listar todas as faturas para um paciente específico.
MATCH (p:Patient {id_patient: 2})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(b:Bill)
RETURN b;

// 11) Listar todas as consultas agendadas para um paciente específico.
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[a:APPOINTMENT_DOCTOR]->(s:Staff)
RETURN p,e,a,s;

// 12) Listar consultas baseadas no médico responsável.
MATCH (d:Staff {id_emp: 1})<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
RETURN d,a,e;

// 13) Listar os Appointment para um dado Medico (por dia)
MATCH (d:Staff {id_emp: 1})<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
WHERE date(a.appointment_date) = date('2023-11-29')
RETURN d,a,e;

// 14) Buscar Appointment por data
MATCH (d:Staff {id_emp: 1})<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
WHERE date(a.appointment_date) = date('2023-11-29')
RETURN d,a,e;

// 15) Buscar Appointment por data e depois por hora
MATCH (d:Staff {id_emp: 1})<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
WHERE date(a.appointment_date) = date('2023-11-29') AND a.appointment_time = '18:11'
RETURN d,a,e;

// 16) Lista todos os episódios e o respetivo paciente
MATCH (p:Patient)-[:HAS_EPISODE]->(e:Episode)
RETURN e, p;

// 17) Lista os médicos com mais consultas marcadas, com informação detalhada do paciente
MATCH (d:Staff)-[a:APPOINTMENT_DOCTOR]-(e:Episode)
WITH d, count(a) AS appointment_count
ORDER BY appointment_count DESC

MATCH (d:Staff)-[a:APPOINTMENT_DOCTOR]-(e:Episode)-[:HAS_EPISODE]-(p:Patient)
RETURN d.id_emp AS doctor_id, d.emp_fname AS doctor_first_name, d.emp_lname AS doctor_last_name, 
       d.email AS doctor_email, appointment_count, collect(p) AS patients
ORDER BY appointment_count DESC;
