from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict, Any
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class JiraRequest(BaseModel):
    key: str
    value: Dict[str, Any]

class JiraResponse(BaseModel):
    data: Dict[str, Any]

def process_jira_data(value):
    questions = value['design']['questions']
    answers = value['state']['answers']
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

@app.post("/decode-jira", response_model=JiraResponse)
def decode_jira(request: JiraRequest):
    logger.info("Received request to decode Jira data")
    result = process_jira_data(request.value)
    if result:
        logger.info("Successfully processed Jira data")
        return JiraResponse(data=result)
    else:
        logger.error("Failed to process Jira data")
        raise HTTPException(status_code=500, detail="Failed to process Jira data")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)