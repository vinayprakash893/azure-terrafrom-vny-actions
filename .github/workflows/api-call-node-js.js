const axios = require('axios');

const url = 'https://automation.atlassian.com/pro/hooks/7e0c8982c6766ee66128b036964ae062592d1a69'; // Replace with the actual target URL

const data = {
  "issues": ["ISM1-10"],
  "data": {
    "commentdata": '"""#'### Terraform Format and Style 🖌`failure`
#### Terraform Initialization ⚙️`success`
#### Check Terraform state file 🔎:  ``
#### Terraform Validation 🤖`$success`
<details><summary>Validation Output</summary>

```

Success! The configuration is valid.


```

</details>

*Pusher: @vinayprakash893, Action: `pull_request`, Working Directory: `/home/runner/work/azure-terrafrom-vny-actions/azure-terrafrom-vny-actions/app2`, Workflow: `caller-reusable-with-approval-app2`*'''
  }
};

// const multilineString = ```
//   ###This is a multiline string.`sasa`
//   It can span multiple lines without using escape characters.
//   You can include variables and expressions inside placeholders.
//   Special characters like backticks \` and newlines work as expected.
// ```;
// console.log(multilineString)

data.data.commentdata = data.data.commentdata.replace(/`/g, '"');

const headers = {
  "Content-Type": "application/json"
};

console.log(data)


axios.post(url, JSON.stringify(data), { headers })
  .then(response => {
    console.log('Response:', response.data);
  })
  .catch(error => {
    console.error('Error:', error);
  });
