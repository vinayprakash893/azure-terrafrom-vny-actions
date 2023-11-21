# Reusable GitHub Actions Workflow Framework
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

This repository provides a reusable framework for creating GitHub Actions workflows using YAML. This framework is designed to simplify the setup of common workflows, making it easier to automate your development and deployment processes.

## How to Use

To use this reusable framework for your GitHub workflow, follow these steps:

1. **Create a YAML file for your workflow**: Start by creating a YAML file in your repository's `.github/workflows` directory. You can give the file any name you like, such as `my-custom-workflow.yml`.

2. **Copy the framework code**: Copy the content from the framework YAML file provided in this repository. You can customize it to fit your specific workflow requirements. refer below sample code as needed.

3. **Configure the workflow**: Update the workflow configuration to match your project's needs. In the sample YAML file provided in this repository, you'll find the following key sections:

   - `on`: Define the events that trigger the workflow, such as `push`, `pull_request`, and `workflow_dispatch`. You can customize this section to match your repository's branching strategy and event triggers.

   - `permissions`: Define the required permissions for the workflow. Adjust the permissions as necessary for your project.

   - `jobs`: Define the individual jobs that make up your workflow. Each job can use different actions, parameters, and secrets as discussed below.

4. **Customize the jobs**: Customize the jobs within the workflow according to your requirements. In the sample YAML file, you'll find three jobs: `Validating`, `Plan`, and `Apply`. These jobs use external actions and specify input parameters and secrets. Look for the Workflow Explanation below for each jobs usage 

5. **Secrets**: Make sure to set up the necessary secrets in your repository's GitHub Secrets settings. Replace the references to secrets in your YAML file with the correct secret names.

6. **Save and commit**: Save your YAML file and commit it to your repository. GitHub Actions will automatically pick up the workflow configuration, and it will run based on the defined triggers.

## Workflow Explanation

Here's a brief explanation of the jobs included in the reusable YAML files:

- `Validating`: `terraform-build.yaml` This job validates your infrastructure code using Terraform. It uses an external action and passes parameters and secrets to it.

- `Plan`: `terraform-plan.yaml`This job creates an execution plan for your Terraform infrastructure changes.

- `Apply`: `terraform-apply.yaml` This job applies the Terraform changes but only if the trigger event is a push to the `main` branch.

## Github Federated Credentials
The below changes are used if you are using Github Federated Credentials for Azure:

- This will use the Github authentication mode to use Azure federated credentials which avoids using Azure Secrets rotation..
  ```
  ARM_USE_OIDC: true
  ```

## Additional Information

- For more information on creating and configuring GitHub Actions workflows, refer to the [GitHub Actions documentation](https://docs.github.com/en/actions).

- You can find the external actions used in the sample YAML file from the `uses` field. Make sure these actions are compatible with your project's requirements.

- Customize the workflow to add or remove jobs and actions as needed for your specific use case.

By following these steps, you can quickly set up and customize GitHub Actions workflows for your projects using this reusable framework.


# Sample Code
# << >> to replace the required values in the yaml file 

```
name: <<Add the name of the workflow here>>
on: 
  push:
    paths:
      - <<'keyvault/example/**'>>  # provide the path of the resource tf files which execute when merged to main branch 
    branches: [ main ]
  pull_request:
    paths:
      - <<'keyvault/example/**'>>  # provide the path of the resource tf files which execute when pushed to feature branch 
    branches: [ main ]
  workflow_dispatch:
    inputs:
      destroy:
        description: 'Destroy Resources'
        required: false
        default: false
    
  
permissions:
  id-token: write
  contents: read
  issues: write
  pull-requests: write
  
jobs:
  Validating:
    name: Validate
    uses: xxxxxxxxxxxx/iac-github-workflow-templates/.github/workflows/terraform-build.yaml@main
    with:
      environment: <<dev>>                                        # Provide the environment
      terraform_directory: <<'keyvault/example'>>                 # provide the path of the tf resource
      artifact-name: <<keyvault>>                                 # resource name 
      AZURE_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}                # Azure client ID will be taken from github variables 
      AZURE_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}    # Azure Sub ID will be taken from github variables 
      AZURE_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}                # Azure Tenant ID will be taken from github variables 
      #ARM_USE_OIDC: true
    secrets: inherit
      
  Plan:
    name: Plan
    needs: [Validating]
    uses: xxxxxxxxxxx/iac-github-workflow-templates/.github/workflows/terraform-plan.yaml@main
    with:
      environment: <<dev >>                                         # Provide the environment
      terraform_directory: ""
      artifact-name: <<keyvault>>                                   # resource name 
      AZURE_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      AZURE_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
    secrets: inherit

  Apply:
    name: Apply
    if: github.event.ref == 'refs/heads/main'
    needs: [Plan]
    uses: xxxxxxxxxxx/iac-github-workflow-templates/.github/workflows/terraform-apply.yaml@main
    with:
      environment: production                                        # Provide the environment
      terraform_directory: ""
      artifact-name: keyvault                                        # resource name 
      AZURE_CLIENT_ID: ${{ vars.AZURE_CLIENT_ID }}
      AZURE_SUBSCRIPTION_ID: ${{ vars.AZURE_SUBSCRIPTION_ID }}
      AZURE_TENANT_ID: ${{ vars.AZURE_TENANT_ID }}
    secrets: inherit

```
![Static Badge](https://img.shields.io/badge/Language-YAML-blue)
