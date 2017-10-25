# Httpd Configmap Generator - Active Directory

This documents how to run the httpd\_configmap\_generator tool to configure external authentication
by joining an Active Directory domain.


## Usage for the `active-directory` auth-type:

```
$ httpd_configmap_generator active-directory --help
Options:
  -h, --host=<s>           Application Domain
  -o, --output=<s>         Configuration map file to create
  -a, --ad-domain=<s>      Active Directory Domain
  -u, --ad-user=<s>        Active Directory User
  -p, --ad-password=<s>    Active Directory Password
  -f, --force              Force configuration if configured already
  -d, --debug              Enable debugging
  -r, --ad-realm=<s>       Active Directory Realm
  -s, --ad-server=<s>      Active Directory Server
  -e, --help               Show this message
```

### Example:

```
$ httpd_configmap_generator active-directory \
   --host=application.example.com  \
   --ad-domain=example.com         \
   --ad-realm=EXAMPLE.COM          \
   --ad-user=Administrator         \
   --ad-password=smartvm           \
   -o /tmp/external-active-directory.yaml
```
