from datetime import datetime
import neo4j.exceptions
import oracledb
import neo4j
import argparse
import logging

class OracleConnection():
    host : str
    port : int
    user : str
    password : str
    service_name : str
    connection : oracledb.Connection
    cursor : oracledb.Cursor
    
    def __init__(self, host='localhost', port=1521, user='', password='', service_name='XEPDB1'):
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.service_name = service_name
        self.addConnection()
        self.addCursor()
        
    def addConnection(self):
        self.connection = oracledb.connect(host=self.host, port=self.port, 
                                           user=self.user, password=self.password, service_name=self.service_name)
        
    def addCursor(self):
        self.cursor = self.connection.cursor()
        
    def executeQuery(self, query : str):
        self.cursor.execute(query)
        return self.cursor.fetchall()
    
    def executeSingletonQuery(self, query : str):
        self.cursor.execute(query)
        return self.cursor.fetchone()
        
    def close(self):
        self.cursor.close()
        self.connection.close()
    
       
class Neo4jConnection():
    host : str
    port : int
    user : str
    password : str
    database : str
    driver : neo4j.GraphDatabase
    session : neo4j.Session
    
    def __init__(self, host='localhost', port=7687, user='', password='', database=''):     
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.database = database
        self.addDriver()
        self.addSession()
        
    def addDriver(self):
        uri = f'bolt://{self.host}:{self.port}'
        self.driver = neo4j.GraphDatabase.driver(uri=uri, auth=(self.user, self.password))
    
    def addSession(self):
        session = self.driver.session()
        session.run(f'CREATE DATABASE {self.database} IF NOT EXISTS WAIT')
        session.close()
        self.session = self.driver.session(database=self.database)
    
    def executeQuery(self, query : str):
        return self.session.run(query)
    
    def close(self):
        self.session.close()
        self.driver.close()

def add_constraints(neo4j_conn : Neo4jConnection):
    # Ensure uniqueness constraint on id_patient
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (p:Patient) REQUIRE p.id_patient IS UNIQUE")
    # Ensure uniqueness constraint on insurance policy_number
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (i:Insurance) REQUIRE i.policy_number IS UNIQUE")
    # Ensure uniqueness constraint on emergency contacts
    neo4j_conn.executeQuery("CREATE CONSTRAINT unique_contact FOR (c:EmergencyContact) REQUIRE (c.contact_name, c.phone, c.relation) IS UNIQUE;")
    # Ensure uniqueness constraint on id_record
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (m:MedicalHistory) REQUIRE m.id_record IS UNIQUE")
    # Ensure uniqueness constraint on id_department
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (dep:Department) REQUIRE dep.id_department IS UNIQUE")
    # Ensure uniqueness constraint on id_emp
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (s:Staff) REQUIRE s.id_emp IS UNIQUE;")
    # Ensure uniqueness constraint on id_room
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (r:Room) REQUIRE r.id_room IS UNIQUE")
    # Ensure uniqueness constraint on id_bill
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (b:Bill) REQUIRE b.id_bill IS UNIQUE")
    # Ensure uniqueness constraints on prescriptions
    neo4j_conn.executeQuery("CREATE CONSTRAINT for (m:Medicine) REQUIRE m.id_medicine IS UNIQUE")
    # Ensure uniqueness contraints on medicines
    neo4j_conn.executeQuery("CREATE CONSTRAINT for (p:Prescription) REQUIRE p.id_prescription IS UNIQUE")
    # Ensure uniqueness constraint on lab screening
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (l:LabScreening) REQUIRE l.id_lab IS UNIQUE")
    # Ensure uniqueness constraint on appointment
    neo4j_conn.executeQuery("CREATE CONSTRAINT unique_appointment FOR (a:Appointment) REQUIRE (a.appointment_date, a.appointment_time,a.id_doctor) IS UNIQUE;")
    # Ensure uniqueness constraint on hospitalization
    neo4j_conn.executeQuery("CREATE CONSTRAINT unique_hospitalization FOR (h:Hospitalization) REQUIRE (h.admission_date, h.discharge_date, h.id_episode) IS UNIQUE;")
    # Ensure uniqueness constraint on episode
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (e:Episode) REQUIRE e.id_episode IS UNIQUE")

def get_counter_id(neo4j_conn, entity_type, id_field):
    max_id = get_max_id(neo4j_conn, entity_type, id_field)
    increment_counter_query = f"""
        MERGE (c:Counter {{type: '{entity_type}'}})
        ON CREATE SET c.count = {max_id}
        RETURN c.count AS new_id
    """
    neo4j_conn.executeQuery(increment_counter_query)

def get_max_id(neo4j_conn: Neo4jConnection, label: str, id_field: str) -> int:
    result = neo4j_conn.executeQuery(f"""
        MATCH (n:{label})
        RETURN COUNT(n) AS count_id
    """)
    result = result.single()
    return result['count_id']

def add_counters(neo4j_conn : Neo4jConnection):
    list = [
            {"name": 'Patient', "id": 'id_patient'},
            {"name": 'Insurance', "id": 'policy_number'},
            {"name": 'Staff', "id": 'id_emp'},
            {"name": 'Room', "id": 'id_room'},
            {"name": 'Medicine',"id": 'id_medicine'},
            {"name": 'LabScreening', "id": 'id_lab'},
            {"name": 'Prescription', "id": 'id_prescription'},
            {"name": 'Episode', "id": 'id_episode'},
            {"name": 'Bill', "id": 'id_bill'},
            {"name": 'MedicalHistory', "id": 'id_record'},
            {"name": 'Department', "id": 'id_department'}
          ]
    
    for element in list:
        get_counter_id(neo4j_conn, element["name"], element["id"])

def migrate_insurance(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # Query to retrieve all the insurance information
    insurance_sql_query = "SELECT * FROM insurance"
    insurances = oracle_conn.executeQuery(insurance_sql_query)

    for insurance in insurances:
        node_insurance = {
            'policy_number': insurance[0],
            'provider': insurance[1],
            'insurance_plan': insurance[2],
            'co_pay': float(insurance[3]),
            'coverage': insurance[4],
            'maternity': insurance[5] == 'Y',
            'dental': insurance[6] == 'Y',
            'optical': insurance[7] == 'Y',
        }

        # Neo4j query to create or merge the insurance node
        insurance_query = f"""
            MERGE (i:Insurance {{policy_number: '{node_insurance['policy_number']}'}})
            ON CREATE SET i.provider = '{node_insurance['provider']}',
                          i.insurance_plan = '{node_insurance['insurance_plan']}',
                          i.co_pay = {node_insurance['co_pay']},
                          i.coverage = '{node_insurance['coverage']}',
                          i.maternity = {node_insurance['maternity']},
                          i.dental = {node_insurance['dental']},
                          i.optical = {node_insurance['optical']}
            ON MATCH SET i.provider = '{node_insurance['provider']}',
                         i.insurance_plan = '{node_insurance['insurance_plan']}',
                         i.co_pay = {node_insurance['co_pay']},
                         i.coverage = '{node_insurance['coverage']}',
                         i.maternity = {node_insurance['maternity']},
                         i.dental = {node_insurance['dental']},
                         i.optical = {node_insurance['optical']}
        """
        neo4j_conn.executeQuery(insurance_query)

def migrate_patients(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    migrate_insurance(oracle_conn, neo4j_conn)
    
    # Query to retrieve all the patients and their insurance information
    patients_sql_query = """
        SELECT * FROM patient
    """
    patients = oracle_conn.executeQuery(patients_sql_query)

    for patient in patients:
        # create patient node
        node_patient = {
            'id_patient': int(patient[0]),
            'patient_fname': patient[1],
            'patient_lname': patient[2],
            'blood_type': patient[3],
            'phone': patient[4],
            'email': patient[5],
            'gender': patient[6],
            'policy_number': patient[7],
            'birthday': patient[8].isoformat()
        }

        # Neo4j query to create the patient node and relationship with insurance
        patient_query = f"""
            MERGE (p:Patient {{id_patient: {node_patient['id_patient']}}})
            ON CREATE SET
                p.patient_fname = '{node_patient['patient_fname']}', 
                p.patient_lname = '{node_patient['patient_lname']}',
                p.blood_type = '{node_patient['blood_type']}', 
                p.phone = '{node_patient['phone']}',
                p.email = '{node_patient['email']}',
                p.gender = '{node_patient['gender']}',
                p.birthday = datetime('{node_patient['birthday']}')
            ON MATCH SET
                p.patient_fname = '{node_patient['patient_fname']}', 
                p.patient_lname = '{node_patient['patient_lname']}',
                p.blood_type = '{node_patient['blood_type']}', 
                p.phone = '{node_patient['phone']}',
                p.email = '{node_patient['email']}',
                p.gender = '{node_patient['gender']}',
                p.birthday = datetime('{node_patient['birthday']}')
            MERGE (i:Insurance {{policy_number: '{node_patient['policy_number']}'}})
            MERGE (p)-[:HAS_INSURANCE]->(i)
        """
        neo4j_conn.executeQuery(patient_query)

        migrate_emergency_contacts(oracle_conn, neo4j_conn, node_patient['id_patient'])
        migrate_medical_history(oracle_conn, neo4j_conn, node_patient['id_patient'])

def migrate_emergency_contacts(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection, patient_id):
    # Query to retrieve all the emergency contacts for a patient
    emergency_contacts_sql_query = f'SELECT * FROM emergency_contact WHERE idpatient = {patient_id}'
    emergency_contacts = oracle_conn.executeQuery(emergency_contacts_sql_query)
    for contact in emergency_contacts:
        node_contact = {
            'contact_name': contact[0],
            'phone': contact[1],
            'relation': contact[2],
        }
        # Neo4j query to create the emergency contact node and relationship with patient
        emergency_contacts_query = f"""
            MATCH (p:Patient {{id_patient: {patient_id}}})
            MERGE (c:EmergencyContact {{contact_name: '{node_contact['contact_name']}',
                phone: '{node_contact['phone']}',
                relation: '{node_contact['relation']}'}})
            MERGE (p)-[:HAS_EMERGENCY_CONTACT]->(c)
            """
        neo4j_conn.executeQuery(emergency_contacts_query)

def migrate_medical_history(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection, patient_id):
    # Query to retrieve all the medical histories for a patient
    medical_histories_sql_query = f'SELECT * FROM medical_history WHERE idpatient = {patient_id}'
    medical_histories = oracle_conn.executeQuery(medical_histories_sql_query)
    
    for history in medical_histories:
        node_history = {
            'id_record': int(history[0]),
            'condition': history[1],
            'record_date': history[2].isoformat()

        }
        # Neo4j query to create the medical history node and relationship with patient
        medical_history_query = f"""
            MATCH (p:Patient {{id_patient: {patient_id}}})
            MERGE (m:MedicalHistory {{id_record: {node_history['id_record']}}})
            ON CREATE SET m.condition = '{node_history['condition']}',
                          m.record_date = datetime('{node_history['record_date']}')
            MERGE (p)-[:HAS_MEDICAL_HISTORY]->(m)
        """
        neo4j_conn.executeQuery(medical_history_query)

def migrate_department(oracle_conn: OracleConnection, neo4j_conn: Neo4jConnection):
    # Query to retrieve all the departments
    departments_sql_query = "SELECT * FROM department"
    departments = oracle_conn.executeQuery(departments_sql_query)

    for department in departments:
        node_department = {
            'id_department': int(department[0]),
            'department_head': department[1],
            'department_name': department[2],
        }

        # Neo4j query to create or merge the department node
        department_query = f"""
            MERGE (dep:Department {{id_department: {node_department['id_department']}}})
            ON CREATE SET dep.department_head = '{node_department['department_head']}', dep.department_name = '{node_department['department_name']}'
            ON MATCH SET dep.department_head = '{node_department['department_head']}', dep.department_name = '{node_department['department_name']}'
        """
        neo4j_conn.executeQuery(department_query)

def create_staff_node_and_relationship(node, department_id):
    properties_str = ", ".join([
        f"n.id_emp = {node['id_emp']}",
        f"n.emp_fname = '{node['emp_fname']}'",
        f"n.emp_lname = '{node['emp_lname']}'",
        f"n.date_joining = datetime('{node['date_joining'].isoformat()}')",
        f"n.email = '{node['email']}'",
        f"n.address = '{node['address']}'",
        f"n.ssn = '{node['ssn']}'",
        f"n.is_active_status = {str(node['is_active_status']).lower()}",
        f"n.role = '{node['role']}'"
    ])

    # Add qualification if exists
    if 'qualification' in node:
        properties_str += f", n.qualification = '{node['qualification']}'"
    
    # Add date_separation if exists
    if node.get('date_separation'):
        properties_str += f", n.date_separation = datetime('{(node['date_separation'].isoformat())}')"
        # Neo4j query to create or merge the staff node and relationship with department, case in which the staff has left
        query = f"""
            MERGE (n:Staff {{id_emp: {node['id_emp']}}})
            ON CREATE SET {properties_str}
            ON MATCH SET {properties_str}
            WITH n
            MATCH (dep:Department {{id_department: {department_id}}})
            MERGE (n)-[:LEFT]->(dep)
        """
    else:
        # Neo4j query to create or merge the staff node and relationship with department, case in which the staff is still working
        query = f"""
            MERGE (n:Staff {{id_emp: {node['id_emp']}}})
            ON CREATE SET {properties_str}
            ON MATCH SET {properties_str}
            WITH n
            MATCH (dep:Department {{id_department: {department_id}}})
            MERGE (n)-[:WORKS_IN]->(dep)
        """

    return query

def migrate_staff(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    migrate_department(oracle_conn, neo4j_conn)
    
    # Query to retrieve all the doctors
    doctors_sql_query ="""
        SELECT * FROM staff
        JOIN doctor ON staff.emp_id = doctor.emp_id 
    """
    doctors = oracle_conn.executeQuery(doctors_sql_query)

    for doctor in doctors:
        node_doctor = {
            'id_emp': int(doctor[0]),
            'emp_fname': doctor[1],
            'emp_lname': doctor[2],
            'date_joining': doctor[3],
            'date_separation': doctor[4],
            'email': doctor[5],
            'address': doctor[6],
            'ssn': int(doctor[7]),
            'is_active_status': doctor[9] == 'Y',
            'department_id': int(doctor[8]),
            'role': 'DOCTOR',
            'qualification': doctor[11]
        }
        # Create doctor node
        doctor_query = create_staff_node_and_relationship(node_doctor, node_doctor['department_id'])
        neo4j_conn.executeQuery(doctor_query)

    # Query to retrieve all the nurses
    nurses_sql_query = """
        SELECT * FROM staff
        JOIN nurse ON staff.emp_id = nurse.staff_emp_id 
    """
    nurses = oracle_conn.executeQuery(nurses_sql_query)

    for nurse in nurses:
        node_nurse = {
            'id_emp': int(nurse[0]),
            'emp_fname': nurse[1],
            'emp_lname': nurse[2],
            'date_joining': nurse[3],
            'date_separation': nurse[4],
            'email': nurse[5],
            'address': nurse[6],
            'ssn': int(nurse[7]),
            'is_active_status': nurse[9] == 'Y',
            'department_id': int(nurse[8]),
            'role': 'NURSE',
        }
        # Create nurse node
        nurse_query = create_staff_node_and_relationship(node_nurse, node_nurse['department_id'])
        neo4j_conn.executeQuery(nurse_query)

    # Query to retrieve all the technicians
    technicians_sql_query = """
        SELECT * FROM staff
        JOIN technician ON staff.emp_id = technician.staff_emp_id
    """
    technicians = oracle_conn.executeQuery(technicians_sql_query)

    for technician in technicians:
        node_technician = {
            'id_emp': int(technician[0]),
            'emp_fname': technician[1],
            'emp_lname': technician[2],
            'date_joining': technician[3],
            'date_separation': technician[4],
            'email': technician[5],
            'address': technician[6],
            'ssn': int(technician[7]),
            'is_active_status': technician[9] == 'Y',
            'department_id': int(technician[8]),
            'role': 'TECHNICIAN',
        }
        # Create technician node
        technician_query = create_staff_node_and_relationship(node_technician, node_technician['department_id'])
        neo4j_conn.executeQuery(technician_query)
    
def get_patients_ids(neo4j_conn: Neo4jConnection) -> list:
    result = neo4j_conn.executeQuery("MATCH (p:Patient) RETURN p.id_patient AS id_patient")
    return [record['id_patient'] for record in result]

def migrate_rooms(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection):

    # Query to retrieve all the rooms
    rooms = oracle_conn.executeQuery("SELECT * FROM room")

    for room in rooms:
        node_room = {
            'id_room': int(room[0]),
            'room_type': room[1],
            'room_cost': float(room[2])
        }

        # Neo4j query to create or merge the room node
        room_query = f"""
            MERGE (r:Room {{id_room: {node_room['id_room']}}})
            ON CREATE SET r.room_type = '{node_room['room_type']}', r.room_cost = {node_room['room_cost']}
            ON MATCH SET r.room_type = '{node_room['room_type']}', r.room_cost = {node_room['room_cost']}
        """
        neo4j_conn.executeQuery(room_query)

def migrate_lab_screenings(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection, id_episode):
    lab_screenings = oracle_conn.executeQuery(f"""
        SELECT * FROM lab_screening WHERE lab_screening.episode_idepisode = {id_episode}
    """)
    for lab_screening in lab_screenings:
        node_lab_screening = {
            'id_lab': int(lab_screening[0]),
            'test_cost': float(lab_screening[1]),
            'test_date': lab_screening[2].isoformat(),
            'id_technician': int(lab_screening[3]),
            'id_episode': int(lab_screening[4])
        }

        # Neo4j query to create or merge the lab screening node and relationship with episode and technician
        lab_screening_query = f"""
            MERGE (l:LabScreening {{id_lab: {node_lab_screening['id_lab']}}})
            ON CREATE SET l.test_cost = {node_lab_screening['test_cost']},
                            l.test_date = datetime('{node_lab_screening['test_date']}')
            ON MATCH SET l.test_cost = {node_lab_screening['test_cost']},
                            l.test_date = datetime('{node_lab_screening['test_date']}')
            WITH l
            MATCH (e:Episode {{id_episode: {node_lab_screening['id_episode']}}})
            MERGE (e)-[:HAS_LAB_SCREENING]->(l)
            WITH l
            MATCH (s:Staff {{id_emp: {node_lab_screening['id_technician']}}})
            MERGE (l)-[:PERFORMED_BY]->(s)
        """
        neo4j_conn.executeQuery(lab_screening_query)

def migrate_bills(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection, id_episode):

    # Query to retrieve all the bills for an episode
    bills = oracle_conn.executeQuery(f""" 
        SELECT * FROM bill WHERE bill.idepisode = {id_episode}
    """)
    for bill in bills:
        
        node_bill = {
            'id_bill': int(bill[0]),
            'room_cost': float(bill[1]),
            'test_cost': float(bill[2]),
            'other_charges': float(bill[3]),
            'total': float(bill[4]),
            'id_episode': int(bill[5]),
            'registered_at': bill[6].isoformat(), 
            'payment_status': bill[7]
        }
        

        # Neo4j query to create or merge the bill node and relationship with episode
        bill_query = f"""
            MERGE (b:Bill {{id_bill: {node_bill['id_bill']}}})
            ON CREATE SET b.room_cost = {node_bill['room_cost']}, 
                          b.test_cost = {node_bill['test_cost']}, 
                          b.other_charges = {node_bill['other_charges']}, 
                          b.total = {node_bill['total']}, 
                          b.registered_at = datetime('{node_bill['registered_at']}'), 
                          b.payment_status = '{node_bill['payment_status']}'
            ON MATCH SET b.room_cost = {node_bill['room_cost']}, 
                         b.test_cost = {node_bill['test_cost']}, 
                         b.other_charges = {node_bill['other_charges']}, 
                         b.total = {node_bill['total']}, 
                         b.registered_at = datetime('{node_bill['registered_at']}'), 
                         b.payment_status = '{node_bill['payment_status']}'
            WITH b
            MATCH (e:Episode {{id_episode: {node_bill['id_episode']}}})
            MERGE (e)-[:HAS_BILL]->(b)
        """
        neo4j_conn.executeQuery(bill_query)

def migrate_medicine(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection):
    # Query to retrieve all the medicines for an episode
    medicines = oracle_conn.executeQuery(f""" 
        SELECT * FROM medicine
    """)
    for medicine in medicines:
        node_medicine = {
            'id_medicine': int(medicine[0]),
            'm_name': medicine[1],
            'm_quantity': int(medicine[2]),
            'm_cost': float(medicine[3]),
        }

        # Neo4j query to create or merge the medicine node and relationship with episode
        medicine_query = f"""
            MERGE (m:Medicine {{id_medicine: {node_medicine['id_medicine']}}})
            ON CREATE SET m.m_name = '{node_medicine['m_name']}', 
                          m.m_quantity = {node_medicine['m_quantity']}, 
                          m.m_cost = {node_medicine['m_cost']}
            ON MATCH SET m.m_name = '{node_medicine['m_name']}', 
                         m.m_quantity = {node_medicine['m_quantity']}, 
                         m.m_cost = {node_medicine['m_cost']}
        """
        neo4j_conn.executeQuery(medicine_query)

def migrate_prescriptions(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection, id_episode):
    
    migrate_medicine(neo4j_conn, oracle_conn)
    
    # Query to retrieve all the prescriptions for an episode
    prescriptions = oracle_conn.executeQuery(f""" 
        SELECT * FROM prescription 
        WHERE prescription.idepisode = {id_episode}
    """)
    for prescription in prescriptions:
        node_prescription = {
            'id_prescription': prescription[0],
            'prescription_date': prescription[1].isoformat(),
            'dosage': prescription[2],
            'id_medicine': int(prescription[3]),
            'id_episode': int(prescription[4]),
        }

        # Neo4j query to create or merge the prescription node and relationships with episode and the medicine
        prescription_query = f"""
            MERGE (p:Prescription {{id_prescription: {node_prescription['id_prescription']}}})
            ON CREATE SET p.prescription_date = datetime('{node_prescription['prescription_date']}'), 
                          p.dosage = '{node_prescription['dosage']}'
            ON MATCH SET p.prescription_date = datetime('{node_prescription['prescription_date']}'), 
                         p.dosage = '{node_prescription['dosage']}'
            WITH p
            MATCH (e:Episode {{id_episode: {node_prescription['id_episode']}}})
            MERGE (e)-[:HAS_PRESCRIPTION]->(p)
            WITH p
            MATCH (m:Medicine {{id_medicine: {node_prescription['id_medicine']}}})
            MERGE (p)-[:PRESCRIBES]->(m)
        """
        neo4j_conn.executeQuery(prescription_query)

def migrate_appointment(neo4j_conn: Neo4jConnection, episode):
    node_appointment = {
        'schedule_on': episode[2].isoformat(),
        'appointment_date': episode[3].isoformat(),
        'appointment_time': episode[4],
        'id_doctor': int(episode[5]),
        'id_episode': int(episode[6])
    }

    # Neo4j query to create or merge the appointment node and relationship with episode and doctor
    appointment_query = f"""
        MERGE (a:Appointment {{
            appointment_date: datetime('{node_appointment['appointment_date']}'), 
            appointment_time: '{node_appointment['appointment_time']}'
        }})
        ON CREATE SET a.schedule_on = datetime('{node_appointment['schedule_on']}'), 
                      a.id_doctor = {node_appointment['id_doctor']}
        ON MATCH SET a.schedule_on = datetime('{node_appointment['schedule_on']}'), 
                     a.id_doctor = {node_appointment['id_doctor']}
        WITH a
        MATCH (e:Episode {{id_episode: {node_appointment['id_episode']}}})
        MERGE (e)-[:HAS_APPOINTMENT]->(a)
        WITH a
        MATCH (s:Staff {{id_emp: {node_appointment['id_doctor']}}})
        MERGE (a)-[:CONDUCTED_BY]->(s)
    """
    neo4j_conn.executeQuery(appointment_query)

def migrate_hospitalization(neo4j_conn, episode):
    # Convert admission_date to ISO 8601 format
    admission_date = episode[7].isoformat()
    
    # Check if discharge_date is present and convert to ISO 8601 format if it is
    discharge_date = episode[8].isoformat() if episode[8] is not None else None

    node_hospitalization = {
        'admission_date': admission_date,
        'discharge_date': discharge_date,
        'id_room': int(episode[9]),
        'id_episode': int(episode[10]),
        'responsible_nurse': int(episode[11])
    }

    # Build the dynamic part of the query for discharge_date
    discharge_date_clause = f", discharge_date: datetime('{node_hospitalization['discharge_date']}')" if node_hospitalization['discharge_date'] else ""

    # Neo4j query to create the hospitalization node and relationship with episode
    hospitalization_query = f"""
        MERGE (h:Hospitalization {{
            admission_date: datetime('{node_hospitalization['admission_date']}'){discharge_date_clause}
        }})
        WITH h
        MATCH (e:Episode {{id_episode: {node_hospitalization['id_episode']}}})
        MERGE (e)-[:HAS_HOSPITALIZATION]->(h)
        WITH h
        MATCH (s:Staff {{id_emp: {node_hospitalization['responsible_nurse']}}})
        MERGE (h)-[:RESPONSIBLE_NURSE]->(s)
        WITH h
        MATCH (r:Room {{id_room: {node_hospitalization['id_room']}}})
        MERGE (h)-[:IN_ROOM]->(r)
    """
    neo4j_conn.executeQuery(hospitalization_query)

def migrate_episodes(oracle_conn: OracleConnection, neo4j_conn: Neo4jConnection):

    # Get all the patients from Neo4j
    patients = get_patients_ids(neo4j_conn)
    
    for patient in patients:
        # Query to retrieve all the episodes for a patient    
        episodes_sql_query = f"""
            SELECT * FROM episode
            LEFT JOIN appointment ON episode.idepisode = appointment.idepisode
            LEFT JOIN hospitalization ON episode.idepisode = hospitalization.idepisode 
            WHERE patient_idpatient = {patient}
        """
        # Retrieve episodes for the patient from Oracle
        episodes = oracle_conn.executeQuery(episodes_sql_query)

        for episode in episodes:
            
            node_episode = {
                'id_episode': int(episode[0]),
                'patient_id': int(episode[1]),
            }
            
            # Neo4j query to create or merge the episode node and relationship with patient
            episode_query = f"""
                MERGE (e:Episode {{id_episode: {node_episode['id_episode']}}})
                ON CREATE SET e.patient_id = {node_episode['patient_id']}
                ON MATCH SET e.patient_id = {node_episode['patient_id']}
                WITH e
                MATCH (p:Patient {{id_patient: {node_episode['patient_id']}}})
                MERGE (p)-[:HAS_EPISODE]->(e)
            """
            neo4j_conn.executeQuery(episode_query)
            
            # Migrate rooms
            migrate_rooms(neo4j_conn, oracle_conn)
            # Migrate episode bills
            migrate_bills(neo4j_conn, oracle_conn, node_episode['id_episode'])
            # Migrate episode prescriptions
            migrate_prescriptions(neo4j_conn, oracle_conn, node_episode['id_episode'])
            # Migrate episode lab screenings
            migrate_lab_screenings(neo4j_conn, oracle_conn, node_episode['id_episode'])

            if episode[2]:
                # Migrate episode appointment
                migrate_appointment(neo4j_conn, episode)

            if episode[7]:
                # Migrate episode hospitalization
                migrate_hospitalization(neo4j_conn, episode)

query="""
    CREATE (i:Insurance {policy_number: '123456', provider: 'Blue Cross', insurance_plan: 'Gold', co_pay: 20.0, coverage: 'Full', maternity: true, dental: true, optical: true})
"""

def migrate(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # Add constraints
    add_constraints(neo4j_conn)
    # Inserção de pacientes em Neo4j
    migrate_patients(oracle_conn, neo4j_conn)
    # Insert staff elements in Neo4j
    migrate_staff(oracle_conn, neo4j_conn)
    # Insert episode elements in Neo4j
    migrate_episodes(oracle_conn, neo4j_conn)
    # Add counters
    add_counters(neo4j_conn)


def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-oh', '--oracle-host', help='Oracle host', default='localhost', type=str)
    parser.add_argument('-op', '--oracle-port', help='Oracle port', default=1521, type=int)
    parser.add_argument('-ou', '--oracle-user', help='Oracle username', default='hospital', type=str)
    parser.add_argument('-opwd', '--oracle-password', help='Oracle password', default='hospital', type=str)
    parser.add_argument('-osn', '--oracle-service-name', help='Oracle service name', default='XEPDB1', type=str)
    
    parser.add_argument('-nh', '--neo4j-host', help='Neo4j host', default='localhost', type=str)
    parser.add_argument('-np', '--neo4j-port', help='Neo4j port', default=7687, type=int)
    parser.add_argument('-nu', '--neo4j-user', help='Neo4j username', default='hospital', type=str)
    parser.add_argument('-npwd', '--neo4j-password', help='Neo4j password', default='hospital', type=str)
    parser.add_argument('-nd', '--neo4j-database', help='Neo4j database name', default='hospital', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n\n")
    
    oracle_conn = OracleConnection(args.oracle_host, args.oracle_port, 
                                   args.oracle_user, args.oracle_password, args.oracle_service_name)
    
    neo4j_conn = Neo4jConnection(args.neo4j_host, args.neo4j_port,
                                 args.neo4j_user, args.neo4j_password, args.neo4j_database)
    
    migrate(oracle_conn, neo4j_conn)
    
    oracle_conn.close()
    neo4j_conn.close()


if __name__ == '__main__':
    main()
    