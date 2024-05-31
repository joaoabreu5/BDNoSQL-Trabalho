import requests
import argparse
import logging
import inspect
import jinja2
import json
import os

# Documentation
# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3

SCRIPT_DIR_PATH = os.path.dirname(os.path.abspath(__file__))
TRIGGERS_DIR_PATH = os.path.join(SCRIPT_DIR_PATH, 'triggers')

def read_JS_file(filename : str):
    if not filename.endswith('.js'):
        filename += '.js'
    
    path = os.path.join(TRIGGERS_DIR_PATH, filename)
    
    with open(path, 'r') as js_file:
        return js_file.read()


def print_response_error(status_code : int, body : dict):    
    if 'error' in body:
        frame = inspect.currentframe().f_back
        caller_info = inspect.getframeinfo(frame)
        
        logger = logging.getLogger()
        
        log_record = logging.LogRecord(
            name=logger.name,
            level=logging.ERROR,
            pathname=caller_info.filename,
            lineno=caller_info.lineno,
            func=caller_info.function,
            msg=f'Response Status Code: {status_code}\nResponse Body: {body}',
            args=None,
            exc_info=None
        )
        
        logger.handle(log_record)
        

# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#section/Get-an-Admin-API-Session-Access-Token
def get_access_token(public_key : str, private_key : str):
    url = 'https://services.cloud.mongodb.com/api/admin/v3.0/auth/providers/mongodb-cloud/login'

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
    
    body = {
        'username': public_key,     # <Public API Key>
        'apiKey': private_key       # <Private API Key>
    }
    
    response = requests.post(url, headers=headers, data=json.dumps(body))
    response_body = response.json()
    
    print_response_error(response.status_code, response_body)
    
    access_token = None
    
    if 'access_token' in response_body:
        access_token = response_body['access_token']

    return access_token


# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#section/Project-and-Application-IDs
def get_appId(access_token : str, groupId : str):
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps?product=atlas'

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    response = requests.get(url, headers=headers)
    response_body = response.json()
    
    print_response_error(response.status_code, response_body)
    
    appId = None

    for value in response_body:
        if 'name' in value and value['name'] == 'Triggers':
            appId = value['_id']
            break
        
    return appId


# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/services/operation/adminListServices
def get_cluster_id(access_token : str, groupId : str, appId : str, cluster_name : str):
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/services'

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.get(url, headers=headers)
    response_body = response.json()
    
    print_response_error(response.status_code, response_body)

    cluster_id = None

    for value in response_body:
        if 'name' in value and value['name'] == cluster_name:
            cluster_id = value['_id']
            break
        
    return cluster_id


def create_trigger(access_token: str, groupId : str, appId : str, function_data : dict, trigger_data : dict):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    # POST JavaScript Trigger Function
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/functions/operation/adminCreateFunction
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/functions'
    
    response_POST_function = requests.post(url, headers=headers, data=json.dumps(function_data))
    response_body_POST_function = response_POST_function.json()
    
    print_response_error(response_POST_function.status_code, response_body_POST_function)
    
    # POST Trigger
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminCreateTrigger
    if '_id' in response_body_POST_function:
        url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers'
        
        trigger_data['function_id'] = response_body_POST_function['_id']
        
        response_POST_trigger = requests.post(url, headers=headers, data=json.dumps(trigger_data))
        response_body_POST_trigger = response_POST_trigger.json()
        
        print_response_error(response_POST_trigger.status_code, response_body_POST_trigger)


def create_seq_id_trigger(access_token: str, groupId : str, appId : str, cluster_id : str, cluster_name : str, 
        database_name: str, collection_name : str, field_name : str, trigger_template : jinja2.Template):
    
    trigger_name = f'{field_name}_trigger'.replace('.', '_')
    trigger_code = trigger_template.render(cluster_name_j2_var=cluster_name, field_name_j2_var=field_name)
    
    function_data = {
        'name': f'{trigger_name}_function',
        'private': True,
        'source': trigger_code
    }
    
    trigger_data = {
        'name': f'{trigger_name}',
        'type': 'DATABASE',
        'config': {
            'service_id': cluster_id,
            'database': database_name,
            'collection': collection_name,
            'operation_types': ['INSERT', 'UPDATE', 'REPLACE']
        }
    }
    
    create_trigger(access_token, groupId, appId, function_data, trigger_data)


def create_triggers(access_token: str, groupId : str, appId : str, cluster_id : str, cluster_name : str):
    database_name = 'hospital'
    episodes_coll_name = 'episodes'
    patients_coll_name = 'patients'
    staff_coll_name = 'staff'
    
    j2_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=TRIGGERS_DIR_PATH))
    seq_id_trigger_template = j2_env.get_template('seq_id_trigger.js.j2')
    
    seq_id_triggers_coll_field = (
        (patients_coll_name, 'id_patient'),
        (patients_coll_name, 'medical_history.record_id'),
        (staff_coll_name, 'emp_id'),
        (episodes_coll_name, 'bills.id_bill'),
        (episodes_coll_name, 'id_episode'),
        (episodes_coll_name, 'prescriptions.id_prescription'),
        (episodes_coll_name, 'lab_screenings.lab_id')
    )
    
    for coll_name, field_name in seq_id_triggers_coll_field:
        create_seq_id_trigger(access_token, groupId, appId, cluster_id, cluster_name, database_name, 
                              coll_name, field_name, seq_id_trigger_template)
    
    
def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-pubk', '--public-key', help='MongoDB Atlas public key', type=str)
    parser.add_argument('-privk', '--private-key', help='MongoDB Atlas private key', type=str)
    parser.add_argument('-pid', '--project-id', help='MongoDB Atlas project id', type=str)
    parser.add_argument('-cn', '--cluster-name', help='MongoDB Atlas cluster name', default='Cluster0', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n")
    
    access_token = get_access_token(args.public_key, args.private_key)
    
    groupId = args.project_id
    appId = get_appId(access_token, groupId)
    
    cluster_id = get_cluster_id(access_token, groupId, appId, args.cluster_name)
    
    create_triggers(access_token, groupId, appId, cluster_id, args.cluster_name)
    

if __name__ == '__main__':
    main()
    