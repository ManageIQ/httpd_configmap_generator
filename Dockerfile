
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
    APPLICATION_ROOT=/opt/httpd-auth-config

## GIT clone httpd-auth-config
RUN mkdir -p ${APPLICATION_ROOT} && \
    curl -L https://github.com/abellotti/httpd-auth-config/tarball/${REF} | tar vxz -C ${APPLICATION_ROOT} --strip 1

## Change workdir to the container
WORKDIR ${APPLICATION_ROOT}

## Setup application
RUN cd ${APPLICATION_ROOT} && \
    bundle install

