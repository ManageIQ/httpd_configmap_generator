
FROM manageiq/httpd:latest
MAINTAINER ManageIQ https://github.com/ManageIQ/manageiq-appliance-build

LABEL name="auth-confighttpd" \
      summary="httpd image for configuring external authentication" \
      description="An httpd image which can configure external authentication and generate the auth-config map" \
      io.k8s.display-name="Httpd with Authentication Configuration" \
      io.k8s.description="An httpd image which can configure external authentication and generate the auth-config map"

## Ruby build steps from ManageIQ/container-ruby
## For ruby
ENV REF=master

## For httpd-authconfig
ENV TERM=xterm \
    AUTH_CONFIG_DIRECTORY=/opt/httpd-authconfig

## Need git
RUN yum install -y git

## Fetch and build the httpd-auth-config gem
RUN mkdir -p ${AUTH_CONFIG_DIRECTORY}                                   && \
    curl -L https://github.com/abellotti/httpd-authconfig/tarball/${REF}  \
      | tar vxz -C ${AUTH_CONFIG_DIRECTORY} --strip 1                   && \
    cd ${AUTH_CONFIG_DIRECTORY}                                         && \
    bundle install

## Copy minimalistic container-environment for bringing up container
COPY docker-assets/container-environment /etc/container-environment

## Set the working directory of the container
WORKDIR ${AUTH_CONFIG_DIRECTORY}

