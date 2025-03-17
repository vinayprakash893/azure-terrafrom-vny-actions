import requests
import logging
from typing import Dict, Any, List, Optional
from config import Config
from time import time, sleep
import json
from datetime import datetime
import random

class RateLimitError(Exception):
    """Custom exception for rate limiting"""
    def __init__(self, retry_after: int, reset_time: Optional[str] = None):
        self.retry_after = retry_after
        self.reset_time = reset_time
        super().__init__(f"Rate limit exceeded. Retry after {retry_after} seconds")

class JiraAPI:
    def __init__(self):
        self.base_url = Config.JIRA_URL
        self.auth = (Config.JIRA_USER, Config.JIRA_API_TOKEN)
        self.headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        }
        self.max_retries = 5
        self.initial_delay = 1  # Start with 1 second delay
        self.max_delay = 32  # Maximum delay in seconds

    def _handle_rate_limit(self, response: requests.Response) -> int:
        """Handle rate limit response and return retry delay"""
        retry_after = int(response.headers.get('Retry-After', self.initial_delay))
        reset_time = response.headers.get('X-RateLimit-Reset')
        
        if reset_time:
            logging.warning(f"Rate limit will reset at: {reset_time}")
        
        raise RateLimitError(retry_after, reset_time)

    def _make_request(self, method: str, url: str, **kwargs) -> requests.Response:
        """Make HTTP request with rate limit handling and exponential backoff"""
        current_retry = 0
        current_delay = self.initial_delay
        
        while current_retry <= self.max_retries:
            try:
                response = requests.request(method, url, **kwargs)
                
                # Check for rate limit
                if response.status_code == 429:
                    retry_delay = self._handle_rate_limit(response)
                    current_delay = min(retry_delay, self.max_delay)
                elif response.status_code >= 500:
                    # Handle server errors with backoff
                    if 'Retry-After' in response.headers:
                        current_delay = int(response.headers['Retry-After'])
                    else:
                        current_delay = min(current_delay * 2, self.max_delay)
                else:
                    # Check if we're approaching the rate limit
                    if response.headers.get('X-RateLimit-NearLimit') == 'true':
                        logging.warning("Approaching rate limit, adding delay to subsequent requests")
                        sleep(1)  # Add small delay to help avoid hitting limit
                    return response
                
                # Add jitter to avoid thundering herd
                jitter = random.uniform(0, 0.1) * current_delay
                sleep_time = current_delay + jitter
                
                logging.warning(f"Request failed, retrying in {sleep_time:.2f} seconds (attempt {current_retry + 1}/{self.max_retries})")
                sleep(sleep_time)
                
                current_retry += 1
                
            except RateLimitError as e:
                if current_retry >= self.max_retries:
                    raise
                sleep(e.retry_after)
                current_retry += 1
            except Exception as e:
                logging.error(f"Request failed: {str(e)}")
                raise

        raise Exception(f"Max retries ({self.max_retries}) exceeded")

    def get_object(self, object_id: str) -> Dict[str, Any]:
        """Get object with rate limit handling"""
        try:
            url = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/object/{object_id}"
            response = self._make_request('get', url, headers=self.headers, auth=self.auth)
            
            if response.status_code == 404:
                return None
                
            result = response.json()
            
            if not result.get('objectType', {}).get('id'):
                logging.error(f"API response missing object type for asset {object_id}. Response: {result}")
                return None
                
            return result
            
        except Exception as e:
            logging.error(f"Error retrieving asset {object_id}: {str(e)}")
            return None

    def search_objects(self, aql_query: str, start_at: int = 0, max_results: int = 50, include_attributes: bool = True) -> Dict:
        """Execute AQL search request"""
        endpoint = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/object/aql"
        
        params = {
            'startAt': start_at,
            'maxResults': max_results,
            'includeAttributes': str(include_attributes).lower()
        }
        
        payload = {
            "qlQuery": aql_query
        }
        
        response = self._make_request(
            'post',
            endpoint,
            params=params,
            json=payload,
            headers=self.headers,
            auth=self.auth
        )
        return response.json()

    def update_object(self,  object_type_id: str, attributes: List[Dict], object_id: str) -> Dict[str, Any]:
        """Update object attributes with rate limit handling"""
        endpoint = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/object/{object_id}"
        
        payload = {
            "attributes": attributes,
            "objectTypeId": object_type_id,
            "avatarUUID": "",
            "hasAvatar": False
        }
        
        logging.debug(f"Making PUT request to {endpoint}")
        logging.debug(f"Update payload: {json.dumps(payload, indent=2)}")
        
        try:
            response = self._make_request(
                'put',
                endpoint,
                json=payload,
                headers=self.headers,
                auth=self.auth
            )
            
            logging.debug(f"API Response status: {response.status_code}")
            logging.debug(f"API Response headers: {dict(response.headers)}")
            
            if response.status_code not in [200, 201]:
                logging.error(f"Failed to update asset {object_id}: {response.text}")
                return None
            
            logging.info(f"Successfully updated asset {object_id}")
            return response.json()
            
        except Exception as e:
            logging.error(f"Exception during API update: {str(e)}")
            return None

    def get_all_object_schemas (self) -> Dict[str, Any]:
        """Get all Jira asset schemas"""
        try:
            url = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/objectschema/list"
            response = self._make_request('get', url, headers=self.headers, auth=self.auth)
            
            if response.status_code == 404:
                return None
                
            result = response.json()

            if not result.get('values'):
                logging.error("API response missing asset values")
                return None
                
            return result
            
        except Exception as e:
            logging.error(f"Error retrieving asset schemas: {str(e)}")
            return None
            
    def get_object_types(self, schema_id: str) -> List[Dict[str, Any]]:
        """Get all object types for a given object schema"""
        try:
            url = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/objectschema/{schema_id}/objecttypes"
            response = self._make_request('get', url, headers=self.headers, auth=self.auth)
            
            if response.status_code == 404:
                return None
               
            result = response.json()
            
            if not result:
                logging.error("API response missing object types")
                return None
                
            return result
            
        except Exception as e:
            logging.error(f"Error retrieving object types: {str(e)}")
            return None

    def get_object_type_attributes(self, objecttype_id: str) -> Dict[str, Any]:
        """Get all object type attributes for a given object schema"""
        try:
            url = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/objecttype/{objecttype_id}/attributes"
            response = self._make_request('get', url, headers=self.headers, auth=self.auth)
            
            if response.status_code == 404:
                return None
                
            result = response.json()
            
            if not result:
                logging.error("API response missing object attributes")
                return None
                
            return result
            
        except Exception as e:
            logging.error(f"Error retrieving object type attributes: {str(e)}")
            return None
    

    def get_jira_issue_forms_data(self, issue):
        """Get Jira issue forms data"""        
        try:
            url = f'https://{self.base_url}/rest/api/2/issue/{issue}/properties/proforma.forms.i1'
            response = self._make_request('get', url, headers=self.headers, auth=self.auth)
            if response.status_code == 404:
                return None
                
            result = response.json()
            
            if not result:
                logging.error("API response missing issue forms data")
                return None
                
            return result
            
        except Exception as e:
            logging.error(f"Error retrieving object type attributes: {str(e)}")
            return None

    def create_object(self, object_type_id: str, attributes: List[Dict]) -> Dict[str, Any]:
        """Create a new object with the given object type and attributes"""
        endpoint = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/object/create"
        
        payload = {
            "attributes": attributes,
            "objectTypeId": object_type_id,
            "avatarUUID": "",
            "hasAvatar": False
        }
        
        logging.debug(f"Making POST request to {endpoint}")
        logging.debug(f"Create payload: {json.dumps(payload, indent=2)}")
        
        try:
            response = self._make_request(
                'post',
                endpoint,
                json=payload,
                headers=self.headers,
                auth=self.auth
            )
            
            logging.debug(f"API Response status: {response.status_code}")
            logging.debug(f"API Response headers: {dict(response.headers)}")
            
            if response.status_code not in [200, 201]:
                logging.error(f"Failed to create object: {response.text}")
                return None
            
            logging.info(f"Successfully created object")
            return response.json()
            
        except Exception as e:
            logging.error(f"Exception during object creation: {str(e)}")
            return None

    def delete_object(self, object_id: str) -> bool:
        """Delete the referenced object"""
        try:
            url = f"https://api.atlassian.com/jsm/assets/workspace/{Config.WORKSPACE_ID}/v1/object/{object_id}"
            response = self._make_request('delete', url, headers=self.headers, auth=self.auth)
            
            if response.status_code == 200:
                logging.info(f"Successfully deleted object {object_id}")
                return True
            
            logging.error(f"Failed to delete object {object_id}: {response.text}")
            return False
            
        except Exception as e:
            logging.error(f"Exception during object deletion: {str(e)}")
            return False