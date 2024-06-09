-- 1) All info about an id_episode
MATCH (e:Episode {id_episode: 89})
RETURN e

-- 2) All info about Hospital.Prescription
MATCH (p:Prescription)
RETURN p

-- 4) Quantos episodios para um dado patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)
RETURN COUNT(e) AS number_of_episodes

-- 5) Buscar as presciptions para um dado id_episode
MATCH (e:Episode {id_episode: 89})-[:HAS_PRESCRIPTION]->(p:Prescription)
RETURN p

-- 6) Bills para um dado id_episode
MATCH (e:Episode {id_episode: 95})-[:HAS_BILL]->(b:Bill)
RETURN b

-- 7) Bill para um dado id_bill
MATCH (b:Bill {id_bill: 29})
RETURN b

-- 8) Labs para um dado id de episode
MATCH (e:Episode {id_episode: 158})-[:HAS_LAB_SCREENING]->(l:LabScreening)
RETURN l

-- 9) Lab para o ID Lab
MATCH (l:LabScreening {id_lab: 98})
RETURN l

-- 10) Hospitalization para um dado id_episode
MATCH (e:Episode {id_episode: 95})-[:HAS_HOSPITALIZATION]->(h:Hospitalization)
RETURN h

-- 11) Buscar room por ID_Room
MATCH (r:Room {id_room: 1})
RETURN r

-- 12) Buscar Prescriptions por id_patient
MATCH (e:Episode {patient_id: 1})-[:HAS_PRESCRIPTION]->(prescription:Prescription)
RETURN prescription

-- 13) Buscar Bills por id_patient
MATCH (e:Episode {patient_id: 89})-[:HAS_BILL]->(bill:Bill)
RETURN bill

-- 14) Buscar LabScreening por id_patient
MATCH (e:Episode {patient_id: 89})-[:HAS_LAB_SCREENING]->(labScreening:LabScreening)
RETURN labScreening

-- 15) Buscar Hospitalization por id_patient
MATCH (e:Episode {patient_id: 89})-[:HAS_HOSPITALIZATION]->(hospitalization:Hospitalization)
RETURN hospitalization

-- 16) Buscar room por idPatient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_HOSPITALIZATION]->(h:Hospitalization)-[:IN_ROOM]->(room:Room)
RETURN room

-- 17) Buscar Medicine por idPatient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_PRESCRIPTION]->(prescription:Prescription)-[:PRESCRIBES]->(medicine:Medicine)
RETURN medicine

-- 18) Buscar Medicine por IdEpisode
MATCH (e:Episode {id_episode: 1})-[:HAS_PRESCRIPTION]->(prescription:Prescription)-[:PRESCRIBES]->(medicine:Medicine)
RETURN medicine

-- 19) Buscar Medicine por IDMedicine
MATCH (medicine:Medicine {id_medicine: 5})
RETURN medicine

-- 20) Buscar Medicine por IDPresciption
MATCH (prescription:Prescription {id_prescription: 1})-[:PRESCRIBES]->(medicine:Medicine)
RETURN medicine

-- 21) Buscar Medicine per Name
MATCH (medicine:Medicine {m_name: "Amoxicillin"})
RETURN medicine

-- 22) Buscar prescrições em uma data específica
MATCH (pr:Prescription)
WHERE date(pr.prescription_date) = date('2023-11-29')
RETURN pr

-- 23) Buscar prescrições entre duas datas
MATCH (pr:Prescription)
WHERE date(pr.prescription_date) >= date('2023-01-01') AND date(pr.prescription_date) <= date('2023-12-31')
RETURN pr

-- 24) Buscar prescrições entre duas dosages
MATCH (prescription:Prescription)
WHERE toInteger(prescription.dosage) >= 10 AND toInteger(prescription.dosage) <= 200
RETURN prescription

-- 25) Somar o total das faturas para um dado paciente
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(bill:Bill)
RETURN SUM(toFloat(bill.total)) AS total_amount

-- 26) Soma de todas as bills para um dado paciente
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(bill:Bill)
RETURN 
    SUM(toFloat(bill.room_cost)) AS totalRoomCost,
    SUM(toFloat(bill.test_cost)) AS totalTestCost,
    SUM(toFloat(bill.other_charges)) AS totalOtherCharges,
    SUM(toFloat(bill.room_cost) + toFloat(bill.test_cost) + toFloat(bill.other_charges)) AS totalCost

-- 27) LabScreening por intervalo de datas
MATCH (ls:LabScreening)
WHERE date(ls.test_date) >= date('2023-01-01') AND date(ls.test_date) <= date('2023-12-31')
RETURN ls

-- 28) LabScreening por intervalo de custo
MATCH (lab:LabScreening)
WHERE toFloat(lab.test_cost) >= 10 AND toFloat(lab.test_cost) <= 100
RETURN lab

-- 29) Buscar registos de hospitalização com base em um intervalo de datas de admissão e alta
MATCH (h:Hospitalization)
WHERE (date(h.admission_date) >= date('2023-01-01') AND date(h.admission_date) <= date('2023-12-31'))
   OR (date(h.discharge_date) >= date('2023-01-01') AND date(h.discharge_date) <= date('2023-12-31'))
RETURN h

-- 30) Buscar appointments por id_patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_APPOINTMENT]->(appointment:Appointment)
RETURN appointment

-- 31) Buscar appointments por id_episode
MATCH (e:Episode {id_episode: 10})-[:HAS_APPOINTMENT]->(appointment:Appointment)
RETURN appointment

-- 32) Buscar todos os appointments agendados (schedule_on) em uma data específica
MATCH (a:Appointment)
WHERE date(a.schedule_on) = date('2023-10-28')
RETURN a

-- 33) Buscar todos os appointments para uma appointment_date específica
MATCH (a:Appointment)
WHERE date(a.appointment_date) = date('2023-11-29')
RETURN a

-- 34) Buscar todos os appointments para um horário específico (appointment_time)
MATCH (a:Appointment)
WHERE a.appointment_time = '18:11'
RETURN a

-- 35) Buscar Todos os Appointments por id_doctor
MATCH (d:Staff {id_emp: 1})<-[:CONDUCTED_BY]-(a:Appointment)
RETURN a

-- 36) Contar Appointments por Médico (id_doctor)
MATCH (d:Staff)<-[:CONDUCTED_BY]-(a:Appointment)
WITH d, count(a) AS appointment_count
RETURN d.id_emp AS doctor_id, d.emp_fname AS doctor_first_name, d.emp_lname AS doctor_last_name, appointment_count
ORDER BY appointment_count DESC

-- 37) Calcular o Total de Medicamentos e Custo Total
MATCH (m:Medicine)
RETURN sum(m.m_quantity) AS total_quantity, 
       sum(m.m_quantity * m.m_cost) AS total_cost

-- 38) Calcular o Total de Cada Medicamento Usado e o Custo Total
MATCH (m:Medicine)
WITH m.id_medicine AS medicine_id, 
     m.m_name AS medicine_name, 
     sum(m.m_quantity) AS total_quantity, 
     sum(m.m_quantity * m.m_cost) AS total_cost
RETURN medicine_id, medicine_name, total_quantity, total_cost
ORDER BY total_quantity DESC

-- 39) Calcular o Total de test_costs e a Contagem de Testes Realizados
MATCH (ls:LabScreening)
RETURN count(ls) AS total_lab_screenings, 
       sum(ls.test_cost) AS total_test_cost

-- 40) Buscar Todas as Bills Registadas Entre Duas Datas
MATCH (b:Bill)
WHERE date(b.registered_at) >= date('2024-01-01') AND date(b.registered_at) <= date('2024-12-31')
RETURN b

-- 41) Buscar Pacientes com um payment_status Específico
MATCH (p:Patient)-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(b:Bill)
WHERE b.payment_status = 'PENDING'
RETURN p

-- 42) Buscar Todas as bills com para um determinado Paciente
MATCH (p:Patient {id_patient: 2})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(b:Bill)
RETURN b

-- 43) Calcular o Custo Total das Bills Registadas Entre Duas Datas
MATCH (b:Bill)
WHERE date(b.registered_at) >= date('2024-01-01') AND date(b.registered_at) <= date('2024-12-31')
RETURN sum(b.total) AS total_cost

-- 44) Todos os episódios que ainda não acabaram
MATCH (e:Episode)
OPTIONAL MATCH (e)-[:HAS_HOSPITALIZATION]->(h:Hospitalization)
OPTIONAL MATCH (e)-[:HAS_APPOINTMENT]->(a:Appointment)
WITH e, h, a, datetime() AS current_date
WHERE (a IS NOT NULL AND date(a.appointment_date) > date(current_date)) OR
      (h IS NOT NULL AND date(h.admission_date) <= date(current_date) AND (h.discharge_date IS NULL OR date(h.discharge_date) >= date(current_date)))
RETURN e, h, a

-- 45) Buscar enfermeira responsável para um episódio específico
MATCH (e:Episode {id_episode: 2})-[:HAS_HOSPITALIZATION]->(h:Hospitalization)-[:RESPONSIBLE_NURSE]->(n:Staff)
RETURN n

-- 46) Obter todas as enfermeiras que já cuidaram de um determinado paciente
MATCH (p:Patient {id_patient: 2})-[:HAS_EPISODE]->(e:Episode)-[:HAS_HOSPITALIZATION]->(h:Hospitalization)-[:RESPONSIBLE_NURSE]->(n:Staff)
RETURN p, n

-- 47) Obter informações do médico responsável por um episódio específico
MATCH (e:Episode {id_episode: 1})-[:HAS_APPOINTMENT]->(a:Appointment)-[:CONDUCTED_BY]->(d:Staff)
RETURN d

-- 48) Obter todas as informações dos médicos que atenderam um paciente específico


-- 49) Obter informações do técnico responsável por um episódio específico

-- 50) Obter todas as informações dos técnicos que atenderam um paciente específico
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_LAB_SCREENING]->(lab:LabScreening)-[:PERFORMED_BY]->(technician:Staff)
RETURN DISTINCT technician

-- 51) Retornar informações de um paciente específico dado um id_patient
MATCH (p:Patient {id_patient: 89})
OPTIONAL MATCH (p)-[:HAS_EPISODE]->(e:Episode)
OPTIONAL MATCH (e)-[:HAS_APPOINTMENT]->(appointment:Appointment)
OPTIONAL MATCH (e)-[:HAS_BILL]->(bill:Bill)
OPTIONAL MATCH (e)-[:HAS_HOSPITALIZATION]->(hospitalization:Hospitalization)
OPTIONAL MATCH (e)-[:HAS_LAB_SCREENING]->(lab:LabScreening)
RETURN p, 
       COLLECT(DISTINCT appointment) AS appointments, 
       COLLECT(DISTINCT bill) AS bills, 
       COLLECT(DISTINCT hospitalization) AS hospitalizations, 
       COLLECT(DISTINCT lab) AS labScreenings

--52) Retornar informações de todos os pacientes 
MATCH (p:Patient)
OPTIONAL MATCH (p)-[:HAS_EPISODE]->(e:Episode)
OPTIONAL MATCH (e)-[:HAS_APPOINTMENT]->(appointment:Appointment)
OPTIONAL MATCH (e)-[:HAS_BILL]->(bill:Bill)
OPTIONAL MATCH (e)-[:HAS_HOSPITALIZATION]->(hospitalization:Hospitalization)
OPTIONAL MATCH (e)-[:HAS_LAB_SCREENING]->(lab:LabScreening)
RETURN p, COLLECT(DISTINCT appointment) AS appointments, COLLECT(DISTINCT bill) AS bills, 
       COLLECT(DISTINCT hospitalization) AS hospitalizations, COLLECT(DISTINCT lab) AS labScreenings