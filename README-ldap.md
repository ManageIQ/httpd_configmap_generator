# Httpd Configmap Generator - LDAP

This documents how to run the httpd\_configmap\_generator tool to configure external authentication
for an LDAP server.


## Usage for the `ldap` auth-type:

```
$ httpd_configmap_generator ldap --help
Options:
  -h, --host=<s>                           Application Domain
  -o, --output=<s>                         Configuration map file to create
  -c, --cert-file=<s>                      Cert File
  -l, --ldap-host=<s>                      LDAP Directory Host FQDN
  -a, --ldap-mode=<s>                      ldap | ldaps
  -p, --ldap-basedn=<s>                    LDAP Directory Base DN
  -f, --force                              Force configuration if configured already
  -d, --debug                              Enable debugging
  -g, --ldap-group-name=<s>                LDAP Directory Group Name (default: cn)
  -r, --ldap-group-member=<s>              Attribute containing the names of the
                                           group's members (default: member)
  -u, --ldap-group-object-class=<s>        The object class of a group entry in
                                           LDAP (default: groupOfNames)
  -i, --ldap-id-use-start-tls,
      --no-ldap-id-use-start-tls           Connection use tls? (default: true)
  -t, --ldap-port=<s>                      LDAP Directory Port
  -s, --ldap-tls-reqcert=<s>               The checks to perform on server
                                           certificates. (Default: allow)
  -e, --ldap-user-gid-number=<s>           LDAP attribute corresponding to the
                                           user's gid (default: gidNumber)
  -n, --ldap-user-name=<s>                 LDAP Directory User Name (default: cn)
  -b, --ldap-user-object-class=<s>         Object class of a user entry in LDAP
                                           (default: posixAccount)
  -m, --ldap-user-uid-number=<s>           LDAP attribute corresponding to the
                                           user's id (default: uidNumber)
  --ldap-user-search-base=<s>              The user DN search scope
  --ldap-group-search-base=<s>             The group DN search scope
  -x, --support-non-posix                  Supports non-posix user records
  --help                                   Shows this message
```

### Example:

```
$ httpd_configmap_generator ldap \
    --force                                                 \
    --host=application.example.com                          \
    --ldap-mode=ldap                                        \
    --ldap-host=ldap-server.example.com                     \
    --ldap-port=10389                                       \
    --ldap-basedn=dc=example,dc=com                         \
    --ldap-group-name=cn                                    \
    --ldap-group-search-base=ou=groups,dc=example,dc=com    \
    --ldap-group-object-class=groupOfNames                  \
    --ldap-user-name=uid                                    \
    --ldap-user-search-base=ou=users,dc=example,dc=com      \
    --ldap-user-object-class=person                         \
    --cert-file=/etc/openldap/cacerts/apacheds-cert.pem     \
    --debug                                                 \
    -o /tmp/external-ldap.yaml
```
