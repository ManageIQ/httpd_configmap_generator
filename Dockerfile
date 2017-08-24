
FROM abellotti/httpd:ext-auth-latest
MAINTAINER ManageIQ https://github.com/ManageIQ/manageiq-appliance-build

LABEL name="auth-config-httpd" \
      summary="httpd image for configuring external authentication" \
      description="An httpd image which can configure external authentication and generate the auth-config map" \
      io.k8s.display-name="Httpd with Authentication Configuration" \
      io.k8s.description="An httpd image which can configure external authentication and generate the auth-config map"

## Ruby build steps from ManageIQ/container-ruby
## For ruby
ENV RUBY_GEMS_ROOT=/opt/rubies/ruby-2.3.1/lib/uby/gems/2.3.0 \
    PATH=$PATH:/opt/rubies/ruby-2.3.1/bin \
    LANG=en_US.UTF-8 \
    REF=master

## Install repos
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    curl -sL https://copr.fedorainfracloud.org/coprs/postmodern/ruby-install/repo/fedora-25/postmodern-ruby-install-fedora-25.repo -o /etc/yum.repos.d/ruby-install.repo && \
    sed -i 's/\$releasever/25/g' /etc/yum.repos.d/ruby-install.repo

## Install ruby-install and make
RUN yum -y install --setopt=tsflags=nodocs ruby-install make

RUN ruby-install ruby 2.3.1 -- --disable-intall-doc && rm -rf /usr/local/src/* && yum clean all


## For httpd-auth-config
ENV TERM=xterm \
    CONTAINER_ROOT=/opt/httpd-auth-config

## GIT clone httpd-auth-config
RUN mkdir -p ${CONTAINER_ROOT} && \
    curl -L https://github.com/abellotti/httpd-auth-config/tarball/${REF} | tar vxz -C ${CONTAINER_ROOT} --strip 1

## Change workdir to the container
WORKDIR ${CONTAINER_ROOT}

## Setup container application
RUN cd ${CONTAINER_ROOT} && \
    gem install bundler --conservative && \
    bundle install && \
    find ${RUBY_GEMS_ROOT}/gems/ -name .git | xargs rm -rvf && \
    find ${RUBY_GEMS_ROOT}/gems/ | grep "\.s\?o$" | xargs rm -rvf && \
    rm -rvf ${RUBY_GEMS_ROOT}/cache/* && \
    rm -rvf /root/.bundle/cache

