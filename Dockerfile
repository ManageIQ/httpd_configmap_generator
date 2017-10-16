FROM manageiq/httpd:latest
MAINTAINER ManageIQ https://github.com/ManageIQ/manageiq-appliance-build

LABEL name="httpd-configmap-generator" \
      summary="httpd image for configuring external authentication" \
      description="An httpd image which can configure external authentication and generate the auth-config map" \
      io.k8s.display-name="Httpd with Authentication Configuration" \
      io.k8s.description="An httpd image which can configure external authentication and generate the auth-config map"

## Ruby build steps from ManageIQ/container-ruby
## For ruby
ENV REF=master

## Auth Httpd Defaults
ENV HTTPD_AUTH_TYPE=internal \
    HTTPD_AUTH_KERBEROS_REALMS=undefined

## For httpd_configmap_generator
ENV TERM=xterm \
    AUTH_CONFIG_DIRECTORY=/opt/httpd_configmap_generator

## Fetch and build the httpd_configmap_generator gem
RUN mkdir -p ${AUTH_CONFIG_DIRECTORY}                                   && \
    curl -L https://github.com/ManageIQ/httpd_configmap_generator/tarball/${REF}   \
      | tar vxz -C ${AUTH_CONFIG_DIRECTORY} --strip 1                   && \
    cd ${AUTH_CONFIG_DIRECTORY}                                         && \
    bundle install

## Set the working directory of the container
WORKDIR ${AUTH_CONFIG_DIRECTORY}

