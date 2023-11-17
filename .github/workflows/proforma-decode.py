import requests
import sys
from automationassets import *

def get_jira_data(raw_data):
    corrected_string = raw_data.replace("{", "{'").replace(":", "':'").replace(",", "','").replace("}", "'}").replace("'{'","{'").replace("'}'","'}")
    webhook_data = eval(corrected_string)
    print(webhook_data)
    issue = str(webhook_data["RequestBody"])
    jira_server = get_automation_variable("JIRA_SERVER")
    jira_url = 'https://{}/rest/api/3/issue/{}/properties/proforma.forms.i1'.format(jira_server, issue)
    username = get_automation_variable("USERNAME")
    api_token = get_automation_variable("JIRA_API_KEY")
    session = requests.Session()
    session.auth = (username, api_token)

    try:
        # Make a GET request to the Jira API
        response_call = session.get(jira_url)
        response_call.raise_for_status()  # Raise an error for bad status codes

        # Check if the request was successful
        if response_call.status_code == 200:
            # Print the response content (JSON)
            data = response_call.json()
            questions = data['value']['design']['questions']
            answers = data['value']['state']['answers']

            response_values = {'key': issue}
            for answer_key, response in answers.items():
                if answer_key in questions:
                    name = questions[answer_key]['label']
                    if response['text']:
                        response_values[name] = response['text']
                    elif response['choices']:
                        selected = response['choices'][0]
                        for choice in questions[answer_key]['choices']:
                            if selected == choice['id']:
                                response_values[name] = choice['label']
                                break

            return response_values

    except requests.exceptions.HTTPError as err:
        print(err)
        return None

def trigger_github_action(repository, workflow_data):
    token = get_automation_variable("GITHUB_API_KEY")
    api_url = f'https://api.github.com/repos/vinayprakash893/{repository}/dispatches'
    headers = {
        'Accept': 'application/vnd.github.everest-preview+json',
        'Authorization': f'Bearer {token}',
    }
    data = {
        'event_type': 'json-decode',  # Customize this event type as needed
        'client_payload': {
            'workflow_data':workflow_data,
            'key':workflow_data['location']
        } ,
    }

    response = requests.post(api_url, headers=headers, json=data)

    if response.status_code == 204:
        print(f"GitHub Action '{repository}' triggered successfully.")
    else:
        print(f"Failed to trigger GitHub Action. Status code: {response.status_code}")
        print(response.text)


def replace_values(original_dict, replacement_dict):
    result_dict = original_dict.copy()  # Create a copy to avoid modifying the original dictionary

    for key,value in original_dict.items():
        if value in replacement_dict:
            new_key = f'jinja_{key}'
            result_dict[new_key] = replacement_dict[value]

    return result_dict

rawdata = sys.argv[1]
result = get_jira_data(rawdata)
jinja_dict={'United States':'eastus2','Canada':'canadacentral','Infrastructure Engineering Sandbox':'app99', 'Development':'app01'}


if result:
    
    print(f"RAW Data: {result}")
    jinja_result = replace_values(result, jinja_dict)
    print(f"Jira Pay Load : {jinja_result}")
    #sub=result['Subscription']
    #repository_name = f'cie-camelot-{sub}-infra-onboarding'
    repository_name = f'azure-tf-self-service'
    #workflow_data = jinja_result
    workflow_data = result

    trigger_github_action(repository_name, workflow_data)

else:
    print("Failed to retrieve Jira data.")



#####SIMPLE###################
# import requests 
# import json 

# issue = 'ISM1-25' 
# jira_server='vinaycloudtech.atlassian.net' 
# jira_url = 'https://{}/rest/api/3/issue/{}/properties/proforma.forms.i1'.format(jira_server,issue) 
# username = 'vinaycloudtech@gmail.com' 
# api_token = 'ATATT3xFfGF0p-IH8DHj88Lr2UvOVto2KuL8bJiPLRn4DOImJidrHGwzSpwrYmltdvebM8bNgqN7Muxz1GJx0EFgNdC7r_80oEWycGiNjDw66-IOfxZS9IzWWoTb2UXZwRWa1ybj-9J1uxCwgbt7fBb2ZXdagQhyraYlyFcJp8ExedwkcQAq2yg=C7E3BE1A'  # Use your Jira API token 

# session = requests.Session() 
# session.auth = (username, api_token) 

# try: 
#     response_call = session.get(jira_url) 
#     response_call.raise_for_status()  # Raise an error for bad status codes 

#     if response_call.status_code == 200: 
#         data = response_call.json() 
#         questions = data['value']['design']['questions'] 
#         answers = data['value']['state']['answers'] 
#         response_values = {} 
#         for answer_key, response in answers.items(): 
#             if answer_key in questions: 
#                 name = questions[answer_key]['label'] 
#                 if response['text']: 
#                     response_values[name] = response['text'] 
#                 elif response['choices']: 
#                     selected=response['choices'][0] 
#                     for choice in questions[answer_key]['choices']: 
#                         if selected == choice['id']: 
#                             response_values[name] = choice['label'] 
#                             break 
#     print(response_values)
#     with open('input-data.json', 'w') as json_file:
#         json.dump(response_values, json_file)

# except requests.exceptions.HTTPError as err: 
#     print(err)