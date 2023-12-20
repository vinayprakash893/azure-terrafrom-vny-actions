# Container image that runs your code
FROM alpine:3.13.2
RUN apk add --no-cache bash docker-cli jq

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
COPY cleanup.sh /cleanup.sh

RUN chmod +x *.sh
# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]