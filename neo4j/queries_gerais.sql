-- 1)
-- Listar todas as prescrições para um paciente específico
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_PRESCRIPTION]->(pr:Prescription)
RETURN pr

-- 2)
-- Listar os pacientes alocados a um específico quarto
MATCH (r:Room {id_room: 1})<-[:IN_ROOM]-(h:Hospitalization)<-[:HAS_HOSPITALIZATION]-(e:Episode)<-[:HAS_EPISODE]-(p:Patient)
RETURN p

-- 3)
-- Listar todas os internamentos de um determinado paciente
MATCH (p:Patient {id_patient: 1})-[:HAS_EPISODE]->(e:Episode)-[:HAS_HOSPITALIZATION]->(h:Hospitalization)
RETURN h

-- 4)
-- Listar hospitalizações por enfermeira responsável.
MATCH (n:Staff {id_emp: 5})<-[:RESPONSIBLE_NURSE]-(h:Hospitalization)
RETURN h

-- 5)
-- Listar todos os episódios médicos de um paciente específico.


-- 6)
-- Listar episódios médicos por tipo de condição.

-- 7)
-- Listar todos os episódios médicos tratados por um médico específico.

-- 8)
-- Listar todos os exames laboratoriais para um paciente específico.

-- 9)
-- Listar exames baseados no técnico responsável.

-- 10)
-- Listar todas as faturas emitidas por um médico específico.

-- 11)
-- Listar todas as consultas agendadas para um paciente específico.

-- 12)
-- Listar consultas baseadas no médico responsável.

-- 13)
-- Listar os Appointment para um dado Medico (por dia)

-- 14)
-- Buscar Appointment por data

-- 15)
-- Buscar Appointment por data e depois por hora

-- 16)
-- Lista todos os episódios e o respetivo paciente

-- 17)
-- Lista os médicos com mais consultas marcadas, com informação detalhada do paciente