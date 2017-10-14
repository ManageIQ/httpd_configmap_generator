# Httpd AuthConfig - IPA

This documents how to run the configure-auth tool to configure external authentication
for an IPA server.


## Usage for the `ipa` auth-type:

```
$ /opt/httpd-authconfig/bin/configure-auth ipa --help
      configure-auth 0.1.0 - External Authentication Configuration script

      Usage: configure-auth auth_type | update | export [--help | options]

      configure-auth options are:
  -V, --version              Version of the configure-auth command
  -h, --host=<s>             Application Domain (default: )
  -o, --output=<s>           Configuration map file to create (default: )
  -i, --ipa-server=<s>       IPA Server Fqdn (default: )
  -p, --ipa-password=<s>     IPA Server Password (default: )
  -f, --force                Force configuration if configured already
  -d, --debug                Enable debugging
  -a, --ipa-principal=<s>    IPA Server Principal (default: admin)
  -m, --ipa-domain=<s>       Domain of IPA Server (default: )
  -r, --ipa-realm=<s>        Realm of IPA Server (default: )
  -e, --help                 Show this message
```

### Example:

```
$ /opt/httpd-authconfig/bin/configure-auth ipa \
   --force                                 \
   --host=application.example.com          \
   --ipa-server=ipaserver7.example.com     \
   --ipa-domain=example.com                \
   --ipa-realm=EXAMPLE.COM                 \
   --ipa-principal=admin                   \
   --ipa-password=smartvm                  \
   -o /tmp/external-ipa.yaml
```

  
