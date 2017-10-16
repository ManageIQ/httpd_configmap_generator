# Httpd Configmap Generator - Active Directory

This documents how to run the httpd\_configmap\_generator tool to configure external authentication
by joining an Active Directory domain.


## Usage for the `active-directory` auth-type:

```
$ /opt/httpd_configmap_generator/bin/httpd_configmap_generator active-directory --help
      httpd_configmap_generator 0.1.0 - External Authentication Configuration script

      Usage: httpd_configmap_generator auth_type | update | export [--help | options]

      httpd_configmap_generator options are:
  -V, --version              Version of the httpd_configmap_generator command
  -h, --host=<s>             Application Domain (default: )
  -o, --output=<s>           Configuration map file to create (default: )
  -a, --ad-domain=<s>        Active Directory Domain (default: )
  -u, --ad-server=<s>        Active Directory User (default: )
  -p, --ad-password=<s>      Active Directory Password (default: )
  -f, --force                Force configuration if configured already
  -d, --debug                Enable debugging
  -r, --ad-realm=<s>         Active Directory Realm (default: )
  -e, --help                 Show this message
```

### Example:

```
$ /opt/httpd_configmap_generator/bin/httpd_configmap_generator active-directory \
   --host=application.example.com  \
   --ad-domain=example.com         \
   --ad-realm=EXAMPLE.COM          \
   --ad-user=Administrator         \
   --ad-password=smartvm           \
   -o /tmp/external-active-directory.yaml
```

