import oracledb
import pymongo
import argparse
import json

class OracleConnection():
    host : str
    port : int
    user : str
    password : str
    service_name : str
    
    def __init__(self, host='localhost', port=1521, user='', password='', service_name='XEPDB1'):
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.service_name = service_name
        
    def getConnection(self):
        return oracledb.connect(host=self.host, port=self.port, 
                                user=self.user, password=self.password, service_name=self.service_name)
    
    
class MongoDBConnection():
    host : str
    port : int
    user : str
    password : str
    database : str
    
    def __init__(self, host='localhost', port=27017, user='', password='', database=''):     
        self.host = host
        self.port = int(port)
        self.user = user
        self.password = password
        self.database = database
        
    def getClient(self):
        return pymongo.MongoClient(host=self.host, port=self.port, 
                                   username=self.user, password=self.password, connect=True)
        
    def getDatabase(self, client : pymongo.MongoClient):
        return client.get_database(name=self.database)
    
    def getClientAndDatabase(self):
        client = self.getClient()
        database = self.getDatabase(client)
        return client, database
        
def get_patients_collection(cursor):

    # get data from table patient and insurance
    cursor.execute("""
        SELECT * FROM patient
        JOIN insurance ON insurance.policy_number = patient.policy_number
    """)
    results = cursor.fetchall()
    patients = []
    for row in results:
        patient = {}
        patient['id_patient'] = int(row[0])
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
        cursor.execute(f"""SELECT * FROM emergency_contact WHERE idpatient = {row[0]}""")
        emergency_contacts = cursor.fetchall()
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
        cursor.execute(f"""SELECT * FROM medical_history WHERE idpatient = {row[0]}""")
        medical_histories = cursor.fetchall()
        medical_history_list = []
        for medical_history in medical_histories:
            medical_history_obj = {
                'record_id': int(medical_history[0]),
                'condition': medical_history[1],
                'record_date': medical_history[2],
            }
            medical_history_list.append(medical_history_obj)

        patient['medical_history'] = medical_history_list
        patients.append(patient)
    return patients

def get_staff_collection(cursor):
    staff=[]
    # get data from table patient and insurance
    cursor.execute("""
        SELECT * FROM staff
        JOIN department ON department.iddepartment = staff.iddepartment
        JOIN doctor ON staff.emp_id = doctor.emp_id 
    """)
    doctors = cursor.fetchall()
    for doctor in doctors:
        doctor_obj = {}
        doctor_obj['emp_id'] = doctor[0]
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

    cursor.execute("""
        SELECT * FROM staff
        JOIN department ON department.iddepartment = staff.iddepartment
        JOIN nurse ON staff.emp_id = nurse.staff_emp_id 
    """)
    nurses = cursor.fetchall()
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

    cursor.execute("""
        SELECT * FROM staff
        JOIN department ON department.iddepartment = staff.iddepartment
        JOIN technician ON staff.emp_id = technician.staff_emp_id 
    """)
    technicians = cursor.fetchall()
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


    return staff


def get_episodes_collection(cursor):
    return

def migrate(oracleConnectObj : OracleConnection, mongodbConnectObj : MongoDBConnection):
    try:
        oracleConnection = oracleConnectObj.getConnection()

        cursor = oracleConnection.cursor()
        
        patients = get_patients_collection(cursor)
        staff = get_staff_collection(cursor)
        #episodes = get_episodes_collection(cursor)

    finally:
        cursor.close()
        oracleConnection.close()
    
    
    try:
        mongoClient, mongoDatabase = mongodbConnectObj.getClientAndDatabase()
        
        # patients collection
        mongoCollection = mongoDatabase['patients']
        mongoCollection.insert_many(patients)

        # staff collection
        mongoCollection = mongoDatabase['staff']
        mongoCollection.insert_many(staff)

        # episode collection
    
    finally:
        mongoClient.close()


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
    
    oracle_conn = OracleConnection(args.oracle_host, args.oracle_port, 
                                   args.oracle_user, args.oracle_password, args.oracle_service_name)
    
    mongodb_conn = MongoDBConnection(args.mongodb_host, args.mongodb_port, 
                                     args.mongodb_user, args.mongodb_password, args.mongodb_database)
    
    migrate(oracle_conn, mongodb_conn)


if __name__ == '__main__':
    main()
    