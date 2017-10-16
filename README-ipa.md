# Httpd Configmap Generator - IPA

This documents how to run the httpd\_configmap\_generator tool to configure external authentication
for an IPA server.


## Usage for the `ipa` auth-type:

```
$ /opt/httpd_configmap_generator/bin/httpd_configmap_generator ipa --help
      httpd_configmap_generator 0.1.0 - External Authentication Configuration script

      Usage: httpd_configmap_generator auth_type | update | export [--help | options]

      httpd_configmap_generator options are:
  -V, --version              Version of the httpd_configmap_generator command
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
$ /opt/httpd_configmap_generator/bin/httpd_configmap_generator ipa \
   --force                                 \
   --host=application.example.com          \
   --ipa-server=ipaserver7.example.com     \
   --ipa-domain=example.com                \
   --ipa-realm=EXAMPLE.COM                 \
   --ipa-principal=admin                   \
   --ipa-password=smartvm                  \
   -o /tmp/external-ipa.yaml
```

  
