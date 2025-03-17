import requests
from config import Config
import logging
from typing import Dict, Any
from jira_api import JiraAPI
import concurrent.futures
from queue import Queue
import threading
from collections import deque
from time import sleep



class JiraAssetsClient:
    def __init__(self):
        self.api = JiraAPI()
        self.log_queue = Queue()
        self.log_buffer = deque(maxlen=100)  # Buffer for batch logging
        self._setup_logging_thread()

    def _setup_logging_thread(self):
        """Setup background thread for batch logging"""
        def log_worker():
            while True:
                try:
                    messages = []
                    # Wait for first message
                    messages.append(self.log_queue.get())
                    
                    # Collect any other pending messages
                    while not self.log_queue.empty() and len(messages) < 100:
                        messages.append(self.log_queue.get())
                    
                    # Log messages in batch
                    for msg in messages:
                        logging.info(msg)
                    
                    sleep(0.1)  # Small delay to prevent CPU overuse
                except Exception as e:
                    logging.error(f"Error in logging thread: {e}")

        thread = threading.Thread(target=log_worker, daemon=True)
        thread.start()

    def _batch_log(self, message: str):
        """Add message to logging queue"""
        self.log_queue.put(message)

    def _get_common_key_values(self, dict1, dict2):
        common_values = {}
        for key, value in dict1.items():
            if key.lower() in dict2:
                common_values[dict2[key.lower()]] = value
        return common_values

    def _prepare_attribute_update(self, attribute_id: str, value: str) -> Dict:
        """Prepare attribute update structure"""
        return {
            "objectTypeAttributeId": attribute_id,
            "objectAttributeValues": [{"value": value}]
        }

    
    def get_all_objecttypes_details(self, object_schema_name: str) -> Dict[str, Any]:

        """Get all object types for the given object schema"""
        object_schemas = self.api.get_all_object_schemas ()
        object_schema_id= [value.get('id') for value in object_schemas.get('values') if value.get('name') == object_schema_name][0]

        objecttypes = self.api.get_object_types(object_schema_id)
        objecttypes_map = {value.get('id'): value.get('name') for value in objecttypes}
        objecttypes_details = {}
        # Iterate over object types and retrieve their details
        for object_type_id, object_type_name in objecttypes_map.items():
            objecttypes_details[object_type_id] = {"name": object_type_name}
            objecttype_attributes = self.api.get_object_type_attributes(object_type_id)
            objecttypes_details[object_type_id]["attributes"] = {attribute.get('id'): attribute.get('name') for attribute in objecttype_attributes}

        return objecttypes_details

    def _get_objecttype_attributes(self, object_types_id: id) -> Dict[str, Any]:
        """Get all attributes for the given object types """
        objecttype_attributes_data = self.api.get_object_type_attributes(object_types_id)
        objecttype_attributes= {attribute.get('name'): attribute.get('id') for attribute in objecttype_attributes_data}

        return objecttype_attributes
    
    def get_objecttype_attributes(self, object_types_id: id) -> Dict[str, Any]:
        """Get all attributes for the given object types """
        objecttype_attributes = {}
        objecttype_attributes_data = self.api.get_object_type_attributes(object_types_id)
        objecttype_attributes["attributes"]= {attribute.get('id'): attribute.get('name') for attribute in objecttype_attributes_data}

        return objecttype_attributes

    def _get_object_attributes(self, object_id: str) -> Dict[str, Any]:
        """Get attributes of an object by its ID"""
        object_attributes = self.api.get_object_attributes(object_id)
        objecttype_attributes= {attribute.get('name'): attribute.get('id') for attribute in objecttype_attributes_data}
        return object_attributes

    def _get_object_id_by_name_search(self, object_type_id: str, object_name: str, object_value: str) -> str:
        """Get object ID by name search"""
        aql_query = f"objectTypeId = '{object_type_id}'  AND '{object_name}' = '{object_value}'"

        objects = self.api.search_objects(aql_query)
        if objects and 'values' in objects:
            return objects['values'][0]['id']
        return None


    def search_assets_by_aql(self, aql_query, start_at=0, max_results=50, include_attributes=True):
        """Search assets using AQL (Asset Query Language) and handle pagination"""
        all_values = []
        current_start = start_at
        
        while True:
            result = self.api.search_objects(aql_query, current_start, max_results, include_attributes)
            
            # Add values from current page to our collection
            if 'values' in result:
                all_values.extend(result['values'])
                logging.info(f"Retrieved {len(result['values'])} assets. Total so far: {len(all_values)}")
            
            # Check if we've got all results
            if not result.get('values') or len(result['values']) < max_results:
                break
                
            current_start += max_results
        
        return {
            'startAt': start_at,
            'maxResults': max_results,
            'total': len(all_values),
            'values': all_values
        }



    def extract_objects_data(self, aql_query, start_at=0, max_results=50, attribute_details=None, include_attributes=True):
        """Extract data from assets using AQL search"""
        results = self.search_assets_by_aql(aql_query, start_at, max_results, include_attributes)
        
        if 'values' in results:
            extracted_data = []
            logging.info(f"Query completed! Total assets retrieved: {len(results['values'])}")
            for asset_schema in results['values']:
                asset_data = {}
                for attribute in asset_schema.get('attributes', []):
                    object_type_attribute_id = attribute.get('objectTypeAttributeId')
                    
                    if object_type_attribute_id in attribute_details['attributes']:
                        attribute_name = attribute_details['attributes'][object_type_attribute_id]
                        attribute_value = attribute.get('objectAttributeValues', [{}])[0].get('value', '')
                        asset_data[attribute_name] = attribute_value
                extracted_data.append(asset_data)

            return extracted_data
            
        logging.error("No results found")
        return []

        
    def _extract_forms_data(self, issue_key: str):
        """Extract forms data from Jira issue"""
        forms_data = self.api.get_jira_issue_forms_data(issue_key)
        questions = forms_data['value']['design']['questions']
        answers = forms_data['value']['state']['answers']
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

    def handle_create_object(self, object_type_id: str, issue: str) -> Dict[str, Any]:
        """Handle the creation of a new asset with the given object type and attributes"""
        # Extract form data from the Jira issue
        issue_data = self._extract_forms_data(issue)
        
        if not issue_data:
            logging.error("No form data extracted from Jira issue")
            return None

        logging.info(f"Extracted form data: {issue_data}")
        
        object_type_attributes = self._get_objecttype_attributes(object_type_id)

        logging.info(f"Object type attributes: {object_type_attributes}")

        common_attributes = self._get_common_key_values(issue_data, object_type_attributes)

        logging.info(f"Common attributes: {common_attributes}")

        if not common_attributes:
            logging.error("No common attributes found for asset creation")
            return None

        object_data =[]

        for key, value in common_attributes.items():
            data = self._prepare_attribute_update(key, value)
            object_data.append(data)
       
        logging.info(f"Creating asset with attributes: {object_data}")

        created_asset = self.api.create_object(object_type_id, object_data)
        
        if not created_asset:
            logging.error("Failed to create asset")
            return None
        
        logging.info(f"Created asset with ID: {created_asset['id']}")
        return created_asset

    def handle_update_object(self, object_type_id: str, issue: str, object_id: str) -> Dict[str, Any]:
        """Handle the update of an existing asset with the given object ID and Issue """
        issue_data = self._extract_forms_data(issue)
        
        if not issue_data:
            logging.error("No form data extracted from Jira issue")
            return None

        logging.info(f"Extracted form data: {issue_data}")
        
        object_type_attributes = self._get_objecttype_attributes(object_type_id)

        logging.info(f"Object type attributes: {object_type_attributes}")

        common_attributes = self._get_common_key_values(issue_data, object_type_attributes)

        logging.info(f"Common attributes: {common_attributes}")

        if not common_attributes:
            logging.error("No common attributes found for asset creation")
            return None

        object_data =[]

        for key, value in common_attributes.items():
            data = self._prepare_attribute_update(key, value)
            object_data.append(data)
       
        logging.info(f"Creating asset with attributes: {object_data}")

        update_object = self.api.update_object(object_type_id, object_data, object_id)
        
        if not update_object:
            logging.error("Failed to update asset")
            return None
        
        logging.info(f"updated asset with ID: {update_object['id']}")
        return update_object


    def handle_delete_object(self, object_type_id: str, issue: str, object_id: str) -> bool:

        # Perform the deletion
        deleted = self.api.delete_object(object_id)
        if deleted:
            logging.info(f"Deleted asset with ID: {object_id}")
            return True
        else:
            logging.error(f"Deletion failed for asset {object_id}")
            return False