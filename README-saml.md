# Httpd Configmap Generator - SAML

This documents how to run the httpd\_configmap\_generator tool to configure the container against a SAML identity provider.

## Usage for the `saml` auth-type:

```
$ httpd_configmap_generator saml --help
Options:
  -h, --host=<s>                 Application Domain
  -o, --output=<s>               Configuration map file to create
  -f, --force                    Force configuration if configured already
  -d, --debug                    Enable debugging
  -k, --keycloak-add-metadata    Download and add the Keycloak metadata file
  -e, --keycloak-server=<s>      Keycloak Server FQDN or IP
  -y, --keycloak-realm=<s>       Keycloak Realm for this client
  -l, --help                     Show this message
```

### Examples:

Creates the mellon metadata files and certificate for the container:

```
$ httpd_configmap_generator saml \
    --force                                     \
    --host=application.example.com              \
    --debug                                     \
    -o /tmp/external-saml.yaml
```

With the above, the IdP metadata file still needs to be fetched from the SAML Identity Provider and added to the configmap.

For keycloak, this can be done with the following command:

```
$ httpd_configmap_generator update \
    --input=/tmp/external-saml.yaml               \
    --add-file=http://keycloak-server.example.com:8080/auth/realms/testrealm/protocol/saml/descriptor,/etc/httpd/saml2/idp-metadata.xml,644:root:root \
    --output=/tmp/external-saml-keycloak.yaml
```

_Note_: If the Realm is already created on the Keycloak server, the following example initializes the mellon metadata files and certificates as well as downloads the IdP metadata file from Keycloak in a single command:

```
$ httpd_configmap_generator saml     \
    --force                                         \
    --host=application.example.com                  \
    --keycloak-add-metadata                         \
    --keycloak-server=keycloak-server.example.com   \
    --keycloak-realm=testrealm                      \
    --debug                                         \
    -o /tmp/external-saml.yaml
```

In the above example, the auth configmap file would include the following files:

* /etc/httpd/saml2/
  - sp-metadata.xml
  - sp-cert.cert
  - sp-key.key
  - idp-metadata.xml

For Keycloak, the `sp-metadata.xml` file can be imported to create the Client ID for
the `application.example.com` application domain.
