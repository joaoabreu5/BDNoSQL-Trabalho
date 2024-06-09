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

-- 23) Buscar prescrições entre duas datas

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

-- 28) LabScreening por intervalo de custo
MATCH (lab:LabScreening)
WHERE toFloat(lab.test_cost) >= 10 AND toFloat(lab.test_cost) <= 100
RETURN lab

-- 29) Buscar registos de hospitalização com base em um intervalo de datas de admissão e alta

-- 30) Buscar appointments por id_patient
MATCH (p:Patient {id_patient: 89})-[:HAS_EPISODE]->(e:Episode)-[:HAS_APPOINTMENT]->(appointment:Appointment)
RETURN appointment

-- 31) Buscar appointments por id_episode
MATCH (e:Episode {id_episode: 10})-[:HAS_APPOINTMENT]->(appointment:Appointment)
RETURN appointment

-- 32) Buscar todos os appointments agendados (schedule_on) para uma data específica

-- 33) Buscar todos os appointments para uma appointment_date específica

-- 34) Buscar todos os appointments para um horário específico (appointment_time)

-- 35) Buscar Todos os Appointments por id_doctor
ERRO
MATCH (doctor:Staff {id_emp: 82, role: 'DOCTOR'})-[:CONDUCTED_BY]->(appointment:Appointment {id_doctor: 82})
RETURN appointment

-- 36) Contar Appointments por Médico (id_doctor)

-- 37) Calcular o Total de Medicamentos e Custo Total

-- 38) Calcular o Total de Cada Medicamento Usado e o Custo Total

-- 39) Calcular o Total de test_costs e a Contagem de Testes Realizados

-- 40) Buscar Todas as bills Registradas Entre Duas Datas 

-- 41) Buscar Pacientes com um payment_status Específico

-- 42) Buscar Todas as bills com Detalhes dos Pacientes

-- 43) Calcular o Custo Total das bills Registradas Entre Duas Datas

-- 44) Todos os episódios que ainda não acabaram

-- 45) Buscar enfermeira responsável para um episódio específico

-- 46) Obter todas as enfermeiras que já cuidaram de um determinado paciente

-- 47) Obter informações do médico responsável por um episódio específico

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