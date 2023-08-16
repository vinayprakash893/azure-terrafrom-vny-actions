import json
import requests
import sys

parameter_received = sys.argv[1]

data = {
"issues":["ISM1-10"], "data": {"commentdata": {parameter_received}}}


headers = {
    "Content-Type": "application/json"
}


print(data)

response = requests.post("https://automation.atlassian.com/pro/hooks/7e0c8982c6766ee66128b036964ae062592d1a69",data=json.dumps(data), headers=headers)


print(json.dumps(data))