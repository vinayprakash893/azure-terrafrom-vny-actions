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
                result["TF_Organization_Name"] = data["TF_Organization_Name"]
                result["Infrakit_Template_Repo"] = data["Infrakit_Template_Repo"]
                if "Repository_Name" in result:
                    repository_name = result.get("Repository_Name")
                    del result["Repository_Name"]
                return result,repository_name
            else:
                print(f"Environment '{env}' not found in the JSON file.")
                return None, None
    except FileNotFoundError:
        print(f"The file '{file_name}' does not exist.")
        return None, None
    except json.JSONDecodeError:
        print(f"The file '{file_name}' is not a valid JSON file.")
        return None, None

def merge_with_input(input_file, new_data):
    try:
        with open(input_file, 'r') as file:
            existing_data = json.load(file)
    except FileNotFoundError:
        print(f"The file '{input_file}' does not exist. Creating a new one.")
        existing_data = {}
    
    infra_metadata = {
        "Infra_Metadata": new_data
    }
    # Merge new data into existing data
    existing_data.update(infra_metadata)
    
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
        print(f"Calling repo : {repository}")
        api_url = f'https://api.github.com/repos/vinayprakash893/{repository}/dispatches'
        print(f"Calling repo : {api_url}")
        sys.exit(1)
    print(f"Calling repo : {repository}")
    api_url = f'https://api.github.com/repos/vinayprakash893/{repository}/dispatches'
    headers = {
        'Accept': 'application/vnd.github+json',
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
        sys.exit(1)

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
    mapping_path = os.getenv('mapping_path', 'mapping')
    file_name = os.path.join(mapping_path, f"{file_prefix}_{region}_map.json")
    result, repository_name = read_json_map_file(file_name, environment)
    
    if result is not None:
        input_file = os.path.join(mapping_path, 'input-temp.json')
        merged_data = merge_with_input(input_file, result)
        print(f"Data merged successfully into {input_file}.")

        # Write merged data to merged.json
        merged_file = 'merged.json'
        write_to_merged_file(merged_file, merged_data)
        print(f"Merged data written to {merged_file}.")
        print("Content of merged.json:")
        with open(merged_file, 'r') as file:
            print(json.dumps(json.load(file), indent=2))
        # Trigger the GitHub Action with the merged data
        

        # Trigger the GitHub Action with the merged data
        trigger_github_action(repository_name, merged_file)
