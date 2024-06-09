-- 1) Buscar toda a Informação de um Staff
MATCH (s:Staff {id_emp: 1})
RETURN s

-- 2) Buscar o Department para um dado ID
MATCH (s:Staff {id_emp: 1})-[:WORKS_IN]->(d:Department)
RETURN s, d

MATCH (d:Department {id_department: 1})
RETURN d

-- 3) Buscar toda a informação das Enfermeiras
MATCH (s:Staff {role: 'NURSE'})
RETURN s

-- 4) Buscar toda a informação dos Médicos
MATCH (s:Staff {role: 'DOCTOR'})
RETURN s

-- 5) Buscar toda a informação dos Técnicos
MATCH (s:Staff {role: 'TECHNICIAN'})
RETURN s

-- 6) Buscar quantos Enfermeiros existem
MATCH (s:Staff {role: 'NURSE'})
RETURN COUNT(s) AS number_of_nurses

-- 7) Buscar quantos Doutores existem
MATCH (s:Staff {role: 'DOCTOR'})
RETURN COUNT(s) AS number_of_doctors

-- 8) Buscar quantos Técnicos existem
MATCH (s:Staff {role: 'TECHNICIAN'})
RETURN COUNT(s) AS number_of_technicians

-- 9) Buscar quantos nurses, doctor e técnicos existem
MATCH (s:Staff)
WHERE s.role IN ['NURSE', 'DOCTOR', 'TECHNICIAN']
RETURN s.role AS role, COUNT(s) AS count

-- 10) Buscar quantos Departments existem
MATCH (d:Department)
RETURN COUNT(d) AS number_of_departments

-- 11) Buscar Staff por Date_Joining
MATCH (s:Staff)
WHERE date(s.date_joining) = date('2018-08-25')
RETURN s

-- 12) Buscar Staff por Date_Separation
MATCH (s:Staff)
WHERE date(s.date_separation) = date('2022-01-05')
RETURN s

-- 13) Get Staff Members that are active or inactive
MATCH (s:Staff)
WHERE s.is_active_status = true
RETURN s

MATCH (s:Staff)
WHERE s.is_active_status = false
RETURN s

-- 14) Qualifications de um Doctor por ID
MATCH (s:Staff {role: 'DOCTOR', id_emp: 1})
RETURN s.qualification

-- 15) Todos os tipos de Qualifications
MATCH (s:Staff {role: 'DOCTOR'})
RETURN DISTINCT s.qualification AS qualifications

-- 16) Get the number of Employers per Department
MATCH (s:Staff)-[:WORKS_IN]->(d:Department)
RETURN d.department_name AS department, COUNT(s) AS number_of_staff

-- 17) Nurses per Department
MATCH (s:Staff {role: 'NURSE'})-[:WORKS_IN]->(d:Department)
RETURN d.department_name AS department, COUNT(s) AS number_of_nurses

-- 18) Number os Doctors per Department
MATCH (s:Staff {role: 'DOCTOR'})-[:WORKS_IN]->(d:Department)
RETURN d.department_name AS department, COUNT(s) AS number_of_doctors

-- 19) Number os Technicians per Department
MATCH (s:Staff {role: 'TECHNICIAN'})-[:WORKS_IN]->(d:Department)
RETURN d.department_name AS department, COUNT(s) AS number_of_technicians

-- 20) Contar Quantos Staff Estão Ativos
MATCH (s:Staff)
WHERE s.is_active_status = true
RETURN COUNT(s) AS number_of_active_staff

-- 21) Contar Quantos Staff não estão Ativos
MATCH (s:Staff)
WHERE s.is_active_status = false
RETURN COUNT(s) AS number_of_active_staff

-- 22) Buscar Staff pelo Primeiro Nome (emp_fname) e Sobrenome (emp_lname)
MATCH (s:Staff {emp_fname: 'Jillian', emp_lname: 'Gordon'})
RETURN s

-- 23) Buscar Staff pelo Email
MATCH (s:Staff {email: 'juan14@example.net'})
RETURN s

-- 24) Contar o Número Total de Staff
MATCH (s:Staff)
RETURN COUNT(s) AS total_number_of_staff

-- 25) Buscar Staff pelo SSN
MATCH (s:Staff {ssn: '329594711'})
RETURN s