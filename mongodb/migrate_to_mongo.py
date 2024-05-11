import oracledb
import pymongo
import argparse
import logging
import json

from bson import ObjectId
from datetime import date, datetime

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
    
    
class MongoDBConnection():
    host : str
    port : int
    user : str
    password : str
    database_name : str
    collection_names : list
    client : pymongo.MongoClient
    database : pymongo.database.Database
    collections : dict
    
    def __init__(self, host='localhost', port=27017, user='', password='', database_name=''):     
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.database_name = database_name
        self.collection_names = ('patients', 'staff', 'episodes', 'counters')   # Não alterar a ordem dos valores do tuplo!
        self.addClient()
        self.addDatabase()
        self.addCollections()
    
    def addClient(self):
        self.client = pymongo.MongoClient(host=self.host, port=self.port, 
                                          username=self.user, password=self.password)
        
    def addDatabase(self):
        self.database = self.client.get_database(name=self.database_name)
    
    def addCollections(self):
        self.collections = {}
        for collection in self.collection_names:
            self.collections[collection] = self.database.get_collection(name=collection)
    
    def getPatientsColName(self) -> str:
        return self.collection_names[0]
    
    def getStaffColName(self) -> str:
        return self.collection_names[1]
    
    def getEpisodesColName(self) -> str:
        return self.collection_names[2]
    
    def getCountersColName(self) -> str:
        return self.collection_names[3]
         
    def getPatientsCollection(self) -> pymongo.collection.Collection:
        return self.collections[self.getPatientsColName()]
    
    def getStaffCollection(self) -> pymongo.collection.Collection:
        return self.collections[self.getStaffColName()]
    
    def getEpisodesCollection(self) -> pymongo.collection.Collection:
        return self.collections[self.getEpisodesColName()]
    
    def getCountersCollection(self) -> pymongo.collection.Collection:
        return self.collections[self.getCountersColName()]
    
    def close(self):
        self.client.close()


def get_max(current_max : None | int, value : int):
    if current_max is None or value > current_max:
        return value
    else:
        return current_max


def format_exception_message(message, exception):
    return f'{message}:\n\n\t{exception}'
    
    
def convert_to_JSON_serializable(obj):
    if isinstance(obj, list) or isinstance(obj, set) or isinstance(obj, tuple):
        converted_obj = []
        
        for value in obj:
            converted_obj.append(convert_to_JSON_serializable(value))
            
        if isinstance(obj, tuple):
            converted_obj = tuple(converted_obj)
                
    elif isinstance(obj, dict):
        converted_obj = {}
        
        for key, value in obj.items():
            converted_obj[key] = convert_to_JSON_serializable(value)
        
    elif isinstance(obj, datetime):
        converted_obj = obj.strftime("ISODate('%Y-%m-%d %H:%M:%S')")
            
    elif isinstance(obj, date):
        converted_obj = obj.strftime("ISODate('%Y-%m-%d')")
    
    elif isinstance(obj, ObjectId):
        converted_obj = f"ObjectId('{obj}')"
    
    else:
        converted_obj = obj
    
    return converted_obj
    
    
def print_document(doc):    
    print(json.dumps(convert_to_JSON_serializable(doc), ensure_ascii=False, indent=2))
    

def create_collections_indexes(mongo_conn : MongoDBConnection):
    # 'patients' collection
    patientsCol = mongo_conn.getPatientsCollection()
        
    patientsCol.create_index([('id_patient', -1)], unique=True)
    patientsCol.create_index([('medical_history.record_id', -1)], unique=True, sparse=True)
    patientsCol.create_index([('_id', -1), 'emergency_contacts.phone'], unique=True, sparse=True)
    
    # 'staff' collection
    staffCol = mongo_conn.getStaffCollection()
    
    staffCol.create_index([('emp_id', -1)], unique=True)
    
    # 'episodes' collection
    episodesCol = mongo_conn.getEpisodesCollection()
    
    episodesCol.create_index([('id_episode', -1)], unique=True)
    episodesCol.create_index([('prescriptions.id_prescription', -1)], unique=True, sparse=True)
    episodesCol.create_index([('bills.id_bill', -1)], unique=True, sparse=True)
    episodesCol.create_index([('lab_screenings.lab_id', -1)], unique=True, sparse=True)
    
    # 'counters' collection
    countersCol = mongo_conn.getCountersCollection()
    countersCol.create_index(['field', 'col'], unique=True)


def migrate_patients(oracle_conn : OracleConnection, mongo_conn : MongoDBConnection) -> pymongo.results.InsertManyResult:
    patients = []
    
    # get data from table patient and insurance
    results = oracle_conn.executeQuery("""
        SELECT * FROM patient
        JOIN insurance ON insurance.policy_number = patient.policy_number
    """)
    
    max_id_patient = None
    max_record_id = None
    
    for row in results:
        id_patient = int(row[0])
        
        max_id_patient = get_max(max_id_patient, id_patient)
        
        patient = {}
        patient['id_patient'] = id_patient
        patient['patient_fname'] = row[1]
        patient['patient_lname'] = row[2]
        patient['blood_type'] = row[3]
        patient['phone'] = row[4]
        patient['email'] = row[5]
        patient['gender'] = row[6]
        patient['birthday'] = row[8]
        patient['insurance'] = {
            'policy_number': row[7],
            'provider': row[10],
            'insurance_plan': row[11],
            'co_pay': float(row[12]),
            'coverage': row[13],
        }
        patient['insurance']['maternity'] = False
        patient['insurance']['dental'] = False
        patient['insurance']['optical'] = False
        
        if row[14] == 'Y':
            patient['insurance']['maternity'] = True
        if row[15] == 'Y':
            patient['insurance']['dental'] = True
        if row[16] == 'Y':
            patient['insurance']['optical'] = True

        
        # get data from table emergency_contact
        emergency_contacts = oracle_conn.executeQuery(f'SELECT * FROM emergency_contact WHERE idpatient = {row[0]}')
        
        emergency_contact_list = []
        for emergency_contact in emergency_contacts:
            emergency_contact_obj = {
                'contact_name': emergency_contact[0],
                'phone': emergency_contact[1],
                'relation': emergency_contact[2],
            }
            
            emergency_contact_list.append(emergency_contact_obj)
    
        patient['emergency_contact'] = emergency_contact_list

        
        # get data from table medical_history
        medical_histories = oracle_conn.executeQuery(f'SELECT * FROM medical_history WHERE idpatient = {row[0]}')
        
        medical_history_list = []
        for medical_history in medical_histories:
            record_id = int(medical_history[0])
            
            max_record_id = get_max(max_record_id, record_id)
            
            medical_history_obj = {
                'record_id': record_id,
                'condition': medical_history[1],
                'record_date': medical_history[2],
            }
            
            medical_history_list.append(medical_history_obj)

        patient['medical_history'] = medical_history_list


        # Append the document to the patients list
        patients.append(patient)
    
    
    patients_col_name = mongo_conn.getPatientsColName()

    counters = [
        {
            'field': 'id_patient',
            'col': patients_col_name,
            'seq': max_id_patient
        },
        {
            'field': 'medical_history.record_id',
            'col': patients_col_name,
            'seq': max_record_id
        }
    ]
    
        
    patients_insertion = mongo_conn.getPatientsCollection().insert_many(patients)
    mongo_conn.getCountersCollection().insert_many(counters)
        
    return patients_insertion


def migrate_staff(oracle_conn : OracleConnection, mongo_conn : MongoDBConnection) -> pymongo.results.InsertManyResult:
    staff = []
    
    # get data from table patient and insurance
    doctors = oracle_conn.executeQuery("""
        SELECT * FROM staff
        JOIN department ON department.iddepartment = staff.iddepartment
        JOIN doctor ON staff.emp_id = doctor.emp_id 
    """)
    
    max_emp_id = None
    
    for doctor in doctors:
        emp_id = doctor[0]
        
        max_emp_id = get_max(max_emp_id, emp_id)
        
        doctor_obj = {}
        doctor_obj['emp_id'] = emp_id
        doctor_obj['emp_fname'] = doctor[1]
        doctor_obj['emp_lname'] = doctor[2]
        doctor_obj['date_joining'] = doctor[3]
        
        if doctor[4] != None:
            doctor_obj['date_separation'] = doctor[4]
        
        doctor_obj['email'] = doctor[5]
        doctor_obj['address'] = doctor[6]
        doctor_obj['ssn'] = int(doctor[7])
        doctor_obj['is_active_status'] = False
        
        if doctor[9] == 'Y':
            doctor_obj['is_active_status'] = True
        
        doctor_obj['department'] = {
            'id_department': doctor[8],
            'department_head': doctor[11],
            'department_name': doctor[12],
        }
        doctor_obj['role'] = 'DOCTOR'
        doctor_obj['qualifications'] = doctor[15]
        
        staff.append(doctor_obj)

    
    nurses = oracle_conn.executeQuery("""
        SELECT * FROM staff
        JOIN department ON department.iddepartment = staff.iddepartment
        JOIN nurse ON staff.emp_id = nurse.staff_emp_id 
    """)
    
    for nurse in nurses:
        nurse_obj = {}
        nurse_obj['emp_id'] = nurse[0]
        nurse_obj['emp_fname'] = nurse[1]
        nurse_obj['emp_lname'] = nurse[2]
        nurse_obj['date_joining'] = nurse[3]
        
        if nurse[4] != None:
            nurse_obj['date_separation'] = nurse[4]
            
        nurse_obj['email'] = nurse[5]
        nurse_obj['address'] = nurse[6]
        nurse_obj['ssn'] = int(nurse[7])
        nurse_obj['is_active_status'] = False
        
        if nurse[9] == 'Y':
            nurse_obj['is_active_status'] = True
        
        nurse_obj['department'] = {
            'id_department': nurse[8],
            'department_head': nurse[11],
            'department_name': nurse[12],
        }
        nurse_obj['role'] = 'NURSE'
        
        staff.append(nurse_obj)

    
    technicians = oracle_conn.executeQuery("""
        SELECT * FROM staff
        JOIN department ON department.iddepartment = staff.iddepartment
        JOIN technician ON staff.emp_id = technician.staff_emp_id 
    """)
    
    for technician in technicians:
        technician_obj = {}
        technician_obj['emp_id'] = technician[0]
        technician_obj['emp_fname'] = technician[1]
        technician_obj['emp_lname'] = technician[2]
        technician_obj['date_joining'] = technician[3]
        
        if technician[4] is not None:
            technician_obj['date_separation'] = technician[4]
            
        technician_obj['email'] = technician[5]
        technician_obj['address'] = technician[6]
        technician_obj['ssn'] = int(technician[7])
        technician_obj['is_active_status'] = technician[9] == 'Y'
        technician_obj['department'] = {
            'id_department': technician[8],
            'department_head': technician[11],
            'department_name': technician[12],
        }
        technician_obj['role'] = 'TECHNICIAN'
        
        staff.append(technician_obj)

    
    staff_col_name = mongo_conn.getStaffColName()
    
    counters = [
        {
            'field': 'emp_id',
            'col': staff_col_name,
            'seq': max_emp_id
        }
    ]
    
    
    staff_insertion = mongo_conn.getStaffCollection().insert_many(staff)
    mongo_conn.getCountersCollection().insert_many(counters)
        
    return staff_insertion


def get_ObjectId(oid: int, objectIds: list, role: str):
    for obj in objectIds:
        if obj['emp_id'] == oid and obj['role'] == role:
            return obj['_id']
    return None

def migrate_episodes(oracle_conn: OracleConnection, 
                     mongo_conn: MongoDBConnection, 
                     patients_ids: list, staff_ids: list) -> pymongo.results.InsertManyResult:
    episodes = []

    # Retrieve the inserted patient documents
    inserted_patients = list(mongo_conn.getPatientsCollection().find({'_id': {'$in': patients_ids}}, {'id_patient': 1}))
    
    # Retrieve the inserted staff documents
    inserted_staff = list(mongo_conn.getStaffCollection().find({'_id': {'$in': staff_ids}}, {'emp_id': 1, 'role': 1}))
    
    max_id_episode = None
    max_id_prescription = None
    max_id_bill = None
    max_lab_id = None
    
    for patient in inserted_patients:
        episodes_oracle = oracle_conn.executeQuery(f"""
            SELECT * FROM episode 
            LEFT JOIN appointment ON episode.idepisode = appointment.idepisode
            LEFT JOIN hospitalization ON episode.idepisode = hospitalization.idepisode 
            WHERE patient_idpatient = {patient['id_patient']}
        """)
        
        for episode in episodes_oracle:
            id_episode = int(episode[0])
            max_id_episode = get_max(max_id_episode, id_episode)
            
            episode_object = {}
            episode_object['id_episode'] = id_episode
            episode_object['id_patient'] = patient['_id']
            episode_object['prescriptions'] = []
            episode_object['bills'] = []
            episode_object['lab_screenings'] = []

            if episode[2]:
                appointment_object = {}
                appointment_object['schedule_on'] = episode[2]
                appointment_object['appointment_date'] = episode[3]
                appointment_object['appointment_time'] = episode[4]
                appointment_object['id_doctor'] = get_ObjectId(episode[5], inserted_staff, 'DOCTOR')
                episode_object['appointment'] = appointment_object
            
            if episode[7]:
                hospitalization_object = {}
                hospitalization_object['admission_date'] = episode[7]
                hospitalization_object['discharge_date'] = episode[8]
                hospitalization_object['responsible_nurse'] = get_ObjectId(episode[11], inserted_staff, 'NURSE')
                
                # Get the rooms information for the hospitalization
                hospitalization = oracle_conn.executeSingletonQuery(f"""
                    SELECT * FROM room WHERE idroom = {episode[9]} 
                """)
                
                hospitalization_object['room'] = {
                    'id_room': int(hospitalization[0]),
                    'room_type': hospitalization[1],
                    'room_cost': float(hospitalization[2]),
                }
                
                episode_object['hospitalization'] = hospitalization_object
            
            # Get all the prescriptions for the episode
            prescriptions = oracle_conn.executeQuery(f""" 
                SELECT * FROM prescription 
                JOIN medicine ON prescription.idmedicine = medicine.idmedicine
                WHERE prescription.idepisode = {episode[0]}
            """)
            
            for prescription in prescriptions:
                id_prescription = int(prescription[0])
                max_id_prescription = get_max(max_id_prescription, id_prescription)
                
                prescription_object = {}
                prescription_object['id_prescription'] = id_prescription
                prescription_object['prescription_date'] = prescription[1]
                prescription_object['dosage'] = int(prescription[2])
                prescription_object['medicine'] = {
                    'id_medicine': int(prescription[5]),
                    'm_name': prescription[6],
                    'm_quantity': int(prescription[7]),
                    'm_cost': float(prescription[8]),
                }
                episode_object['prescriptions'].append(prescription_object)
            
            # Get all the bills for the episode
            bills = oracle_conn.executeQuery(f""" 
                SELECT * FROM bill WHERE bill.idepisode = {episode[0]}
            """)
            
            for bill in bills:
                id_bill = bill[0]
                max_id_bill = get_max(max_id_bill, id_bill)
                
                bill_object = {}
                bill_object['id_bill'] = id_bill
                bill_object['room_cost'] = float(bill[1])
                bill_object['test_cost'] = float(bill[2])
                bill_object['other_charges'] = float(bill[3])
                bill_object['total'] = float(bill[4])
                bill_object['registered_at'] = bill[5]
                bill_object['payment_status'] = bill[6]
                episode_object['bills'].append(bill_object)

            # Get all the lab screenings for the episode
            lab_screenings = oracle_conn.executeQuery(f"""
                SELECT * FROM lab_screening WHERE lab_screening.episode_idepisode = {episode[0]}
            """)
            
            for lab_screening in lab_screenings:
                lab_id = int(lab_screening[0])
                max_lab_id = get_max(max_lab_id, lab_id)
                
                lab_screening_object = {}
                lab_screening_object['lab_id'] = lab_id
                lab_screening_object['test_cost'] = float(lab_screening[1])
                lab_screening_object['test_date'] = lab_screening[2]
                lab_screening_object['id_technician'] = get_ObjectId(lab_screening[3], inserted_staff, 'TECHNICIAN')
                episode_object['lab_screenings'].append(lab_screening_object)
            
            episodes.append(episode_object)
    
    
    episodes_col_name = mongo_conn.getEpisodesColName()
    
    counters = [
        {
            'field': 'id_episode',
            'col': episodes_col_name,
            'seq': max_id_episode
        },
        {
            'field': 'prescriptions.id_prescription',
            'col': episodes_col_name,
            'seq': max_id_prescription
        },
        {
            'field': 'bills.id_bill',
            'col': episodes_col_name,
            'seq': max_id_bill
        },
        {
            'field': 'lab_screenings.lab_id',
            'col': episodes_col_name,
            'seq': max_lab_id
        }
    ]
    
    
    episodes_insertion = mongo_conn.getEpisodesCollection().insert_many(episodes)
    mongo_conn.getCountersCollection().insert_many(counters)
        
    return episodes_insertion


def migrate(oracle_conn : OracleConnection, mongo_conn : MongoDBConnection):
    try:
        # Create collection's indexes
        create_collections_indexes(mongo_conn)
        
        # Migrate 'patients' data
        patients_insertion = migrate_patients(oracle_conn, mongo_conn)
        patients_ids = patients_insertion.inserted_ids

        # Migrate 'staff' data
        staff_insertion = migrate_staff(oracle_conn, mongo_conn)
        staff_ids = staff_insertion.inserted_ids

        # Migrate 'episodes' data
        migrate_episodes(oracle_conn, mongo_conn, patients_ids, staff_ids)
    
    except Exception as e:
        logging.critical(format_exception_message('Erro na migração de Oracle para MongoDB', e))


def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-oh', '--oracle-host', help='Oracle host', default='localhost', type=str)
    parser.add_argument('-op', '--oracle-port', help='Oracle port', default=1521, type=int)
    parser.add_argument('-ou', '--oracle-user', help='Oracle username', default='hospital', type=str)
    parser.add_argument('-opwd', '--oracle-password', help='Oracle password', default='hospital', type=str)
    parser.add_argument('-osn', '--oracle-service-name', help='Oracle service name', default='XEPDB1', type=str)
    
    parser.add_argument('-mh', '--mongodb-host', help='MongoDB host', default='localhost', type=str)
    parser.add_argument('-mp', '--mongodb-port', help='MongoDB port', default=27017, type=int)
    parser.add_argument('-mu', '--mongodb-user', help='MongoDB username', default='', type=str)
    parser.add_argument('-mpwd', '--mongodb-password', help='MongoDB password', default='', type=str)
    parser.add_argument('-md', '--mongodb-database', help='MongoDB database name', default='Hospital', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n\n")
    
    oracle_conn = OracleConnection(args.oracle_host, args.oracle_port, 
                                   args.oracle_user, args.oracle_password, args.oracle_service_name)
    
    mongo_conn = MongoDBConnection(args.mongodb_host, args.mongodb_port,
                                   args.mongodb_user, args.mongodb_password, args.mongodb_database)
    
    migrate(oracle_conn, mongo_conn)
    
    oracle_conn.close()
    mongo_conn.close()


if __name__ == '__main__':
    main()
    