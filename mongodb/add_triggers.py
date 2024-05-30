import argparse
import requests
import json
import os

# Documentation
# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3

SCRIPT_DIR_PATH = os.path.dirname(os.path.abspath(__file__))

def read_JS_file(filename : str):
    if not filename.endswith('.js'):
        filename += '.js'
    
    path = os.path.join(SCRIPT_DIR_PATH, 'triggers', filename)
    
    with open(path, 'r') as js_file:
        return js_file.read()


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

    return response_body['access_token']


# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#section/Project-and-Application-IDs
def get_appId(access_token : str, groupId : str):
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps?product=atlas'

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    response = requests.get(url, headers=headers)
    response_body = response.json()
    
    appId = None

    for value in response_body:
        if value['name'] == 'Triggers':
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

    cluster_id = None

    for value in response_body:
        if value['name'] == cluster_name:
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
    
    response = requests.post(url, headers=headers, data=json.dumps(function_data))
    response_body = response.json()

    function_id = response_body['_id']
    
    # POST Trigger
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminCreateTrigger
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers'
    
    trigger_data['function_id'] = function_id
    
    response = requests.post(url, headers=headers, data=json.dumps(trigger_data))
    

def create_id_patient_trigger(access_token: str, groupId : str, appId : str, cluster_id : str):
    function_data = {
        'name': 'id_patientTriggerFunction',
        'private': True,
        'source': read_JS_file('id_patient_trigger')
    }
    
    trigger_data = {
        'name': 'id_patient_trigger',
        'type': 'DATABASE',
        'config': {
            'service_id': cluster_id,
            'database': 'hospital',
            'collection': 'patients',
            'operation_types': ['INSERT', 'UPDATE', 'REPLACE']
        }
    }
    
    create_trigger(access_token, groupId, appId, function_data, trigger_data)


def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-pubk', '--public-key', help='MongoDB Atlas public key', type=str)
    parser.add_argument('-privk', '--private-key', help='MongoDB Atlas private key', type=str)
    parser.add_argument('-pid', '--project-id', help='MongoDB Atlas project id', type=str)
    parser.add_argument('-cn', '--cluster-name', help='MongoDB Atlas cluster name', default='Cluster0', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    access_token = get_access_token(args.public_key, args.private_key)
    
    groupId = args.project_id
    appId = get_appId(access_token, groupId)
    
    cluster_id = get_cluster_id(access_token, groupId, appId, args.cluster_name)
    
    create_id_patient_trigger(access_token, groupId, appId, cluster_id)
    

if __name__ == '__main__':
    main()
    