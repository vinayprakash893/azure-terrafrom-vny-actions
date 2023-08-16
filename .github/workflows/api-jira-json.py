import json
import requests

data = {
"issues":["ISM1-10"], "data": {"commentdata": """
#### Terraform Format and Style 🖌`failure`
#### Terraform Initialization ⚙️`success`
#### Check Terraform state file 🔎:  ``
#### Terraform Validation 🤖`$success`
<details><summary>Validation Output</summary>

```

[32m[1mSuccess![0m The configuration is valid.
[0m

```

</details>

*Pusher: @vinayprakash893, Action: `pull_request`, Working Directory: `/home/runner/work/azure-terrafrom-vny-actions/azure-terrafrom-vny-actions/app2`, Workflow: `caller-reusable-with-approval-app2`*
"""}}


headers = {
    "Content-Type": "application/json"
}


print(data)

response = requests.post("https://automation.atlassian.com/pro/hooks/7e0c8982c6766ee66128b036964ae062592d1a69",data=json.dumps(data), headers=headers)


print(json.dumps(data))