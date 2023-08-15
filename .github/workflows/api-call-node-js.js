const axios = require('axios');

const url = 'https://automation.atlassian.com/pro/hooks/7e0c8982c6766ee66128b036964ae062592d1a69'; // Replace with the actual target URL

const data = {
  "issues": ["ISM1-10"],
  "data": {
    "releaseVersion": `Terraform Format and Style 🖌failure

    Terraform Initialization ⚙️success
    
    Check Terraform state file 🔎: \`\`
    
    Terraform Validation 🤖$success
    
    <details><summary>Validation Output</summary>
    
    
    [32m[1mSuccess![0m The configuration is valid.
    [0m
    
    </details>
    
    Pusher: @vinayprakash893, Action: pull_request, Working Directory: /home/runner/work/azure-terrafrom-vny-actions/azure-terrafrom-vny-actions/app2, Workflow: caller-reusable-with-approval-app2`
  }
};

const headers = {
  "Content-Type": "application/json"
};

axios.post(url, data, { headers })
  .then(response => {
    console.log('Response:', response.data);
  })
  .catch(error => {
    console.error('Error:', error);
  });
