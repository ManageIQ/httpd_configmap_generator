# container-httpd-auth-config
Docker container for configuring external authentication for the container-httpd container

## Running this docker image and get the running docker's container id
docker run --privileged abellotti/container-httpd-auth-config:latest &
AUTHCONFIG_CONTAINER_ID="`docker ps -l -q`"

## Configure external authentication against IPA
docker exec $AUTHCONFIG_CONTAINER_ID /opt/httpd-auth-config/bin/configure_ipa

## Stop the httpd authentication configuration container
docker stop $AUTHCONFIG_CONTAINER_ID
