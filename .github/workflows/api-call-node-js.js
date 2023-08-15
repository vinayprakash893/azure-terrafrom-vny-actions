const axios = require('axios');

const url = 'https://automation.atlassian.com/pro/hooks/7e0c8982c6766ee66128b036964ae062592d1a69'; // Replace with the actual target URL

const data = {
  "issues": ["ISM1-10"],
  "data": {
    "releaseVersion": `workingfrom piepline`
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
