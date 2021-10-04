FROM manageiq/httpd-init:latest
MAINTAINER ManageIQ https://github.com/ManageIQ

LABEL name="httpd-configmap-generator" \
      summary="httpd image for configuring external authentication" \
      description="An httpd image which can configure external authentication and generate the auth-config map" \
      io.k8s.display-name="Httpd with Authentication Configuration" \
      io.k8s.description="An httpd image which can configure external authentication and generate the auth-config map"

ENV HTTPD_AUTH_TYPE=internal \
    HTTPD_AUTH_KERBEROS_REALMS=undefined \
    TERM=xterm

RUN dnf -y --disableplugin=subscription-manager install \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf -y --disableplugin=subscription-manager install \
        authselect-compat \
        openldap-clients \
        pamtester && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN gem install --no-document httpd_configmap_generator
