# Httpd AuthConfig

This GEM provides a CLI to automate the generation of auth-config maps 
which can be used with the httpd auth pod for enabling external authentication.

## Installing

The httpd-authconfig tool is to be built and provided in a container based off the httpd auth container as done with [container-httpd-authconfig](https://github.com/abellotti/container-httpd-authconfig/blob/master/README.md)

Installing as follows:

```
$ cd /opt
$ git clone https://github.com/abellotti/httpd-authconfig.git
$ cd httpd-authconfig
$ bundle install
```


## Running the tool

Generating an auth-config map can be done by running the configure-auth tool

```
$ /opt/httpd-authconfig/bin/configure-auth

Usage: configure-auth auth_type | update | export [--help | options]
Supported auth_type: active-directory, ipa, saml
```

Showing the usage for each authentication type or sub-command as follows:

```
$ /opt/httpd-authconfig/bin/configure-auth ipa --help
```

## Supported Authentication Types

|auth-type         | Identity Provider/Environment                  | for usage: |
|------------------|------------------------------------------------|------------|
| active-directory | Active Directory domain realm join             | [README-active-directory](README-active-directory.md) |
| ipa              | IPA, IPA 2-factor authentication, IPA/AD Trust | [README-ipa](README-ipa.md) |
| saml             | Keycloak, etc.                                 | [README-saml](README-saml.md) |

___

## Updating an auth configuration map:

With the `update` subcommand, it is possible to add file(s) to the configuration
map as per the following usage:


```
$ /opt/httpd-authconfig/bin/configure-auth update --help
      configure-auth 0.1.0 - External Authentication Configuration script

      Usage: configure-auth auth_type | update | export [--help | options]

      configure-auth options are:
  -V, --version         Version of the configure-auth command
  -i, --input=<s>       Input config map file (default: )
  -o, --output=<s>      Output config map file (default: )
  -f, --force           Force configuration if configured already
  -d, --debug           Enable debugging
  -a, --add-file=<s>    Add file to config map (default: )
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
$ /opt/httpd-authconfig/bin/configure-auth update \
  --input=/tmp/original-auth-configmap.yaml                    \
  --add-file=/etc/openldap/cacerts/primary-directory-cert.pem  \
  --add-file=/etc/openldap/cacerts/seconday-directory-cert.pem \
  --output=/tmp/updated-auth-configmap.yaml
```

### Adding target files from different source directories:


```
$ /opt/httpd-authconfig/bin/configure-auth update \
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
$ /opt/httpd-authconfig/bin/configure-auth update \
  --input=/tmp/original-auth-configmap.yaml                          \
  --add-file=/tmp/secondary-keytab,/etc/http2.keytab,600:apache:root \
  --output=/tmp/updated-auth-configmap.yaml
```

### Adding files by URL:

```
$ /opt/httpd-authconfig/bin/configure-auth update \
  --input=/tmp/original-auth-configmap.yaml \
  --add-file=http://aab-keycloak:8080/auth/realms/miq/protocol/saml/description,/etc/httpd/saml2/idp-metadata.xml,644:root:root \
  --output=/tmp/updated-auth-configmap.yaml
```

When downloading a file by URL, a target file path and file ownership/mode must be specified.

___

## Exporting a file from an auth configuration map

With the `export` subcommand, it is possible to export a file from the configuration
map as per the following usage:


```
$ /opt/httpd-authconfig/bin/configure-auth export --help

      configure-auth 0.1.0 - External Authentication Configuration script

      Usage: configure-auth auth_type | update | export [--help | options]

      configure-auth options are:
  -V, --version       Version of the configure-auth command
  -i, --input=<s>     Input config map file (default: )
  -l, --file=<s>      Config map file to export (default: )
  -o, --output=<s>    The output file being exported (default: )
  -f, --force         Force configuration if configured already
  -d, --debug         Enable debugging
  -h, --help          Show this message
```

Example:

Extract the sssd.conf file out of the auth configuration map:

```
$ /opt/httpd-authconfig/bin/configure-auth export \
  --input=/tmp/external-ipa.yaml \
  --file=/etc/sssd/sssd.conf     \
  --output=/tmp/sssd.conf

# Building Httpd Configmap Generator in a Container

Container for configuring external authentication for the httpd auth pod.
It is based on the auth httpd container and generates the httpd auth-config map
needed to enable external authentication.

## Installing

```
$ git clone https://github.com/abellotti/container-httpd-authconfig.git
```

___

## Running with Docker

### Building container image

```
$ cd container-httpd-authconfig
$ docker build . -t manageiq/httpd-authconfig:latest
```

### Running the httpd-authconfig container


```
$ docker run --privileged manageiq/httpd-authconfig:latest &
```

Getting the httpd-authconfig container id:

```
$ AUTHCONFIG_ID="`docker ps -l -q`"
```

### Generating a configmap for external authentication against IPA

While the configure-auth tool can be run in the container by first getting into a bash shell:

```
$ docker exec -it $AUTHCONFIG_ID /bin/bash -i
```

The tool can also be executed directly as follows:

Example for generating a configuration map for IPA:

```
$ docker exec $AUTHCONFIG_ID /opt/httpd-authconfig/bin/configure-auth ipa \
    --host=miq-appliance.example.com    \
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
$ docker cp $AUTHCONFIG_ID:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied to the auth httpd pod and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```

#### Stopping the httpd-authconfig container

When completed with httpd-authconfig, the container can simply be stopped and/or removed:

```
$ docker stop $AUTHCONFIG_ID
```

```
$ docker rmi --force manageiq/httpd-authconfig:latest
```

___


## Running with OpenShift

### Pre-deployment tasks

#### If running without OCI systemd hooks (Minishift)

The miq-httpd-authconfig service account must be added to the miq-sysadmin SCC before the Httpd Auth Config pod can run.

##### As Admin

```
$ oc adm policy add-scc-to-user miq-sysadmin system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```

Verify that the miq-httpd-authconfig service account is now included in the miq-sysadmin SCC:

```
$ oc describe scc miq-sysadmin | grep Users
Users:        system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```

#### If running  with OCI systemd hooks

##### As Admin

```
$ oc adm policy add-scc-to-user anyuid system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```

Verify that the miq-httpd-authconfig service account is now included in the miq-sysadmin SCC:

```
$ oc describe scc anyuid | grep Users
Users:        system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```


### Deploy the Httpd AuthConfig Application

As basic user

```
$ oc create -f templates/miq-httpd-authconfig-template.yaml

$ oc get templates
NAME                        DESCRIPTION                                                 PARAMETERS     OBJECTS
manageiq-httpd-authconfig   ManageIQ appliance httpd authentication configuration       7 (1 blank)    4
```

Deploy the Httpd AuthConfig

```
$ oc new-app --template=manageiq-httpd-authconfig
```

Scale up the Httpd AuthConfig

```
$ oc scale dc httpd-authconfig --replicas=1
```

Check the readiness of the httpd AuthConfig

```
$ oc get pods
NAME                       READY     STATUS    RESTARTS   AGE
httpd-authconfig-1-txc34   1/1       Running   0          1h
```

#### Getting the POD Name

For working with the configure-auth script in the httpd-authconfig pod, it is necessary to
get the pod name reference below:


```
$ AUTHCONFIG_POD=`oc get pods | grep "httpd-authconfig" | cut -f1 -d" "`
```


### Generating a configmap for external authentication against IPA

```
$ oc rsh $AUTHCONFIG_POD /opt/httpd-authconfig/bin/configure-auth ipa ...
```

Example configuration:

```
$ oc rsh $AUTHCONFIG_POD /opt/httpd-authconfig/bin/configure-auth ipa \
    --host=miq-appliance.example.com    \
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
$ oc cp $AUTHCONFIG_POD:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied to the auth httpd pod and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```


### Usage for the configure-auth tool:

```
$ oc rsh $AUTHCONFIG_POD /opt/httpd-authconfig/bin/configure-auth
```

Additional information on the configure-auth tool is available in the
httpd-authconfig gem [README.md](https://github.com/abellotti/httpd-authconfig/blob/master/README.md)

To generate a new auth configuration map it is recommended to redeploy the manageiq-httpd-authconfig
pod first to get a clean environment before running the /opt/httpd-authconfig/bin/configure-auth tool.

When done generating an auth-configmap, the manageiq-httpd-authconfig pod can simply be scaled down:

```
$ oc scale dc httpd-authconfig --replicas=0
```

