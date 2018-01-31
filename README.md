# Httpd Configmap Generator

[![Gem Version](https://badge.fury.io/rb/httpd_configmap_generator.svg)](http://badge.fury.io/rb/httpd_configmap_generator)
[![Build Status](https://travis-ci.org/ManageIQ/httpd_configmap_generator.svg)](https://travis-ci.org/ManageIQ/httpd_configmap_generator)
[![Code Climate](https://codeclimate.com/github/ManageIQ/httpd_configmap_generator.svg)](https://codeclimate.com/github/ManageIQ/httpd_configmap_generator)
[![Test Coverage](https://codeclimate.com/github/ManageIQ/httpd_configmap_generator/badges/coverage.svg)](https://codeclimate.com/github/ManageIQ/httpd_configmap_generator/coverage)
[![Dependency Status](https://gemnasium.com/ManageIQ/httpd_configmap_generator.svg)](https://gemnasium.com/ManageIQ/httpd_configmap_generator)
[![Security](https://hakiri.io/github/ManageIQ/httpd_configmap_generator/master.svg)](https://hakiri.io/github/ManageIQ/httpd_configmap_generator/master)

[![Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ManageIQ/authentication?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This GEM provides a CLI to automate the generation of auth-config maps
which can be used with the httpd auth pod for enabling external authentication.

Install as follows:

```
gem install httpd_configmap_generator
```

## Running the tool

Generating an auth-config map can be done by running the httpd\_configmap\_generator tool

```
$ httpd_configmap_generator --help
httpd_configmap_generator 0.1.1 - External Authentication Configuration script

Usage: httpd_configmap_generator auth_type | update | export [--help | options]

supported auth_type: active-directory, ipa, ldap, saml

httpd_configmap_generator options are:
  -V, --version    Version of the httpd_configmap_generator command
  -h, --help       Show this message
```

Showing the usage for each authentication type or sub-command as follows:

```
$ httpd_configmap_generator ipa --help
```

## Supported Authentication Types

|auth-type         | Identity Provider/Environment                    | for usage:                                            |
|------------------|--------------------------------------------------|-------------------------------------------------------|
| active-directory | Active Directory domain realm join               | [README-active-directory](README-active-directory.md) |
| ipa              | IPA, IPA 2-factor authentication, IPA/AD Trust   | [README-ipa](README-ipa.md)                           |
| ldap             | Ldap directories                                 | [README-ldap](README-ldap.md)                         |
| saml             | Keycloak, etc.                                   | [README-saml](README-saml.md)                         |

___

## Updating an auth configuration map:

With the `update` subcommand, it is possible to add file(s) to the configuration
map as per the following usage:


```
$ httpd_configmap_generator update --help
Options:
  -i, --input=<s>       Input config map file
  -o, --output=<s>      Output config map file
  -f, --force           Force configuration if configured already
  -d, --debug           Enable debugging
  -a, --add-file=<s>    Add file to config map
  -h, --help            Show this message
```

The `--add-file` option can be specified multiple times, one per file to add
to a configuration map.

Supported file specification for the `--add-file` option are:

```
--add-file=file-path
--add-file=source-file-path,target-file-path
--add-file=source-file-path,target-file-path,file-permission
--add-file=file-url,target-file-path,file-permission
```

Where:

* file-url is an http URL
* file-permission can be specified as: `mode:owner:group`

Examples:

### Adding files by specifying paths:

The file ownership and permissions will be based on the files specified.

```
$ httpd_configmap_generator update \
  --input=/tmp/original-auth-configmap.yaml                    \
  --add-file=/etc/openldap/cacerts/primary-directory-cert.pem  \
  --add-file=/etc/openldap/cacerts/seconday-directory-cert.pem \
  --output=/tmp/updated-auth-configmap.yaml
```

### Adding target files from different source directories:


```
$ httpd_configmap_generator update \
  --input=/tmp/original-auth-configmap.yaml                                        \
  --add-file=/tmp/uploaded-cert1,/etc/openldap/cacerts/primary-directory-cert.pem  \
  --add-file=/tmp/uploaded-cert2,/etc/openldap/cacerts/seconday-directory-cert.pem \
  --output=/tmp/updated-auth-configmap.yaml
```

The file ownership and permissions will be based on the source files specified,
in this case the ownership and permissiong of the `/tmp/uploaded-cert1`
and `/tmp/uploaded-cert2` files will be used.

### Adding a target file with user specified ownership and mode:

```
$ httpd_configmap_generator update \
  --input=/tmp/original-auth-configmap.yaml                          \
  --add-file=/tmp/secondary-keytab,/etc/http2.keytab,600:apache:root \
  --output=/tmp/updated-auth-configmap.yaml
```

### Adding files by URL:

```
$ httpd_configmap_generator update \
  --input=/tmp/original-auth-configmap.yaml \
  --add-file=http://aab-keycloak:8080/auth/realms/testrealm/protocol/saml/description,/etc/httpd/saml2/idp-metadata.xml,644:root:root \
  --output=/tmp/updated-auth-configmap.yaml
```

When downloading a file by URL, a target file path and file ownership/mode must be specified.

___

## Exporting a file from an auth configuration map

With the `export` subcommand, it is possible to export a file from the configuration
map as per the following usage:


```
$ httpd_configmap_generator export --help
Options:
  -i, --input=<s>     Input config map file
  -l, --file=<s>      Config map file to export
  -o, --output=<s>    The output file being exported
  -f, --force         Force configuration if configured already
  -d, --debug         Enable debugging
  -h, --help          Show this message
```

Example:

Extract the sssd.conf file out of the auth configuration map:

```
$ httpd_configmap_generator export \
  --input=/tmp/external-ipa.yaml \
  --file=/etc/sssd/sssd.conf     \
  --output=/tmp/sssd.conf
```

# Building the Httpd Configmap Generator in a Container

Container for configuring external authentication for the httpd auth pod.
It is based on the auth httpd container and generates the httpd auth-config map
needed to enable external authentication.

## Installing

```
$ git clone https://github.com/ManageIQ/httpd_configmap_generator.git
```

___

## Running with Docker

### Building container image

```
$ cd httpd_configmap_generator
$ docker build . -t manageiq/httpd_configmap_generator:latest
```

### Running the httpd\_configmap\_generator container


```
$ docker run --privileged manageiq/httpd_configmap_generator:latest &
```

Getting the httpd_configmap_generator container id:

```
$ CONFIGMAP_GENERATOR_ID="`docker ps -l -q`"
```

### Generating a configmap for external authentication against IPA

While the httpd_configmap_generator tool can be run in the container by first getting into a bash shell:

```
$ docker exec -it $CONFIGMAP_GENERATOR_ID /bin/bash -i
```

The tool can also be executed directly as follows:

Example for generating a configuration map for IPA:

```
$ docker exec $CONFIGMAP_GENERATOR_ID httpd_configmap_generator ipa \
    --host=appliance.example.com        \
    --ipa-server=ipaserver.example.com  \
    --ipa-domain=example.com            \
    --ipa-realm=EXAMPLE.COM             \
    --ipa-principal=admin               \
    --ipa-password=smartvm1             \
    -o /tmp/external-ipa.yaml
```

`--host` above must be the DNS of the application exposing the httpd auth pod,

i.e. ${APPLICATION_DOMAIN}


Copying the new auth configmap back locally:

```
$ docker cp $CONFIGMAP_GENERATOR_ID:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied to the auth httpd pod and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```

#### Stopping the httpd\_configmap\_generator container

When completed with httpd\_configmap\_generator, the container can simply be stopped and/or removed:

```
$ docker stop $CONFIGMAP_GENERATOR_ID
```

```
$ docker rmi --force manageiq/httpd_configmap_generator:latest
```

___


## Running with OpenShift

### Pre-deployment tasks

#### If running without OCI systemd hooks (Minishift)

The httpd-configmap-generator service account must be added to the httpd-scc-sysadmin SCC before the Httpd Configmap Generator can run.

##### As Admin

Create the httpd-scc-sysadmin SCC:

```
$ oc create -f templates/httpd-scc-sysadmin.yaml
```

Include the httpd-configmap-generator service account with the new SCC:

```
$ oc adm policy add-scc-to-user httpd-scc-sysadmin system:serviceaccount:<your-namespace>:httpd-configmap-generator
```

Verify that the httpd-configmap-generator service account is now included in the httpd-scc-sysadmin SCC:

```
$ oc describe scc httpd-scc-sysadmin | grep Users
Users:        system:serviceaccount:<your-namespace>:httpd-configmap-generator
```

#### If running  with OCI systemd hooks

##### As Admin

```
$ oc adm policy add-scc-to-user anyuid system:serviceaccount:<your-namespace>:httpd-configmap-generator
```

Verify that the httpd-configmap-generator service account is included in the anyuid SCC:

```
$ oc describe scc anyuid | grep Users
Users:        system:serviceaccount:<your-namespace>:httpd-configmap-generator
```


### Deploy the Httpd Configmap Generator Application

As basic user

```
$ oc create -f templates/httpd-configmap-generator-template.yaml

$ oc get templates
NAME                        DESCRIPTION                                 PARAMETERS     OBJECTS
httpd-configmap-generator   Httpd Configmap Generator                   6 (all set)    3
```

Deploy the Httpd Configmap Generator

```
$ oc new-app --template=httpd-configmap-generator
```

Check the readiness of the Httpd Configmap Generator

```
$ oc get pods
NAME                                READY     STATUS    RESTARTS   AGE
httpd-configmap-generator-1-txc34   1/1       Running   0          1h
```

#### Getting the POD Name

For working with the httpd\_configmap\_generator script in the httpd-configmap-generator pod, it is necessary to
get the pod name reference below:


```
$ CONFIGMAP_GENERATOR_POD=`oc get pods | grep "httpd-configmap-generator" | cut -f1 -d" "`
```


### Generating a configmap for external authentication against IPA

```
$ oc exec $CONFIGMAP_GENERATOR_POD  -- bash -c 'httpd_configmap_generator ipa ...
```

Example configuration:

```
$ oc exec $CONFIGMAP_GENERATOR_POD -- bash -c 'httpd_configmap_generator ipa \
    --host=appliance.example.com        \
    --ipa-server=ipaserver.example.com  \
    --ipa-domain=example.com            \
    --ipa-realm=EXAMPLE.COM             \
    --ipa-principal=admin               \
    --ipa-password=smartvm1             \
    -o /tmp/external-ipa.yaml'
```

`--host` above must be the DNS of the application exposing the httpd auth pod,

i.e. ${APPLICATION_DOMAIN}


Copying the new auth configmap back locally:

```
$ oc cp $CONFIGMAP_GENERATOR_POD:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied to the auth httpd pod and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```

To generate a new auth configuration map it is recommended to redeploy the httpd\_configmap\_generator
pod first to get a clean environment before running the httpd\_configmap\_generator tool.

When done generating an auth-configmap, the httpd\_configmap\_generator pod can simply be scaled down:

```
$ oc scale dc httpd-configmap-generator --replicas=0
```

or deleted if no longer needed:

```
$ oc delete all  -l app=httpd-configmap-generator
$ oc delete pods -l app=httpd-configmap-generator
```
