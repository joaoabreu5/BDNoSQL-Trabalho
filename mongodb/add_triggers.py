import requests
import argparse
import logging
import inspect
import jinja2
import json
import os

# Documentation
# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3
# https://www.mongodb.com/docs/atlas/reference/api-resources-spec/v2

SCRIPT_DIR_PATH = os.path.dirname(os.path.abspath(__file__))
TRIGGERS_DIR_PATH = os.path.join(SCRIPT_DIR_PATH, 'triggers')

def read_JS_file(filename : str):
    if not filename.endswith('.js'):
        filename += '.js'
    
    path = os.path.join(TRIGGERS_DIR_PATH, filename)
    
    with open(path, 'r') as js_file:
        return js_file.read()


def check_response_status(response: requests.Response, success_code : int):
    status_code = response.status_code
    success = True
        
    if status_code != success_code:
        success = False
        
        frame = inspect.currentframe().f_back
        caller_info = inspect.getframeinfo(frame)
        
        try:
            response_body = response.json()
        except Exception:
            if response.text == '':
                response_body = response.content
            else:
                response_body = response.text
        
        logger = logging.getLogger()
        
        log_record = logging.LogRecord(
            name=logger.name,
            level=logging.ERROR,
            pathname=caller_info.filename,
            lineno=caller_info.lineno,
            func=caller_info.function,
            msg=f'Response Status Code: {status_code}\nResponse Body: {response_body}',
            args=None,
            exc_info=None
        )
        
        logger.handle(log_record)
    
    return success


def get_data_source_config(cluster_name : str):
    return {
        'name': cluster_name,
        'type': 'mongodb-atlas',
        'config': {
            'clusterName': cluster_name,
        }
    }
        

# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#section/Get-an-Admin-API-Session-Access-Token
def get_access_token(public_key : str, private_key : str) -> str | None:
    url = 'https://services.cloud.mongodb.com/api/admin/v3.0/auth/providers/mongodb-cloud/login'

    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
    
    body = {
        'username': public_key,     # <Public API Key>
        'apiKey': private_key       # <Private API Key>
    }
    
    access_token = None
    
    response = requests.post(url, headers=headers, data=json.dumps(body))
    success = check_response_status(response, 200)
    
    if success:
        response_body = response.json()
        
        if 'access_token' in response_body:
            access_token = response_body['access_token']

    return access_token


# https://www.mongodb.com/docs/atlas/reference/api-resources-spec/v2/#tag/Projects/operation/getProjectByName
def get_groupId(public_key : str, private_key : str, groupName : str) -> str | None:
    url = f'https://cloud.mongodb.com/api/atlas/v2/groups/byName/{groupName}'
    
    headers = {
        'Accept': 'application/vnd.atlas.2024-05-30+json'
    }
    
    groupId = None
    
    response = requests.get(url, auth=requests.auth.HTTPDigestAuth(public_key, private_key), headers=headers)
    success = check_response_status(response, 200)
    
    if success:
        response_body = response.json()
        
        if 'id' in response_body:
            groupId = response_body['id']
        
    return groupId


def get_appId(access_token : str, groupId : str, cluster_name : str) -> str | None:
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    appId = None
    
    # GET Apps list
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#section/Project-and-Application-IDs
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/apps/operation/adminListApplications
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps?product=atlas'
    
    response_GET = requests.get(url, headers=headers)
    success_GET = check_response_status(response_GET, 200)
    
    if success_GET:
        response_body_GET = response_GET.json()
        
        for value in response_body_GET:
            if 'product' in value and value['product'] == 'atlas':
                appId = value['_id']
                break
        
        if appId is None:
            # POST a new App (of 'atlas' type, for Atlas Triggers)
            # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/apps/operation/adminCreateApplication
            url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps?product=atlas'
            
            body = {
                'name': 'Triggers',
                'data_source': get_data_source_config(cluster_name)
            }
            
            response_POST = requests.post(url, headers=headers, data=json.dumps(body))
            success_POST = check_response_status(response_POST, 201)
            
            if success_POST:
                response_body_POST = response_POST.json()
                
                appId = response_body_POST['_id']
    
    
    return appId


def get_service_id_and_name(access_token : str, groupId : str, appId : str, cluster_name : str) -> tuple[str | None, str | None]:
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
        
    service_id = None
    service_name = None
    
    # GET App configuration
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/apps/operation/adminPullAppConfiguration
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/pull'
    
    response_GET_app_config = requests.get(url, headers=headers)
    success_GET_app_config = check_response_status(response_GET_app_config, 200)
    
    if success_GET_app_config:
        response_body_GET_app_config = response_GET_app_config.json()
        
        data_sources = response_body_GET_app_config['data_sources']
        
        for data_source in data_sources:
            if data_source['config']['clusterName'] == cluster_name:
                service_name = data_source['name']
                break
        
        
        if service_name is not None:
            # GET list of data sources
            # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/services/operation/adminListServices
            url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/services'
            
            response_GET_list_data_sources = requests.get(url, headers=headers)
            success_GET_list_data_sources = check_response_status(response_GET_list_data_sources, 200)
            
            if success_GET_list_data_sources:
                response_body_GET_list_data_sources = response_GET_list_data_sources.json()
                            
                for value in response_body_GET_list_data_sources:
                    if 'name' in value and value['name'] == service_name:
                        service_id = value['_id']
                        break  
        else:
            # POST data source
            # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/services/operation/adminCreateService
            url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/services'
            
            body = get_data_source_config(cluster_name)
            
            response_POST = requests.post(url, headers=headers, data=json.dumps(body))
            success_POST = check_response_status(response_POST, 201)
            
            if success_POST:
                response_body_POST = response_POST.json()
                
                service_id = response_body_POST['_id']
                service_name = response_body_POST['name']
    
    
    return service_id, service_name


def create_trigger(access_token: str, groupId : str, appId : str, function_data : dict, trigger_data : dict):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    # POST JavaScript Trigger Function
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/functions/operation/adminCreateFunction
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/functions'
    
    response_POST_function = requests.post(url, headers=headers, data=json.dumps(function_data))
    success_POST_function = check_response_status(response_POST_function, 201)
    
    if success_POST_function:
        response_body_POST_function = response_POST_function.json()
        
        # POST Trigger
        # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminCreateTrigger
        if '_id' in response_body_POST_function:
            url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers'
            
            trigger_data['function_id'] = response_body_POST_function['_id']
            
            response_POST_trigger = requests.post(url, headers=headers, data=json.dumps(trigger_data))
            
            check_response_status(response_POST_trigger, 201)


def create_seq_id_trigger(access_token: str, groupId : str, appId : str, service_id : str, service_name : str, 
        database_name: str, collection_name : str, field_name : str | tuple, trigger_template : jinja2.Template):
    
    if len(field_name) == 1:
        field_name = field_name[0]
    
    if isinstance(field_name, str):
        trigger_name = f'{field_name}_trigger'
        trigger_code = trigger_template.render(service_name_j2_var=service_name, field_name_j2_var=field_name)
        
    elif len(field_name) == 2:
        list_name, list_obj_field_name = field_name
        
        trigger_name = f'{list_name}_{list_obj_field_name}_trigger'
        trigger_code = trigger_template.render(service_name_j2_var=service_name, 
                                               list_name_j2_var=list_name, obj_field_name_j2_var=list_obj_field_name)
    
    function_data = {
        'name': f'{trigger_name}_function',
        'private': True,
        'source': trigger_code
    }
    
    trigger_data = {
        'name': f'{trigger_name}',
        'type': 'DATABASE',
        'config': {
            'service_id': service_id,
            'database': database_name,
            'collection': collection_name,
            'operation_types': ['INSERT', 'UPDATE', 'REPLACE'],
            'tolerate_resume_errors': True
        }
    }
    
    create_trigger(access_token, groupId, appId, function_data, trigger_data)


def create_triggers(access_token: str, groupId : str, appId : str, service_id : str, service_name : str):
    database_name = 'hospital'
    episodes_coll_name = 'episodes'
    patients_coll_name = 'patients'
    staff_coll_name = 'staff'
    
    j2_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=TRIGGERS_DIR_PATH))
    
    seq_id_trigger_template = j2_env.get_template('seq_id_trigger.js.j2')
    seq_id_list_trigger_template = j2_env.get_template('seq_id_list_trigger.js.j2')
    
    seq_id_triggers_coll_field = (
        (patients_coll_name, 'id_patient', seq_id_trigger_template),
        (episodes_coll_name, 'id_episode', seq_id_trigger_template),
        (staff_coll_name, 'emp_id', seq_id_trigger_template),
        (patients_coll_name, ('medical_history', 'record_id'), seq_id_list_trigger_template),
        (episodes_coll_name, ('bills', 'id_bill'), seq_id_list_trigger_template),
        (episodes_coll_name, ('prescriptions', 'id_prescription'), seq_id_list_trigger_template),
        (episodes_coll_name, ('lab_screenings', 'lab_id'), seq_id_list_trigger_template)
    )
    
    for coll_name, field_name, trigger_template in seq_id_triggers_coll_field:
        create_seq_id_trigger(access_token, groupId, appId, service_id, service_name, database_name, 
                              coll_name, field_name, trigger_template)
    
    
def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-pubk', '--public-key', help='MongoDB Atlas public key', type=str)
    parser.add_argument('-privk', '--private-key', help='MongoDB Atlas private key', type=str)
    parser.add_argument('-pn', '--project-name', help='MongoDB Atlas project name', default='BDNoSQL-TP', type=str)
    parser.add_argument('-cn', '--cluster-name', help='MongoDB Atlas cluster name', default='Cluster0', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n")
    
    access_token = get_access_token(args.public_key, args.private_key)
    
    groupId = get_groupId(args.public_key, args.private_key, args.project_name)
    appId = get_appId(access_token, groupId, args.cluster_name)
    
    service_id, service_name = get_service_id_and_name(access_token, groupId, appId, args.cluster_name)
    
    create_triggers(access_token, groupId, appId, service_id, service_name)
    

if __name__ == '__main__':
    main()
    