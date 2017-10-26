# Httpd Configmap Generator - IPA

This documents how to run the httpd\_configmap\_generator tool to configure external authentication
for an IPA server.


## Usage for the `ipa` auth-type:

```
$ httpd_configmap_generator ipa --help
Options:
  -h, --host=<s>             Application Domain
  -o, --output=<s>           Configuration map file to create
  -i, --ipa-server=<s>       IPA Server FQDN
  -p, --ipa-password=<s>     IPA Server Password
  -f, --force                Force configuration if configured already
  -d, --debug                Enable debugging
  -a, --ipa-principal=<s>    IPA Server Principal (default: admin)
  -m, --ipa-domain=<s>       Domain of IPA Server
  -r, --ipa-realm=<s>        Realm of IPA Server
  -e, --help                 Show this message
```

### Example:

```
$ httpd_configmap_generator ipa \
   --force                                 \
   --host=application.example.com          \
   --ipa-server=ipaserver7.example.com     \
   --ipa-domain=example.com                \
   --ipa-realm=EXAMPLE.COM                 \
   --ipa-principal=admin                   \
   --ipa-password=smartvm                  \
   -o /tmp/external-ipa.yaml
```
