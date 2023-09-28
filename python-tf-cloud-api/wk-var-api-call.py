import requests
import json

# Configure your Terraform Cloud API Token and Workspace details
api_token = "xaatefhNYa6HJA.atlasv1.CgjrOKOj6DFeq3qIZmTjUJrh0u8scaBYkwccOwhAQoQ9g5Ym24dhKE1RxMZHFIEcRVg"
organization_name = "Cloudtech"
workspace_name = "cloud_user_p_99650270"

# Define the new variables you want to set or update
new_variables = {
    "variable_name_1": "variable_value_1",
    "variable_name_2": "variable_value_2"
}

# Base URL for the Terraform Cloud API
base_url = f"https://app.terraform.io/api/v2/organizations/{organization_name}/workspaces/{workspace_name}"

# Headers for API request
headers = {
    "Authorization": f"Bearer {api_token}",
    "Content-Type": "application/vnd.api+json"
}

# Get the current workspace configuration
response = requests.get(f"{base_url}/current-configuration", headers=headers)

if response.status_code == 200:
    current_configuration = response.json()

    # Update the existing variables or add new ones
    current_configuration["data"]["attributes"]["terraform-version"] += 1
    current_configuration["data"]["attributes"]["variables"].update(new_variables)

    # Send a PUT request to update the workspace configuration
    response = requests.put(f"{base_url}/current-configuration", headers=headers, data=json.dumps(current_configuration))
    
    if response.status_code == 200:
        print(f"Workspace variables updated successfully.")
    else:
        print(f"Failed to update workspace variables. Status Code: {response.status_code}, Response: {response.text}")
else:
    print(f"Failed to fetch current workspace configuration. Status Code: {response.status_code}, Response: {response.text}")
