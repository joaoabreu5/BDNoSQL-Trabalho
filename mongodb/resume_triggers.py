import requests
import argparse
import logging
import inspect
import json

# Documentation
# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3
# https://www.mongodb.com/docs/atlas/reference/api-resources-spec/v2

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


# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#section/Project-and-Application-IDs
# https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/apps/operation/adminListApplications
def get_appId(access_token : str, groupId : str) -> str | None:
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps?product=atlas'

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    appId = None
    
    response = requests.get(url, headers=headers)
    success = check_response_status(response, 200)
    
    if success:
        response_body = response.json()
        
        for value in response_body:
            if 'product' in value and value['product'] == 'atlas':
                appId = value['_id']
                break
        
    return appId


def resume_triggers(access_token: str, groupId : str, appId : str, trigger_names : list[str]):    
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {access_token}'
    }
    
    # GET all triggers
    # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminListTriggers
    url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers'
    
    response_GET = requests.get(url, headers=headers)
    success = check_response_status(response_GET, 200)
    
    if success:
        response_body_GET = response_GET.json()
        
        trigger_ids = []
        
        for value in response_body_GET:
            if 'name' in value and value['name'] in trigger_names:
                trigger_ids.append(value['_id'])
        
        
        # RESUME each trigger (PUT)
        # https://www.mongodb.com/docs/atlas/app-services/admin/api/v3/#tag/triggers/operation/adminResumeTrigger
        for triggerId in trigger_ids:
            url = f'https://services.cloud.mongodb.com/api/admin/v3.0/groups/{groupId}/apps/{appId}/triggers/{triggerId}/resume'
            
            # 'disable_token' default value: False
            response_PUT = requests.put(url, headers=headers)
            check_response_status(response_PUT, 204)
         
    
def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('-pubk', '--public-key', help='MongoDB Atlas public key', type=str)
    parser.add_argument('-privk', '--private-key', help='MongoDB Atlas private key', type=str)
    parser.add_argument('-pn', '--project-name', help='MongoDB Atlas project name', default='BDNoSQL-TP', type=str)
    
    args = parser.parse_args()      # Para obter um dicionário: args = vars(parser.parse_args())
    
    logging.basicConfig(format="[%(asctime)s] - %(levelname)s - line %(lineno)d, in '%(funcName)s' - %(message)s\n")
    
    access_token = get_access_token(args.public_key, args.private_key)
    
    groupId = get_groupId(args.public_key, args.private_key, args.project_name)
    appId = get_appId(access_token, groupId)
    
    trigger_names = [
        'id_patient_trigger',
        'id_episode_trigger',
        'emp_id_trigger',
        'medical_history_record_id_trigger',
        'bills_id_bill_trigger',
        'prescriptions_id_prescription_trigger',
        'lab_screenings_lab_id_trigger'
    ]
    
    resume_triggers(access_token, groupId, appId, trigger_names)
    

if __name__ == '__main__':
    main()
    