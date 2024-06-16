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
        if self.database != 'system':
            session = self.driver.session(database='system')
            session.run(f'CREATE DATABASE {self.database} IF NOT EXISTS WAIT')
            session.close()

        self.session = self.driver.session(database=self.database)
    
    def executeQuery(self, query : str, parameters : dict = {}, **kwargs : any):
        return self.session.run(query, parameters, **kwargs)
    
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
    # Ensure uniqueness contraints on medicines
    neo4j_conn.executeQuery("CREATE CONSTRAINT for (m:Medicine) REQUIRE m.id_medicine IS UNIQUE")
    # Ensure uniqueness constraint on episode
    neo4j_conn.executeQuery("CREATE CONSTRAINT FOR (e:Episode) REQUIRE e.id_episode IS UNIQUE")
    

def get_counter_id(neo4j_conn : Neo4jConnection, entity_type : str):
    max_id = get_max_id(neo4j_conn, entity_type)
    
    increment_counter_query = """
        MERGE (c:Counter {type: $entity_type})
        ON CREATE SET c.count = $max_id
        RETURN c.count AS new_id
    """
    
    neo4j_conn.executeQuery(increment_counter_query, entity_type=entity_type, max_id=max_id)


def get_max_id(neo4j_conn : Neo4jConnection, label : str) -> int:    
    query = f"""
        MATCH (n:{label})
        RETURN COUNT(n) AS count_id
    """
    
    result = neo4j_conn.executeQuery(query).single()
    
    return result['count_id']


def add_counters(neo4j_conn : Neo4jConnection):
    list = [
        {'name': 'Patient', "id": 'id_patient'},
        {'name': 'Insurance', "id": 'policy_number'},
        {'name': 'MedicalHistory', "id": 'id_record'},
        {'name': 'Staff', "id": 'id_emp'},
        {'name': 'Medicine',"id": 'id_medicine'},
        {'name': 'Room', "id": 'id_room'},
        {'name': 'Episode', "id": 'id_episode'},
        {'name': 'Bill', "id": 'id_bill'},
        {'name': 'Prescription', "id": 'id_prescription'},
        {'name': 'LabScreening', "id": 'id_lab'},
        {'name': 'Department', "id": 'id_department'}
    ]
    
    for element in list:
        get_counter_id(neo4j_conn, element['name'])


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
        insurance_query = """
            MERGE (i:Insurance {policy_number: $policy_number})
            ON CREATE SET i.provider = $provider,
                          i.insurance_plan = $insurance_plan,
                          i.co_pay = $co_pay,
                          i.coverage = $coverage,
                          i.maternity = $maternity,
                          i.dental = $dental,
                          i.optical = $optical
            ON MATCH SET i.provider = $provider,
                         i.insurance_plan = $insurance_plan,
                         i.co_pay = $co_pay,
                         i.coverage = $coverage,
                         i.maternity = $maternity,
                         i.dental = $dental,
                         i.optical = $optical
        """
        
        neo4j_conn.executeQuery(insurance_query, node_insurance)


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
            'birthday': patient[8].date()
        }

        # Neo4j query to create the patient node and relationship with insurance
        patient_query = """
            MERGE (p:Patient {id_patient: $id_patient})
            ON CREATE SET
                p.patient_fname = $patient_fname, 
                p.patient_lname = $patient_lname,
                p.blood_type = $blood_type, 
                p.phone = $phone,
                p.email = $email,
                p.gender = $gender,
                p.birthday = $birthday
            ON MATCH SET
                p.patient_fname = $patient_fname, 
                p.patient_lname = $patient_lname,
                p.blood_type = $blood_type, 
                p.phone = $phone,
                p.email = $email,
                p.gender = $gender,
                p.birthday = $birthday
            MERGE (i:Insurance {policy_number: $policy_number})
            MERGE (p)-[:HAS_INSURANCE]->(i)
        """
        
        neo4j_conn.executeQuery(patient_query, node_patient)

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
        emergency_contacts_query = """
            MATCH (p:Patient {id_patient: $patient_id})
            MERGE (c:EmergencyContact {contact_name: $contact_name,
                phone: $phone,
                relation: $relation})
            MERGE (p)-[:HAS_EMERGENCY_CONTACT]->(c)
        """
        
        neo4j_conn.executeQuery(emergency_contacts_query, node_contact, patient_id = patient_id)


def migrate_medical_history(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection, patient_id):
    # Query to retrieve all the medical histories for a patient
    medical_histories_sql_query = f'SELECT * FROM medical_history WHERE idpatient = {patient_id}'
    medical_histories = oracle_conn.executeQuery(medical_histories_sql_query)
    
    for history in medical_histories:
        node_history = {
            'id_record': int(history[0]),
            'condition': history[1],
            'record_date': history[2].date()

        }
        
        # Neo4j query to create the medical history node and relationship with patient
        medical_history_query = """
            MATCH (p:Patient {id_patient: $patient_id})
            MERGE (m:MedicalHistory {id_record: $id_record})
            ON CREATE SET m.condition = $condition,
                          m.record_date = $record_date
            MERGE (p)-[:HAS_MEDICAL_HISTORY]->(m)
        """
        
        neo4j_conn.executeQuery(medical_history_query, node_history, patient_id=patient_id)


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
        department_query = """
            MERGE (dep:Department {id_department: $id_department})
            ON CREATE SET dep.department_head = $department_head, dep.department_name = $department_name
            ON MATCH SET dep.department_head = $department_head, dep.department_name = $department_name
        """
        
        neo4j_conn.executeQuery(department_query, node_department)


def create_staff_node_and_relationship(node):
    properties_str = ", ".join([
        f"n.id_emp = $id_emp",
        f"n.emp_fname = $emp_fname",
        f"n.emp_lname = $emp_lname",
        f"n.date_joining = $date_joining",
        f"n.email = $email",
        f"n.address = $address",
        f"n.ssn = $ssn",
        f"n.is_active_status = $is_active_status",
        f"n.role = $role"
    ])

    # Add qualification if exists
    if 'qualification' in node:
        properties_str += f", n.qualification = $qualification"
    
    # Add date_separation if exists
    if node.get('date_separation'):
        properties_str += f", n.date_separation = $date_separation"
        
        # Neo4j query to create or merge the staff node and relationship with department, case in which the staff has left
        query = f"""
            MERGE (n:Staff {{id_emp: $id_emp}})
            ON CREATE SET {properties_str}
            ON MATCH SET {properties_str}
            WITH n
            MATCH (dep:Department {{id_department: $department_id}})
            MERGE (n)-[:LEFT]->(dep)
        """
    else:
        # Neo4j query to create or merge the staff node and relationship with department, case in which the staff is still working
        query = f"""
            MERGE (n:Staff {{id_emp: $id_emp}})
            ON CREATE SET {properties_str}
            ON MATCH SET {properties_str}
            WITH n
            MATCH (dep:Department {{id_department: $department_id}})
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
            'date_joining': doctor[3].date(),
            'date_separation': doctor[4].date() if doctor[4] else None,
            'email': doctor[5],
            'address': doctor[6],
            'ssn': int(doctor[7]),
            'is_active_status': doctor[9] == 'Y',
            'department_id': int(doctor[8]),
            'role': 'DOCTOR',
            'qualification': doctor[11]
        }
        
        # Create doctor node
        doctor_query = create_staff_node_and_relationship(node_doctor)
        neo4j_conn.executeQuery(doctor_query, node_doctor)
    
    
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
            'date_joining': nurse[3].date(),
            'date_separation': nurse[4].date() if nurse[4] else None,
            'email': nurse[5],
            'address': nurse[6],
            'ssn': int(nurse[7]),
            'is_active_status': nurse[9] == 'Y',
            'department_id': int(nurse[8]),
            'role': 'NURSE'
        }
        
        # Create nurse node
        nurse_query = create_staff_node_and_relationship(node_nurse)
        neo4j_conn.executeQuery(nurse_query, node_nurse)
    
    
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
            'date_joining': technician[3].date(),
            'date_separation': technician[4].date() if technician[4] else None,
            'email': technician[5],
            'address': technician[6],
            'ssn': int(technician[7]),
            'is_active_status': technician[9] == 'Y',
            'department_id': int(technician[8]),
            'role': 'TECHNICIAN',
        }
        
        # Create technician node
        technician_query = create_staff_node_and_relationship(node_technician)
        neo4j_conn.executeQuery(technician_query, node_technician)
    
    
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
        room_query = """
            MERGE (r:Room {id_room: $id_room})
            ON CREATE SET r.room_type = $room_type, r.room_cost = $room_cost
            ON MATCH SET r.room_type = $room_type, r.room_cost = $room_cost
        """
        
        neo4j_conn.executeQuery(room_query, node_room)


def migrate_lab_screenings(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection, id_episode):
    lab_screenings = oracle_conn.executeQuery(f"""
        SELECT * FROM lab_screening WHERE lab_screening.episode_idepisode = {id_episode}
    """)

    for lab_screening in lab_screenings:
        # Neo4j query to create or merge the episode and technician nodes and relationship with lab screening
        lab_screening_query = """
            MATCH (e:Episode {id_episode: $id_episode})
            MATCH (s:Staff {id_emp: $id_technician})
            MERGE (e)-[r:LAB_SCREENING_TECHNICIAN {id_lab: $id_lab, test_cost: $test_cost, test_date: $test_date}]->(s)
        """

        node_lab_screening = {
            'id_lab': int(lab_screening[0]),
            'test_cost': float(lab_screening[1]),
            'test_date': lab_screening[2].date(),
            'id_technician': int(lab_screening[3]),
            'id_episode': int(lab_screening[4])
        }

        neo4j_conn.executeQuery(lab_screening_query, node_lab_screening)

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
            'registered_at': bill[6], 
            'payment_status': bill[7]
        }
        
        # Neo4j query to create or merge the bill node and relationship with episode
        bill_query = """
            MERGE (b:Bill {id_bill: $id_bill})
            ON CREATE SET b.room_cost = $room_cost, 
                          b.test_cost = $test_cost, 
                          b.other_charges = $other_charges, 
                          b.total = $total, 
                          b.registered_at = $registered_at, 
                          b.payment_status = $payment_status
            ON MATCH SET b.room_cost = $room_cost, 
                         b.test_cost = $test_cost, 
                         b.other_charges = $other_charges, 
                         b.total = $total, 
                         b.registered_at = $registered_at, 
                         b.payment_status = $payment_status
            WITH b
            MATCH (e:Episode {id_episode: $id_episode})
            MERGE (e)-[:HAS_BILL]->(b)
        """
        
        neo4j_conn.executeQuery(bill_query, node_bill)


def migrate_medicine(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection):
    # Query to retrieve all the medicines for an episode
    medicines = oracle_conn.executeQuery("SELECT * FROM medicine")
    
    for medicine in medicines:
        node_medicine = {
            'id_medicine': int(medicine[0]),
            'm_name': medicine[1],
            'm_quantity': int(medicine[2]),
            'm_cost': float(medicine[3]),
        }

        # Neo4j query to create or merge the medicine node and relationship with episode
        medicine_query = """
            MERGE (m:Medicine {id_medicine: $id_medicine})
            ON CREATE SET m.m_name = $m_name, 
                          m.m_quantity = $m_quantity, 
                          m.m_cost = $m_cost
            ON MATCH SET m.m_name = $m_name, 
                         m.m_quantity = $m_quantity, 
                         m.m_cost = $m_cost
        """
        
        neo4j_conn.executeQuery(medicine_query, node_medicine)


def migrate_prescriptions(neo4j_conn: Neo4jConnection, oracle_conn: OracleConnection, id_episode):
    migrate_medicine(neo4j_conn, oracle_conn)
    
    # Query to retrieve all the prescriptions for an episode
    prescriptions = oracle_conn.executeQuery(f""" 
        SELECT * FROM prescription 
        WHERE prescription.idepisode = {id_episode}
    """)
    
    for prescription in prescriptions:
        # Neo4j query to create or merge the episode and medicine nodes and relationships with prescription
        prescription_query = """
            MATCH (e:Episode {id_episode: $id_episode})
            MATCH (m:Medicine {id_medicine: $id_medicine})
            MERGE (e)-[r:HAS_PRESCRIPTION {id_prescription: $id_prescription, prescription_date: $prescription_date, dosage: $dosage}]->(m)
        """

        node_prescription = {
            'id_prescription': prescription[0],
            'prescription_date': prescription[1].date(),
            'dosage': int(prescription[2]),
            'id_medicine': int(prescription[3]),
            'id_episode': int(prescription[4]),
        }

        neo4j_conn.executeQuery(prescription_query, node_prescription)

def migrate_appointment(neo4j_conn: Neo4jConnection, episode):
    
    node_appointment = {
        'schedule_on': episode[2].date(),
        'appointment_date': episode[3].date(),
        'appointment_time': episode[4],
        'id_doctor': int(episode[5]),
        'id_episode': int(episode[6])
    }
    
    # Neo4j query to create or merge the episode and doctor nodes and relationship with appointment
    appointment_query = """
        MATCH (e:Episode {id_episode: $id_episode})
        MATCH (s:Staff {id_emp: $id_doctor})
        MERGE (e)-[r:APPOINTMENT_DOCTOR {schedule_on: $schedule_on, appointment_date: $appointment_date, appointment_time: $appointment_time}]->(s)
    """
    
    neo4j_conn.executeQuery(appointment_query, node_appointment)


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
            if episode[7]:
                admission_date = episode[7].date()
                discharge_date = episode[8].date() if episode[8] is not None else None

                node_episode = {
                    'id_episode': int(episode[0]),
                    'patient_id': int(episode[1]),
                    'admission_date': admission_date,
                    'discharge_date': discharge_date,
                    'id_room': int(episode[9]),
                    'id_episode': int(episode[10]),
                    'responsible_nurse': int(episode[11])
                }
                # Neo4j query to create the hospitalization node and relationship with episode
                episode_query = """
                    MERGE (e:Episode {id_episode: $id_episode})
                    ON CREATE SET e.admission_date = $admission_date,
                                  e.discharge_date = $discharge_date
                    ON MATCH SET e.admission_date = $admission_date,
                                 e.discharge_date = $discharge_date
                    WITH e
                    MATCH (p:Patient {id_patient: $patient_id})
                    MERGE (p)-[:HAS_EPISODE]->(e)
                    WITH e
                    MATCH (r:Room {id_room: $id_room})
                    MERGE (e)-[:IN_ROOM]->(r)
                    WITH e
                    MATCH (s:Staff {id_emp: $responsible_nurse})
                    MERGE (e)-[:HOSPITALIZATION_NURSE]->(s)
                """ 
            else: 
                node_episode = {
                    'id_episode': int(episode[0]),
                    'patient_id': int(episode[1])
                }
                # Neo4j query to create or merge the episode node and relationship with patient
                episode_query = """
                    MERGE (e:Episode {id_episode: $id_episode})
                    WITH e
                    MATCH (p:Patient {id_patient: $patient_id})
                    MERGE (p)-[:HAS_EPISODE]->(e)
                """
            
            neo4j_conn.executeQuery(episode_query, node_episode)
            
            # Migrate episode bills
            migrate_bills(neo4j_conn, oracle_conn, node_episode['id_episode'])
            
            # Migrate episode prescriptions
            migrate_prescriptions(neo4j_conn, oracle_conn, node_episode['id_episode'])
            # Migrate episode lab screenings
            migrate_lab_screenings(neo4j_conn, oracle_conn, node_episode['id_episode'])

            if episode[2]:
                # Migrate episode appointment
                migrate_appointment(neo4j_conn, episode)


def migrate(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # Add constraints
    add_constraints(neo4j_conn)
    
    # Inserção de pacientes em Neo4j
    migrate_patients(oracle_conn, neo4j_conn)
    
    # Insert staff elements in Neo4j
    migrate_staff(oracle_conn, neo4j_conn)
            
    # Migrate rooms
    migrate_rooms(neo4j_conn, oracle_conn)
    
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
    