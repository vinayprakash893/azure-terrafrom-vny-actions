import json
import sys
import requests
import os

def read_json_map_file(file_name, env):
    try:
        with open(file_name, 'r') as file:
            data = json.load(file)
            if env in data:
                result = data[env]
                result["Organization_Name"] = data["Organization_Name"]
                return result
            else:
                print(f"Environment '{env}' not found in the JSON file.")
                return None
    except FileNotFoundError:
        print(f"The file '{file_name}' does not exist.")
        return None
    except json.JSONDecodeError:
        print(f"The file '{file_name}' is not a valid JSON file.")
        return None

def merge_with_input(input_file, new_data):
    try:
        with open(input_file, 'r') as file:
            existing_data = json.load(file)
    except FileNotFoundError:
        print(f"The file '{input_file}' does not exist. Creating a new one.")
        existing_data = {}
    
    # Merge new data into existing data
    existing_data.update(new_data)
    
    with open(input_file, 'w') as file:
        json.dump(existing_data, file, indent=2)
    
    return existing_data

def write_to_merged_file(merged_file, merged_data):
    with open(merged_file, 'w') as file:
        json.dump(merged_data, file, indent=2)

def trigger_github_action(repository, merged_file):
    token = os.getenv('REPO_SCOPED_TOKEN')
    if token:
      print("Token retrieved successfully")
    else:
        print("Token not found")
    api_url = f'https://api.github.com/repos/vinayprakash893/{repository}/dispatches'
    headers = {
        'Accept': 'application/vnd.github.everest-preview+json',
        'Authorization': f'Bearer {token}',
    }
    with open(merged_file, 'r') as file:
        merged_data = json.load(file)
    
    data = {
        'event_type': 'self_service2',  # Customize this event type as needed
        'client_payload': {
            'workflow_data': merged_data
        },
    }
    response = requests.post(api_url, headers=headers, json=data)
    if response.status_code == 204:
        print(f"GitHub Repo '{repository}' triggered successfully.")
    else:
        print(f"Failed to trigger GitHub Repo. Status code: {response.status_code}")
        print(response.text)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python code.py <file_prefix> <region> <environment>")
        sys.exit(1)

    file_prefix = sys.argv[1]
    region = sys.argv[2]
    environment = sys.argv[3]

    # file_prefix =  os.getenv('jsontemp_Platform')
    # region =  os.getenv('jsontemp_Region')
    # environment =  os.getenv('jsontemp_Sub_Environment')
    mapping_path = os.getenv('mapping_path', 'infra_kit_api/mapping')
    file_name = os.path.join(mapping_path, f"{file_prefix}_{region}_map.json")
    result = read_json_map_file(file_name, environment)
    
    if result is not None:
        input_file = os.path.join(mapping_path, 'input-temp.json')
        merged_data = merge_with_input(input_file, result)
        print(f"Data merged successfully into {input_file}.")

        # Write merged data to merged.json
        merged_file = 'merged.json'
        write_to_merged_file(merged_file, merged_data)
        print(f"Merged data written to {merged_file}.")

        # Trigger the GitHub Action with the merged data
        trigger_github_action(result["Repository_Name"], merged_file)
