# Httpd Configmap Generator - OpenID-Connect (OIDC)

This documents how to run the httpd\_configmap\_generator tool to configure the container against an OpenID-Connect (OIDC) identity provider.

## Usage for the `oidc` auth-type:

```
$ httpd_configmap_generator oidc --help
Options:
  -o, --output=<s>                Configuration map file to create
  -u, --oidc-url=<s>              OpenID-Connect Provider URL
  -i, --oidc-client-id=<s>        OpenID-Connect Provider Client ID
  -s, --oidc-client-secret=<s>    OpenID-Connect Provider Client Secret
  -f, --force                     Force configuration if configured already
  -d, --debug                     Enable debugging
  -h, --help                      Show this message

```

### Examples:

Creates the extra data for the container:

```
$ httpd_configmap_generator oidc \
    --force                                     \
    --oidc-url=http://my-keycloak:8080/auth/realms/miq/.well-known/openid-configuration \
    --oidc-client-id=my-keycloak-oidc-client \ 
    --oidc-client-secret=99999999-9999-9999-a999-99999a999999 \
    --debug                                     \
    -o /tmp/external-oidc.yaml
```

The auth configmap file for oidc does not include any files. It only includes the following extra data:

* auth-oidc-provider-metadata-url
* auth-oidc-client-id
* auth-oidc-client-secret

