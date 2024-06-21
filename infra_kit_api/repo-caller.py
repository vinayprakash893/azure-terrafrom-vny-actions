import requests
import sys
#from automationassets import *

issue = 'ISM1-25' 
jira_server='vinaycloudtech.atlassian.net' 
jira_url = 'https://{}/rest/api/3/issue/{}/properties/proforma.forms.i1'.format(jira_server,issue) 
username = 'vinaycloudtech@gmail.com' 
api_token = 'ATATT3xFfGF0p-IH8DHj88Lr2UvOVto2KuL8bJiPLRn4DOImJidrHGwzSpwrYmltdvebM8bNgqN7Muxz1GJx0EFgNdC7r_80oEWycGiNjDw66-IOfxZS9IzWWoTb2UXZwRWa1ybj-9J1uxCwgbt7fBb2ZXdagQhyraYlyFcJp8ExedwkcQAq2yg=C7E3BE1A'  # Use your Jira API token 

def get_jira_data(raw_data):
    # Correct the format by enclosing keys and values in double quotes
    corrected_string = raw_data.replace("{", "{'").replace(":", "':'").replace(",", "','").replace("}", "'}").replace("'{'","{'").replace("'}'","'}")

    # Convert the corrected string to a Python dictionary
    webhook_data = eval(corrected_string)
    print(webhook_data)
    #issue = str(webhook_data["RequestBody"])
    # jira_server = 'ceridian.atlassian.net'
    #jira_server = get_automation_variable("JIRA_SERVER")

    # Jira API endpoint URL
    jira_url = 'https://{}/rest/api/latest/issue/{}/properties/proforma.forms.i1'.format(jira_server, issue)

    # Jira API request credentials
    #username = get_automation_variable("USERNAME")
    #api_token = get_automation_variable("JIRA_API_KEY")

    # Create a session and set the auth credentials
    session = requests.Session()
    session.auth = (username, api_token)

    try:
        # Make a GET request to the Jira API
        response_call = session.get(jira_url)
        response_call.raise_for_status()  # Raise an error for bad status codes
        print("connecting to Jira:", response_call.status_code)
        # Check if the request was successful
        if response_call.status_code == 200:
            # Print the response content (JSON)
            data = response_call.json()
            questions = data['value']['design']['questions']
            answers = data['value']['state']['answers']

            response_values = {'key': issue}
            
            for answer_key, response in answers.items():
                print(f"Processing answer key: {answer_key}")
                if answer_key in questions:
                    name = questions[answer_key]['label']
                    print(f"   Extracted name: {name}")

                    if 'text' in response and response['text']:
                        response_values[name] = response['text']
                        print(f"   Set response value for {name}: {response['text']}")
                    elif 'choices' in response and response['choices']:
                        selected = response['choices'][0]
                        print(f"   Selected choice ID: {selected}")

                        for choice in questions[answer_key]['choices']:
                            if selected == choice['id']:
                                response_values[name] = choice['label']
                                print(f"   Set response value for {name}: {choice['label']}")
                                break
                    elif 'date' in response:
                        response_values[name] = response['date']
                        print(f"   Set response value for {name}: {response['date']}")
                    else:
                        print(f"   No valid response found for {name}")

            return response_values

    


    except requests.exceptions.HTTPError as err:
        print(err)
        return None

def trigger_github_action(repository, workflow_data):
    token = get_automation_variable("GITHUB_API_KEY")
    api_url = f'https://api.github.com/repos/DayforceCloud/{repository}/dispatches'
    headers = {
        'Accept': 'application/vnd.github.everest-preview+json',
        'Authorization': f'Bearer {token}',
    }
    data = {
        'event_type': 'self_service',  # Customize this event type as needed
        'client_payload': {
            'workflow_data':workflow_data,
            'key':workflow_data['key'],
            'Subscription':workflow_data['Subscription'],
            'jinja_Region':workflow_data['jinja_Region'],
            'jinja_Sub_Environment_Name':workflow_data['jinja_Sub_Environment_Name'],
            'Application_Short_Name':workflow_data['Application_Short_Name'],
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

def remove_space(original_dict):
    result_dict = {}

    for key,value in original_dict.items():
        key_string = key.replace(" ", "_")
        result_dict[key_string] = value

    return result_dict

def get_subname(mapRegion, mapEnvironment):
    region_mapping = {
        'United States': {'Non Production':'app551', 'Pre Production':'app351', 'Production': 'app151'},
        'Canada': {'Non Production':'app552', 'Pre Production':'app352', 'Production': 'app152'},
        'EMEA': {'Non Production':'app553', 'Pre Production':'app353', 'Production': 'app153'},
        'Australia': {'Non Production':'app555', 'Pre Production':'app355', 'Production': 'app155'},
    }
    subname = region_mapping.get(mapRegion, {}).get(mapEnvironment)
    return subname

rawdata = sys.argv[1]
result = get_jira_data(rawdata)
jinja_dict={'Prod':'app01','Config':'app01','Infrastructure Engineering Sandbox':'app99', 'Development':'app01','United States':'eastus2','Canada':'canadacentral','EMEA':'westeurope','Australia':'australiaeast'}

if result:
    
    print(f"RAW Data: {result}")
    result_dict = remove_space(result)
    jinja_result = replace_values(result_dict, jinja_dict)
    mapRegion = jinja_result.get('Region', '')
    mapEnvironment = jinja_result.get('Environment', '')
    subname = get_subname(mapRegion, mapEnvironment)
    jinja_result['Subscription'] = subname
    print(f"Jira Pay Load : {jinja_result}")
    repository_name = 'jira-camelot-sandbox-infra-onboarding'
    workflow_data = jinja_result
    trigger_github_action(repository_name, workflow_data)
    print("Calling Workflow")

else:
    print("Failed to retrieve Jira data.")
