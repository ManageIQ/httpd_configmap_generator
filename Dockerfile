FROM manageiq/httpd:latest
MAINTAINER ManageIQ https://github.com/ManageIQ

LABEL name="httpd-configmap-generator" \
      summary="httpd image for configuring external authentication" \
      description="An httpd image which can configure external authentication and generate the auth-config map" \
      io.k8s.display-name="Httpd with Authentication Configuration" \
      io.k8s.description="An httpd image which can configure external authentication and generate the auth-config map"

ENV HTTPD_AUTH_TYPE=internal \
    HTTPD_AUTH_KERBEROS_REALMS=undefined \
    TERM=xterm

RUN yum -y install openldap-clients pamtester

RUN gem install --no-ri --no-rdoc --no-document httpd_configmap_generator
