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
Supported auth_type: ipa, saml
```

Showing the usage for each authentication type or sub-command as follows:

```
$ /opt/httpd-authconfig/bin/configure-auth ipa --help
```

## Supported Authentication Types

|auth-type| Identity Provider/Environment | for usage: |
|---------|-------------------------------|------------|
| ipa     | IPA, IPA 2-factor authentication, IPA/AD Trust |[README-ipa](README-ipa.md) |
| saml    | Keycloak, etc. | [README-saml](README-saml.md) |

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
```

