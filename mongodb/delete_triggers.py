import argparse
import requests
import json

# Documentation
# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3


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


def delete_triggers(access_token: str, groupId : str, appId : str, trigger_names : list[str]):    
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    # GET all triggers
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminListTriggers
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers'
    
    response = requests.get(url, headers=headers)
    response_body = response.json()
        
    function_ids = []
    trigger_ids = []
    
    for value in response_body:
        if value['name'] in trigger_names:
            trigger_ids.append(value['_id'])
            function_ids.append(value['function_id'])
    
    
    # DELETE each trigger
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminDeleteTrigger
    for triggerId in trigger_ids:
        url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers/{triggerId}'
        
        response = requests.delete(url, headers=headers)
    
    
    # DELETE each function
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/functions/operation/adminDeleteFunction
    for functionId in function_ids:
        url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/functions/{functionId}'
        
        response = requests.delete(url, headers=headers)
    
    
def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-pubk', '--public-key', help='MongoDB Atlas public key', type=str)
    parser.add_argument('-privk', '--private-key', help='MongoDB Atlas private key', type=str)
    parser.add_argument('-pid', '--project-id', help='MongoDB Atlas project id', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    access_token = get_access_token(args.public_key, args.private_key)
    
    groupId = args.project_id
    appId = get_appId(access_token, groupId)
    
    trigger_names = ['id_patient_trigger']
    
    delete_triggers(access_token, groupId, appId, trigger_names)
    

if __name__ == '__main__':
    main()
    