import requests 

import json 

issue = 'ddd-21' 

jira_server='sass.atlassian.net' 

# Jira API endpoint URL 

jira_url = 'https://{}/rest/api/3/issue/{}/properties/proforma.forms.i1'.format(jira_server,issue) 


# Replace 'your-jira-instance' with your Jira instance and 'ISSUE-123' with your desired issue ID 


# Jira API request credentials 

username = 'vinay@email.com' 

api_token = 'code'  # Use your Jira API token 


# Create a session and set the auth credentials 

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

        response_values = {} 

        for answer_key, response in answers.items(): 

            if answer_key in questions: 

                name = questions[answer_key]['label'] 

                if response['text']: 

                    response_values[name] = response['text'] 

                elif response['choices']: 

                    selected=response['choices'][0] 

                    for choice in questions[answer_key]['choices']: 

                        if selected == choice['id']: 

                            response_values[name] = choice['label'] 

                            break 


    print(response_values) 



except requests.exceptions.HTTPError as err: 

    print(err) 

