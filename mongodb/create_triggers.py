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
    
def read_config_file(file_path : str):
    path = os.path.join(SCRIPT_DIR_PATH, file_path)
    
    with open(path, 'r') as json_file:
        triggers_config = json.load(json_file)
        
    config_dict = {}
    
    for config in triggers_config:
        config_dict[config['name']] = config
    
    return config_dict


def read_trigger_file(config_dir : str, file_name : str):
    path = os.path.join(config_dir, file_name)
    
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


def get_function_and_trigger_data(triggers_config : dict, trigger_name : str, service_id : str, service_name : str, j2_env: jinja2.Environment, config_dir : str) -> tuple[dict | None, dict | None]:
    trigger_data = None
    function_data = None
    
    if trigger_name in triggers_config:
        trigger_data = triggers_config[trigger_name]
        
        if 'function' in trigger_data:
            function_data = trigger_data.pop('function')
            
            if 'source_file' in function_data and 'source' not in function_data:
                source_file = function_data['source_file']
                
                code = None
                
                if 'path' in source_file:
                    path = source_file['path']
                
                    if 'template' in source_file and source_file['template'] is True:
                        if 'args' in source_file:
                            args = source_file['args']
                        else:
                            args = {}
                        
                        args['service_name'] = service_name
                        
                        try:
                            template = j2_env.get_template(path)
                            code = template.render(args)
                        except Exception as e:
                            logging.error(f'Exceção na leitura do template \'{path}\' -> "{e}".')
                    
                    else:
                        try:
                            code = read_trigger_file(config_dir, path)
                        except Exception as e:
                            logging.error(f'Exceção na leitura do ficheiro \'{path}\' -> "{e}".')
                
                function_data['source'] = code
                del function_data['source_file']
        
        
        if 'config' in trigger_data:
            trigger_config = trigger_data['config']
            trigger_data['config']['service_id'] = service_id
            
            if 'match_file' in trigger_config and 'match' not in trigger_config:
                match_file = trigger_config['match_file']
                
                match = None
                
                if 'path' in match_file:
                    path = match_file['path']
                    
                    if 'template' in match_file and match_file['template'] is True:
                        if 'args' in match_file:
                            args = match_file['args']
                        else:
                            args = {}
                        
                        try:
                            template = j2_env.get_template(path)
                            match = json.loads(template.render(args))
                        except Exception as e:
                            logging.error(f'Exceção na leitura ou deserialização do template JSON \'{path}\' -> "{e}".')
                    
                    else:
                        try:
                            match = json.loads(read_trigger_file(config_dir, path))
                        except Exception as e:
                            logging.error(f'Exceção na leitura ou deserialização do ficheiro JSON \'{path}\' -> "{e}".')
                  
                trigger_data['config']['match'] = match
                del trigger_data['config']['match_file']
        
    
    return function_data, trigger_data


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
    
    
def create_triggers(access_token: str, groupId : str, appId : str, service_id : str, service_name : str, triggers_config : dict, config_dir : str):
    j2_env = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath=config_dir))
    
    for trigger_name in triggers_config:
        function_data, trigger_data = get_function_and_trigger_data(triggers_config, trigger_name, service_id, service_name, j2_env, config_dir)
        
        create_trigger(access_token, groupId, appId, function_data, trigger_data)
        
        
def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-pubk', '--public-key', help='MongoDB Atlas public key', type=str)
    parser.add_argument('-privk', '--private-key', help='MongoDB Atlas private key', type=str)
    parser.add_argument('-pn', '--project-name', help='MongoDB Atlas project name', default='BDNoSQL-TP', type=str)
    parser.add_argument('-cn', '--cluster-name', help='MongoDB Atlas cluster name', default='Cluster0', type=str)
    parser.add_argument('-f', '--file', help='MongoDB Atlas triggers\' configuration file (JSON) path', default='triggers/triggers_config.json', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n")
    
    triggers_config = read_config_file(args.file)
    config_dir = os.path.join(SCRIPT_DIR_PATH, os.path.dirname(args.file))
    
    access_token = get_access_token(args.public_key, args.private_key)
    
    groupId = get_groupId(args.public_key, args.private_key, args.project_name)
    appId = get_appId(access_token, groupId, args.cluster_name)
    
    service_id, service_name = get_service_id_and_name(access_token, groupId, appId, args.cluster_name)
    
    create_triggers(access_token, groupId, appId, service_id, service_name, triggers_config, config_dir)
    

if __name__ == '__main__':
    main()
    