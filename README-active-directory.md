# Httpd AuthConfig - Active Directory

This documents how to run the configure-auth tool to configure external authentication
by joining an Active Directory domain.


## Usage for the `active-directory` auth-type:

```
$ /opt/httpd-authconfig/bin/configure-auth active-directory --help
      configure-auth 0.1.0 - External Authentication Configuration script

      Usage: configure-auth auth_type | update | export [--help | options]

      configure-auth options are:
  -V, --version              Version of the configure-auth command
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
$ /opt/httpd-authconfig/bin/configure-auth active-directory \
   --host=application.example.com  \
   --ad-domain=example.com         \
   --ad-realm=EXAMPLE.COM          \
   --ad-user=Administrator         \
   --ad-password=smartvm           \
   -o /tmp/external-active-directory.yaml
```

