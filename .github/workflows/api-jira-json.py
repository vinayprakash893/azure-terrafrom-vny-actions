import json
import requests
import sys

ticket_received = sys.argv[1]
comment_received = sys.argv[2]

data = {
"issues":[ticket_received], "data": {"commentdata": comment_received }}



headers = {
    "Content-Type": "application/json"
}


print(data)

response = requests.post("https://automation.atlassian.com/pro/hooks/7e0c8982c6766ee66128b036964ae062592d1a69",data=json.dumps(data), headers=headers)


print(json.dumps(data))




#-----------------------------------

# data = {
# "issues":["ISM1-10"], "data": {"commentdata": """${{ github.event.comment.body }}""" }}

# data = {
#     "issues":["ISM1-10"], 
#     "data": {
#     "commentdata": """#### Terraform Format and Style 🖌`failure`
#     #### Terraform Initialization ⚙️`success`
#     #### Check Terraform state file 🔎:  ``
#     #### Terraform Validation 🤖`$success`
#     <details><summary>Validation Output</summary>
    
#     ```
    
#     Success! The configuration is valid.
    
    
#     ```
    
#     </details>
    
#   *Pusher: @vinayprakash893, Action: `pull_request`, Working Directory: `/home/runner/work/azure-terrafrom-vny-actions/azure-terrafrom-vny-actions/app2`, Workflow: `caller-reusable-with-approval-app2`*
#     """
#     }
# }
