
FROM manageiq/httpd:latest
MAINTAINER ManageIQ https://github.com/ManageIQ/manageiq-appliance-build

LABEL name="auth-config-httpd" \
      summary="httpd image for configuring external authentication" \
      description="An httpd image which can configure external authentication and generate the auth-config map" \
      io.k8s.display-name="Httpd with Authentication Configuration" \
      io.k8s.description="An httpd image which can configure external authentication and generate the auth-config map"

## Ruby build steps from ManageIQ/container-ruby
## For ruby
ENV REF=master

## For httpd-auth-config
ENV TERM=xterm \
    AUTH_CONFIG_DIRECTORY=/opt/httpd-auth-config

## GIT clone httpd-auth-config
RUN mkdir -p ${AUTH_CONFIG_DIRECTORY} && \
    curl -L https://github.com/abellotti/httpd-auth-config/tarball/${REF} | tar vxz -C ${AUTH_CONFIG_DIRECTORY} --strip 1

## Change workdir to the container
WORKDIR ${AUTH_CONFIG_DIRECTORY}

## Setup application
RUN cd ${AUTH_CONFIG_DIRECTORY} && \
    bundle install

