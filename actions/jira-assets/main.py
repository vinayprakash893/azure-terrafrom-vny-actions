from jira_client import JiraAssetsClient
import json
import logging
from datetime import datetime
import os
from typing import Dict, Any
from pydantic import BaseModel
import sys
import pandas as pd

# Initialize logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
    )
logger = logging.getLogger(__name__)

class AddObject(BaseModel):
    object_type_id: str
    issue: str

class UpdateObject(BaseModel):
    object_type_id: str
    issue: str
    object_id: str

class DeleteObject(BaseModel):
    object_type_id: str
    issue: str
    object_id: str

def create_object(addobject: AddObject):
    client = JiraAssetsClient()
    try:
        result = client.handle_create_object(addobject.object_type_id, addobject.issue)
        return {"status": "success", "result": result}
    except Exception as e:
        logger.error(f"Error creating object: {e}")
        return {"status": "error", "detail": str(e)}

def update_object(update_object: UpdateObject):
    client = JiraAssetsClient()
    try:
        result = client.handle_update_object(update_object.object_type_id, update_object.issue, update_object.object_id)
        return {"status": "success", "result": result}
    except Exception as e:
        logger.error(f"Error updating object: {e}")
        return {"status": "error", "detail": str(e)}


def delete_object(delete_object: DeleteObject):
    client = JiraAssetsClient()
    try:
        result = client.handle_delete_object(delete_object.object_type_id, delete_object.issue, delete_object.object_id)
        return {"status": "success", "result": result}
    except Exception as e:
        logger.error(f"Error updating object: {e}")
        return {"status": "error", "detail": str(e)}

def handle_action(action_request: Dict[str, Any]):
    action = action_request.get("action")
    data = action_request.get("data")

    if action == "create_object":
        addobject = AddObject(**data)
        return create_object(addobject)
    elif action == "update_object":
        updateobject = UpdateObject(**data)
        return update_object(updateobject)
    elif action == "delete_object":
        deleteobject = DeleteObject(**data)
        return delete_object(deleteobject)
    else:
        logger.error("Invalid action")
        return {"status": "error", "detail": "Invalid action"}





def run_objects_data(asset_type_id, start_at=0, max_results=50, attribute_details=None,debug=False):
 
    query = f'objectTypeId = {asset_type_id}'
 
    logging.info(f"Executing query: {query}")
    logging.info(f"Starting asset retrieval (this might take a while for large datasets)...")
   
    client = JiraAssetsClient()
    results = client.extract_objects_data(query, start_at, max_results, attribute_details)
   
    # Log the results
    logging.info("Query completed!")
    logging.info(f"Final results - Total assets retrieved: {len(results)}")
    logging.info(json.dumps(results, indent=2))
   
    # Print summary
    if  results:        
        summary = f"\nTotal results found: {len(results)}"
        logging.info(summary)
        df = pd.DataFrame(results)
 
        # Convert DataFrame to CSV
        csv_filename = f"{asset_type_id}.csv"
        df.to_csv(csv_filename, index=False)
        print(f"CSV file '{csv_filename}' created.")
    else:
        logging.info("empty results")




def get_asset_schema_details (schema_name: str, debug: bool = False):
    """Get asset schemas details """
    
    logging.info("Retrieving asset schemas details")
    
    client = JiraAssetsClient()
    schemas = client.get_objecttype_attributes(schema_name)
    
    if schemas:
        logging.info("Asset schemas retrieved:")
        logging.info(json.dumps(schemas, indent=2))
        return schemas
    else:
        logging.error("No asset schemas found")
        return None


    

def main():
    print(f"Processing")
    # asset_schema_detail = get_asset_schema_details("CIE_DNS")
    # for asset_type, asset_details in asset_schema_detail.items():
    #     print(f"Asset Type: {asset_type}")
    #     print(f"Asset Details: {asset_details}")
    #     query = f'objectTypeId = {asset_type}'
    #     start = ""
    #     limit = 2000

    #     results = run_objects_data(query, start, limit, asset_details)

    #     if results:
    #         # Convert JSON to DataFrame
    #         df = pd.DataFrame(results)
    
    #         # Convert DataFrame to CSV
    #         csv_filename = f"{asset_details['name']}.csv"
    #         df.to_csv(csv_filename, index=False)
    #         print(f"CSV file '{csv_filename}' created.")

def load_from_env(environ):
    return {'env': environ}

def workspace_create(variables):
    print("Workspace created with:", variables)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python main.py <input_json>")
        # python main.py '123456789BCC41F' '{"action": "create_object", "data": {"object_type_id": "41", "issue": "CIEO-105"}}'
        # python main.py 'token ' 'payload'
        sys.exit(1)
    variables = load_from_env(os.environ)
    workspace_create(variables)

    input_json = sys.argv[1]
    try:
        action_request = json.loads(input_json)
        result = handle_action(action_request)
        print(json.dumps(result, indent=2))
        data = action_request.get("data")
        object_type_id = data.get("object_type_id")
        asset_details = get_asset_schema_details(object_type_id)
        print(f"Asset Details: {asset_details}")
        start = ""
        limit = 2000
        run_objects_data(object_type_id, start, limit, asset_details)

    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON input: {e}")
        sys.exit(1)

