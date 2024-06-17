// 1) All info about an id_episode
MATCH (e:Episode {id_episode: 89})
RETURN e;

// 2) All info about Hospital.Prescription
MATCH (e:Episode)-[r:HAS_PRESCRIPTION]->(m:Medicine)
RETURN r, m

// 3) Quantos episodios para um dado patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)
RETURN COUNT(e) AS number_of_episodes;

// 4) Buscar as presciptions para um dado id_episode
MATCH (e:Episode {id_episode: 89})-[p:HAS_PRESCRIPTION]->(m:Medicine)
RETURN p,m;

// 5) Bills para um dado id_episode
MATCH (e:Episode {id_episode: 95})-[:HAS_BILL]->(b:Bill)
RETURN b;

// 6) Bill para um dado id_bill
MATCH (b:Bill {id_bill: 29})
RETURN b;

// 7) Labs para um dado id de episode
MATCH (e:Episode {id_episode: 158})-[r:LAB_SCREENING_TECHNICIAN]->(s:Staff)
RETURN e, r, s

// 8) Lab para o ID Lab
MATCH (e:Episode)-[r:LAB_SCREENING_TECHNICIAN {id_lab: 98}]->(s:Staff)
RETURN e, r, s

// 9) Hospitalization para um dado id_episode
MATCH (e:Episode {id_episode: 95})-[:IN_ROOM]->(r:Room),
      (e)-[:HOSPITALIZATION_NURSE]->(n:Staff)
RETURN e, r, n

// 10) Buscar room por ID_Room
MATCH (r:Room {id_room: 1})
RETURN r;

// 11) Buscar Prescriptions por id_patient
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[r:HAS_PRESCRIPTION]->(m:Medicine)
RETURN r, m

// 12) Buscar Bills por id_patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(bill:Bill)
RETURN bill;

// 13) Buscar LabScreening por id_patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[l:LAB_SCREENING_TECHNICIAN]->(s:Staff)
RETURN e,l,s;

// 14) Buscar Hospitalization por id_patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)
RETURN e;

// 15) Buscar room por idPatient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:IN_ROOM]->(r:Room)
RETURN e,r;

// 16) Buscar Medicine por idPatient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[pres:HAS_PRESCRIPTION]->(m:Medicine)
RETURN pres,m;

// 17) Buscar Medicine por IdEpisode
MATCH (e:Episode {id_episode : 1})-[pres:HAS_PRESCRIPTION]->(m:Medicine)
RETURN pres,m;

// 18) Buscar Medicine por IDMedicine
MATCH (medicine:Medicine {id_medicine: 5})
RETURN medicine;

// 19) Buscar Medicine por IDPresciption
MATCH (e:Episode)-[p:HAS_PRESCRIPTION {id_prescription: 1}]->(m:Medicine)
RETURN e,p,m;

// 20) Buscar Medicine per Name
MATCH (medicine:Medicine {m_name: "Amoxicillin"})
RETURN medicine;

// 21) Buscar prescrições em uma data específica
MATCH (e:Episode)-[p:HAS_PRESCRIPTION]->(m:Medicine)
WHERE date(p.prescription_date) = date('2023-11-29')
RETURN e,p,m;

// 22) Buscar prescrições entre duas datas
MATCH (e:Episode)-[p:HAS_PRESCRIPTION]->(m:Medicine)
WHERE date(p.prescription_date) >= date('2023-01-01') AND date(p.prescription_date) <= date('2023-12-31')
RETURN p,m;

// 23) Buscar prescrições entre duas dosages
MATCH (e:Episode)-[p:HAS_PRESCRIPTION]->(m:Medicine)
WHERE toInteger(p.dosage) >= 10 AND toInteger(p.dosage) <= 200
RETURN p,m;

// 24) Somar o total das faturas para um dado paciente
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(bill:Bill)
RETURN SUM(toFloat(bill.total)) AS total_amount;

// 25) Soma de todas as bills para um dado paciente
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(bill:Bill)
RETURN 
    SUM(toFloat(bill.room_cost)) AS totalRoomCost,
    SUM(toFloat(bill.test_cost)) AS totalTestCost,
    SUM(toFloat(bill.other_charges)) AS totalOtherCharges,
    SUM(toFloat(bill.room_cost) + toFloat(bill.test_cost) + toFloat(bill.other_charges)) AS totalCost;

// 26) LabScreening por intervalo de datas
MATCH (e:Episode)-[ls:LAB_SCREENING_TECHNICIAN]->(s:Staff)
WHERE date(ls.test_date) >= date('2023-01-01') AND date(ls.test_date) <= date('2023-12-31')
RETURN ls;

// 27) LabScreening por intervalo de custo
MATCH (e:Episode)-[ls:LAB_SCREENING_TECHNICIAN]->(s:Staff)
WHERE toFloat(ls.test_cost) >= 10 AND toFloat(ls.test_cost) <= 100
RETURN ls;

// 28) Buscar registos de hospitalização com base em um intervalo de datas de admissão e alta
MATCH (e:Episode)
WHERE (date(e.admission_date) >= date('2023-01-01') AND date(e.admission_date) <= date('2023-12-31'))
   OR (date(e.discharge_date) >= date('2023-01-01') AND date(e.discharge_date) <= date('2023-12-31'))
RETURN e;

// 29) Buscar appointments por id_patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[a:APPOINTMENT_DOCTOR]->(s:Staff)
RETURN e,a,s;

// 30) Buscar appointments por id_episode
MATCH (e:Episode {id_episode: 10})-[a:APPOINTMENT_DOCTOR]->(s:Staff)
RETURN e,a,s;

// 31) Buscar todos os appointments agendados (schedule_on) em uma data específica
MATCH (e:Episode)-[a:APPOINTMENT_DOCTOR]->(s:Staff)
WHERE date(a.schedule_on) = date('2023-10-28')
RETURN e,a,s;

// 32) Buscar todos os appointments para uma appointment_date específica
MATCH (e:Episode)-[a:APPOINTMENT_DOCTOR]->(s:Staff)
WHERE date(a.appointment_date) = date('2023-11-29')
RETURN e,a,s;

// 33) Buscar todos os appointments para um horário específico (appointment_time)
MATCH (e:Episode)-[a:APPOINTMENT_DOCTOR]->(s:Staff)
WHERE a.appointment_time = '18:11'
RETURN e,a,s;

// 34) Buscar Todos os Appointments por id_doctor
MATCH (s:Staff {id_emp: 1})<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
RETURN e,a,s;

// 35) Contar Appointments por Médico (id_doctor)
MATCH (d:Staff)<-[a:APPOINTMENT_DOCTOR]-(e:Episode)
WITH d, count(a) AS appointment_count
RETURN d.id_emp AS doctor_id, d.emp_fname AS doctor_first_name, d.emp_lname AS doctor_last_name, appointment_count
ORDER BY appointment_count DESC;

// 36) Calcular o Total de Medicamentos e Custo Total
MATCH (m:Medicine)
RETURN sum(m.m_quantity) AS total_quantity, 
       sum(m.m_quantity * m.m_cost) AS total_cost;

// 37) Calcular o Total de Cada Medicamento Usado e o Custo Total
MATCH (m:Medicine)
WITH m.id_medicine AS medicine_id, 
     m.m_name AS medicine_name, 
     sum(m.m_quantity) AS total_quantity, 
     sum(m.m_quantity * m.m_cost) AS total_cost
RETURN medicine_id, medicine_name, total_quantity, total_cost
ORDER BY total_quantity DESC;

// 38) Calcular o Total de test_costs e a Contagem de Testes Realizados
MATCH (e:Episode)-[ls:LAB_SCREENING_TECHNICIAN]->(s:Staff)
RETURN count(ls) AS total_lab_screenings, 
       sum(ls.test_cost) AS total_test_cost;

// 39) Buscar Todas as Bills Registadas Entre Duas Datas
MATCH (b:Bill)
WHERE date(b.registered_at) >= date('2024-01-01') AND date(b.registered_at) <= date('2024-12-31')
RETURN b;

// 40) Buscar Pacientes com um payment_status Específico
MATCH (p:Patient)-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(b:Bill)
WHERE b.payment_status = 'PENDING'
RETURN p;

// 41) Buscar Todas as bills para um determinado Paciente
MATCH (p:Patient {id_patient: 2})-[:HAS_EPISODE]->(e:Episode)-[:HAS_BILL]->(b:Bill)
RETURN b;

// 42) Calcular o Custo Total das Bills Registadas Entre Duas Datas
MATCH (b:Bill)
WHERE date(b.registered_at) >= date('2024-01-01') AND date(b.registered_at) <= date('2024-12-31')
RETURN sum(b.total) AS total_cost;

// 43) Todos os episódios que ainda não acabaram
MATCH (e:Episode)
OPTIONAL MATCH (e)-[a:APPOINTMENT_DOCTOR]->(s:Staff)
WITH e, a, datetime() AS current_date
WHERE (a IS NOT NULL AND date(a.appointment_date) > date(current_date)) OR
      (e IS NOT NULL AND date(e.admission_date) <= date(current_date) AND (e.discharge_date IS NULL OR date(e.discharge_date) >= date(current_date)))
RETURN e, a;

// 44) Buscar enfermeira responsável para um episódio específico
MATCH (e:Episode {id_episode: 2})-[:HOSPITALIZATION_NURSE]->(n:Staff)
RETURN n;

// 45) Obter todas as enfermeiras que já cuidaram de um determinado paciente
MATCH (p:Patient {id_patient: 2})-[:HAS_EPISODE]->(e:Episode)-[:HOSPITALIZATION_NURSE]->(n:Staff)
RETURN p,e,n;

// 46) Obter informações do médico responsável por um episódio específico
MATCH (e:Episode {id_episode: 1})-[a:APPOINTMENT_DOCTOR]->(d:Staff)
RETURN e,a,d;

// 47) Obter todas as informações dos médicos que atenderam um paciente específico
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[a:APPOINTMENT_DOCTOR]->(d:Staff)
RETURN p,e,a,d;

// 48) Obter informações do técnico responsável por um episódio específico
MATCH (e:Episode {id_episode: 1})-[ls:LAB_SCREENING_TECHNICIAN]->(t:Staff)
RETURN e,ls,t;

// 49) Obter todas as informações dos técnicos que atenderam um paciente específico
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[ls:LAB_SCREENING_TECHNICIAN]->(t:Staff)
RETURN DISTINCT t;

// 50) Retornar informações de um paciente específico dado um id_patient
MATCH (p:Patient {id_patient: 89})
OPTIONAL MATCH (p)-[:HAS_EPISODE]->(e:Episode)
OPTIONAL MATCH (e)-[appointment:APPOINTMENT_DOCTOR]->(s:Staff)
OPTIONAL MATCH (e)-[:HAS_BILL]->(bill:Bill)
OPTIONAL MATCH (e)-[ls:LAB_SCREENING_TECHNICIAN]->(s:Staff)
RETURN p, 
       COLLECT(DISTINCT appointment) AS appointments, 
       COLLECT(DISTINCT bill) AS bills, 
       COLLECT(DISTINCT e) AS hospitalizations, 
       COLLECT(DISTINCT ls) AS labScreenings;

// 51) Retornar informações de todos os pacientes 
MATCH (p:Patient)
OPTIONAL MATCH (p)-[:HAS_EPISODE]->(e:Episode)
OPTIONAL MATCH (e)-[appointment:APPOINTMENT_DOCTOR]->(s:Staff)
OPTIONAL MATCH (e)-[:HAS_BILL]->(bill:Bill)
OPTIONAL MATCH (e)-[ls:LAB_SCREENING_TECHNICIAN]->(s:Staff)
RETURN p, 
       COLLECT(DISTINCT appointment) AS appointments, 
       COLLECT(DISTINCT bill) AS bills, 
       COLLECT(DISTINCT e) AS hospitalizations, 
       COLLECT(DISTINCT ls) AS labScreenings;
