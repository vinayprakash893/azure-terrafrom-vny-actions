from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
from typing import Dict, Any
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class JiraRequest(BaseModel):
    issue: str

class JiraResponse(BaseModel):
    data: Dict[str, Any]

jira_server = 'vinaycloudtech-1734068642544.atlassian.net'
username = 'vinaycloudtech@gmail.com'
api_token = 'ATATT3xFfGF06zkjUHA_VOV5sgpYl4Rj59gr8f97b6gZE_ApsSOQZRasAzJiLIjULwSyTsrHV1GTNvxU0P8nOoN_Va3tAdkczv__5QbNsuVqFb9DP3_D8xnKrcl8zkedO5nUN_CiWi7XefSb8GJCr_9euZyrSf-KJ2ethzptzGksHRyZi7utTO4=EA3A3298'

def get_jira_data(issue):
    jira_url = f'https://{jira_server}/rest/api/2/issue/{issue}/properties/proforma.forms.i1'
    session = requests.Session()
    session.auth = (username, api_token)

    try:
        logger.info(f"Making request to Jira API: {jira_url}")
        response_call = session.get(jira_url)
        response_call.raise_for_status()
        if response_call.status_code == 200:
            data = response_call.json()
            questions = data['value']['design']['questions']
            answers = data['value']['state']['answers']
            #response_values = {'key': issue} # will be listed under the main { }
            response_values = {}
            
            for answer_key, response in answers.items():
                if answer_key in questions:
                    name = questions[answer_key]['label']
                    if 'text' in response and response['text']:
                        response_values[name] = response['text']
                    elif 'choices' in response and response['choices']:
                        selected = response['choices'][0]
                        for choice in questions[answer_key]['choices']:
                            if selected == choice['id']:
                                response_values[name] = choice['label']
                                break
                    elif 'date' in response:
                        response_values[name] = response['date']
            return response_values
    except requests.exceptions.HTTPError as err:
        if err.response.status_code == 404:
            logger.error(f"Issue {issue} not found: {err}")
        else:
            logger.error(f"HTTP error occurred: {err}")
        return None
    except Exception as err:
        logger.error(f"An error occurred: {err}")
        return None

@app.post("/decode-jira", response_model=JiraResponse)
def decode_jira(request: JiraRequest):
    logger.info(f"Received request to decode Jira data for issue: {request.issue}")
    result = get_jira_data(request.issue)
    if result:
        logger.info("Successfully retrieved and processed Jira data")
        #return JiraResponse(key=request.issue, data=result)
        return JiraResponse(data=result)
    else:
        logger.error("Failed to retrieve Jira data")
        raise HTTPException(status_code=500, detail="Failed to retrieve Jira data")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=9000)