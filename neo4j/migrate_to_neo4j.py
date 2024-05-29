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

def migrate_patients(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # get data from table patient and insurance
    results = oracle_conn.executeQuery("""
        SELECT * FROM patient
        JOIN insurance ON insurance.policy_number = patient.policy_number
    """)

    for row in results:
        # create patient node
        node_patient = {    
            'id_patient': row[0],
            'patient_fname': row[1],
            'patient_lname': row[2],
            'blood_type': row[3],
            'phone': row[4],
            'email': row[5],
            'gender': row[6],
            'birthday': row[8]
        }

        node_insurance = {
            'policy_number': row[7],
            'provider': row[10],
            'insurance_plan': row[11],
            'co_pay': float(row[12]),
            'coverage': row[13],
            'maternity':  row[14] == 'Y',
            'dental': row[15] == 'Y',
            'optical': row[16] == 'Y',
        }

        # Create patient node
        neo4j_conn.executeQuery(f"""
            MERGE (p:Patient {{id_patient: {node_patient['id_patient']}, 
                patient_fname: '{node_patient['patient_fname']}', 
                patient_lname: '{node_patient['patient_lname']}',
                blood_type: '{node_patient['blood_type']}', 
                phone: '{node_patient['phone']}',
                email: '{node_patient['email']}',
                gender: '{node_patient['gender']}',
                birthday: '{node_patient['birthday']}'}})
            MERGE (i:Insurance {{policy_number: '{node_insurance['policy_number']}',
                provider: '{node_insurance['provider']}',
                insurance_plan: '{node_insurance['insurance_plan']}',
                co_pay: {node_insurance['co_pay']},
                coverage: '{node_insurance['coverage']}',
                maternity: {node_insurance['maternity']},
                dental: {node_insurance['dental']},
                optical: {node_insurance['optical']}}})
            MERGE (p)-[:HAS_INSURANCE]->(i)
            """)

        # Create emergency contacts and associate with patient
        emergency_contacts = oracle_conn.executeQuery(f'SELECT * FROM emergency_contact WHERE idpatient = {row[0]}')
        for contact in emergency_contacts:
            node_contact = {
                'contact_name': contact[0],
                'phone': contact[1],
                'relation': contact[2],
            }
            neo4j_conn.executeQuery(f"""
                MATCH (p:Patient {{id_patient: {node_patient['id_patient']}}})
                MERGE (c:EmergencyContact {{contact_name: '{node_contact['contact_name']}',
                    phone: '{node_contact['phone']}',
                    relation: '{node_contact['relation']}'}})
                MERGE (p)-[:HAS_EMERGENCY_CONTACT]->(c)
                """)

        # Create medical histories and associate with patient
        medical_histories = oracle_conn.executeQuery(f'SELECT * FROM medical_history WHERE idpatient = {row[0]}')
        for history in medical_histories:
            node_history = {
                'record_id': history[0],
                'condition': history[1],
                'record_date': history[2],
            }
            neo4j_conn.executeQuery(f"""
                MATCH (p:Patient {{id_patient: {node_patient['id_patient']}}})
                MERGE (m:MedicalHistory {{record_id: {node_history['record_id']}, 
                    condition: '{node_history['condition']}', 
                    record_date: '{node_history['record_date']}'}}) 
                MERGE (p)-[:HAS_MEDICAL_HISTORY]->(m)
                """)

def migrate_department(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # Get all the departments
    departments = oracle_conn.executeQuery('SELECT * FROM department')

    for department in departments:
        node_department = {
            'id_department': department[0],
            'department_head': department[1],
            'department_name': department[2],
        }

        neo4j_conn.executeQuery(f"""
            MERGE (dep:Department {{
                id_department: '{node_department['id_department']}',
                department_head: '{node_department['department_head']}',
                department_name: '{node_department['department_name']}'
            }})
        """)

def create_staff_node_and_relationship(node, node_label, department_id):
    properties_str = f"""
        emp_id: {node['emp_id']},
        emp_fname: '{node['emp_fname']}',
        emp_lname: '{node['emp_lname']}',
        date_of_joining: '{node['date_of_joining']}',
        email: '{node['email']}',
        address: '{node['address']}',
        ssn: '{node['ssn']}',
        is_active_status: {str(node['is_active_status']).lower()},
        role: '{node['role']}'
        """
    
    if 'qualification' in node:
        properties_str += f", qualification: '{node['qualification']}'"
    
    if node.get('date_separation'):
        properties_str += f", date_separation: '{node['date_separation']}'"

    query = f"""
        MERGE (n:{node_label} {{{properties_str}}})
        WITH n
        MATCH (dep:Department {{id_department: '{department_id}'}})
        MERGE (n)-[:WORKS_IN]->(dep)
    """
    return query

def migrate_staff(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    
    # Get data from table doctor and department
    doctors = oracle_conn.executeQuery("""
        SELECT * FROM staff
        JOIN doctor ON staff.emp_id = doctor.emp_id 
    """)

    for doctor in doctors:
        node_doctor = {
            'emp_id': doctor[0],
            'emp_fname': doctor[1],
            'emp_lname': doctor[2],
            'date_of_joining': doctor[3],
            'date_separation': doctor[4],
            'email': doctor[5],
            'address': doctor[6],
            'ssn': int(doctor[7]),
            'is_active_status': doctor[9] == 'Y',
            'department_id': doctor[8],
            'role': 'DOCTOR',
            'qualification': doctor[10]
        }

        doctor_query = create_staff_node_and_relationship(node_doctor, 'Doctor', node_doctor['department_id'])
        neo4j_conn.executeQuery(doctor_query)

    # Get data from table nurse and department
    nurses = oracle_conn.executeQuery("""
        SELECT * FROM staff
        JOIN nurse ON staff.emp_id = nurse.staff_emp_id 
    """)

    for nurse in nurses:
        node_nurse = {
            'emp_id': nurse[0],
            'emp_fname': nurse[1],
            'emp_lname': nurse[2],
            'date_of_joining': nurse[3],
            'date_separation': nurse[4],
            'email': nurse[5],
            'address': nurse[6],
            'ssn': int(nurse[7]),
            'is_active_status': nurse[9] == 'Y',
            'department_id': nurse[8],
            'role': 'NURSE',
        }

        nurse_query = create_staff_node_and_relationship(node_nurse, 'Nurse', node_nurse['department_id'])
        neo4j_conn.executeQuery(nurse_query)

    # Get data from table technician and department
    technicians = oracle_conn.executeQuery("""
        SELECT * FROM staff
        JOIN technician ON staff.emp_id = technician.staff_emp_id 
    """)

    for technician in technicians:
        node_technician = {
            'emp_id': technician[0],
            'emp_fname': technician[1],
            'emp_lname': technician[2],
            'date_of_joining': technician[3],
            'date_separation': technician[4],
            'email': technician[5],
            'address': technician[6],
            'ssn': int(technician[7]),
            'is_active_status': technician[9] == 'Y',
            'department_id': technician[8],
            'role': 'TECHNICIAN',
        }

        technician_query = create_staff_node_and_relationship(node_technician, 'Technician', node_technician['department_id'])
        neo4j_conn.executeQuery(technician_query)

def get_patients_ids(neo4j_conn: Neo4jConnection) -> list:
    result = neo4j_conn.executeQuery("MATCH (p:Patient) RETURN p.id_patient AS id_patient")
    return [record['id_patient'] for record in result]

def migrate_rooms(neo4j_conn : Neo4jConnection, oracle_conn : OracleConnection):
    # Get the rooms information for the hospitalization
    rooms = oracle_conn.executeQuery(f"""
        SELECT * FROM room 
    """)
    for room in rooms:
        node_room = {
            'id_room': room[0],
            'room_type': room[1],
            'room_cost': float(room[2])
        }
        neo4j_conn.executeQuery(f"""
            MERGE (r:Room {{
                id_room: {node_room['id_room']}, 
                room_type: '{node_room['room_type']}', 
                room_cost: {node_room['room_cost']}
            }})
        """)

def migrate_bills(neo4j_conn : Neo4jConnection, oracle_conn : OracleConnection, episode_id):
    # Get all the bills for the episode
    bills = oracle_conn.executeQuery(f""" 
        SELECT * FROM bill WHERE bill.idepisode = {episode_id}
    """)
    for bill in bills:
        node_bill = {
            'id_bill': bill[0],
            'room_cost': float(bill[1]),
            'test_cost': float(bill[2]),
            'other_charges': float(bill[3]),
            'total': float(bill[4]),
            'id_episode': bill[5],
            'registered_at': bill[6], 
            'payment_status': bill[7]
        }
        bill_query = f"""
            MERGE (b:Bill {{
                id_bill: {node_bill['id_bill']},
                room_cost: {node_bill['room_cost']},
                test_cost: {node_bill['test_cost']},
                other_charges: {node_bill['other_charges']},
                total: {node_bill['total']},
                registered_at: '{node_bill['registered_at']}',
                payment_status: '{node_bill['payment_status']}'
            }})
            WITH b
            MATCH (e:Episode {{id_episode: '{node_bill['id_episode']}'}})
            MERGE (e)-[:HAS_BILL]->(b)
        """
        neo4j_conn.executeQuery(bill_query)

def migrate_prescriptions(neo4j_conn : Neo4jConnection, oracle_conn : OracleConnection, episode_id):
    # Get all the prescriptions for the episode
    prescriptions = oracle_conn.executeQuery(f""" 
        SELECT * FROM prescription 
        JOIN medicine ON prescription.idmedicine = medicine.idmedicine
        WHERE prescription.idepisode = {episode_id}
    """)
    for prescription in prescriptions:
        node_medicine = {
            'id_medicine': prescription[5],
            'm_name': prescription[6],
            'm_quantity': prescription[7],
            'm_cost': prescription[8],

        }

        medicine_query = f"""
            MERGE (m:Medicine {{
                id_medicine: {node_medicine['id_medicine']},
                m_name: '{node_medicine['m_name']}',
                m_quantity: {node_medicine['m_quantity']},
                m_cost: {node_medicine['m_cost']}
            }})
        """
        neo4j_conn.executeQuery(medicine_query)

        node_prescription = {
            'id_prescription': prescription[0],
            'prescription_date': prescription[1],
            'dosage': prescription[2],
            'id_medicine': prescription[3],
            'id_episode': prescription[4],
        }
        prescription_query = f"""
            MERGE (p:Prescription {{
                id_prescription: {node_prescription['id_prescription']},
                prescription_date: '{node_prescription['prescription_date']}',
                dosage: '{node_prescription['dosage']}'
            }})
            WITH p
            MATCH (e:Episode {{id_episode: '{node_prescription['id_episode']}'}})
            MERGE (e)-[:HAS_PRESCRIPTION]->(p)
            WITH p
            MATCH (m:Medicine {{id_medicine: {node_medicine['id_medicine']}}})
            MERGE (p)-[:PRESCRIBES]->(m)
        """
        neo4j_conn.executeQuery(prescription_query)

def migrate_episodes(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    patients = get_patients_ids(neo4j_conn)
    for patient in patients:
        
        # Retrieve episodes for the patient from Oracle
        episodes = oracle_conn.executeQuery(f"""
            SELECT * FROM episode
            LEFT JOIN appointment ON episode.idepisode = appointment.idepisode
            LEFT JOIN hospitalization ON episode.idepisode = hospitalization.idepisode 
            WHERE patient_idpatient = {patient}
        """)

        for episode in episodes:
            node_episode = {
                'id_episode': episode[0],
                'patient_id': episode[1],
            }
            episode_query = f"""
                MERGE (e:Episode {{id_episode: '{node_episode['id_episode']}', patient_id: '{node_episode['patient_id']}'}})
                WITH e
                MATCH (p:Patient {{id_patient: {node_episode['patient_id']}}})
                MERGE (p)-[:HAS_EPISODE]->(e)
            """
            neo4j_conn.executeQuery(episode_query)
            
            migrate_bills(neo4j_conn, oracle_conn, node_episode['id_episode'])
            migrate_prescriptions(neo4j_conn, oracle_conn, node_episode['id_episode'])

        
            if episode[2]:

                node_appointment = {
                    'schedule_on': episode[2],
                    'appointment_date': episode[3],
                    'appointment_time': episode[4],
                    'id_doctor': int(episode[5]),
                    'id_episode': episode[6]
                }
                appointment_query = f"""
                    MERGE (a:Appointment {{
                        schedule_on: '{node_appointment['schedule_on']}', 
                        appointment_date: '{node_appointment['appointment_date']}', 
                        appointment_time: '{node_appointment['appointment_time']}'
                    }})
                    WITH a            
                    MATCH (e:Episode {{id_episode: '{node_appointment['id_episode']}'}})
                    MERGE (e)-[:HAS_APPOINTMENT]->(a)
                    WITH a
                    MATCH (d:Doctor {{emp_id: {node_appointment['id_doctor']}}})
                    MERGE (a)-[:SCHEDULED_BY]->(d)
                """
                neo4j_conn.executeQuery(appointment_query)

            if episode[7]:
                node_hospitalization = {
                    'admission_date': episode[7],
                    'discharge_date': episode[8],
                    'id_room': episode[9],
                    'id_episode': episode[10],
                    'responsible_nurse': int(episode[11])
                }

                hospitalization_query = f"""
                    MERGE (h:Hospitalization {{
                        admission_date: '{node_hospitalization['admission_date']}', 
                        discharge_date: '{node_hospitalization['discharge_date']}'
                    }})
                    WITH h
                    MATCH (e:Episode {{id_episode: '{node_hospitalization['id_episode']}'}})
                    MERGE (e)-[:HAS_HOSPITALIZATION]->(h)
                    WITH h
                    MATCH (n:Nurse {{emp_id: {node_hospitalization['responsible_nurse']}}})
                    MERGE (h)-[:RESPONSIBLE_NURSE]->(n)
                    WITH h
                    MATCH (r:Room {{id_room: {node_hospitalization['id_room']}}})
                    MERGE (h)-[:IN_ROOM]->(r)
                """
                neo4j_conn.executeQuery(hospitalization_query)




def migrate(oracle_conn : OracleConnection, neo4j_conn : Neo4jConnection):
    # Inserção de pacientes em Neo4j
    migrate_patients(oracle_conn, neo4j_conn)
    # Insert department elements in Neo4j
    migrate_department(oracle_conn, neo4j_conn)
    # Insert staff elements in Neo4j
    migrate_staff(oracle_conn, neo4j_conn)
    # Insert room elements in Neo4j
    migrate_rooms(neo4j_conn, oracle_conn)
    # Insert episode elements in Neo4j
    migrate_episodes(oracle_conn, neo4j_conn)


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
    