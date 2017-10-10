# container-httpd-authconfig
Container for configuring external authentication for ManageIQ.
It is based on the auth httpd container and generates the httpd auth-config map
needed to enable external authentication in ManageIQ.

### Installing

```
$ git clone https://github.com/abellotti/container-httpd-authconfig.git
```

### Pre-deployment tasks

#### If running without OCI systemd hooks (Minishift)

The miq-httpd-authconfig service account must be added to the miq-sysadmin SCC before the Httpd Auth Config pod can run.

##### As Admin

```
$ oc adm policy add-scc-to-user miq-sysadmin system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```

Verify that the miq-httpd-authconfig service account is now included in the miq-sysadmin SCC:

```
$ oc describe scc miq-sysadmin | grep Users
Users:        system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```

#### If running  with OCI systemd hooks

##### As Admin

```
$ oc adm policy add-scc-to-user anyuid system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```

Verify that the miq-httpd-authconfig service account is now included in the miq-sysadmin SCC:

```
$ oc describe scc anyuid | grep Users
Users:        system:serviceaccount:<your-namespace>:miq-httpd-authconfig
```


### Deploy the Httpd AuthConfig Application

As basic user

```
$ oc create -f templates/miq-httpd-authconifg-template.yaml

$ oc get templates
NAME                        DESCRIPTION                                                 PARAMETERS     OBJECTS
manageiq-httpd-authconfig   ManageIQ appliance httpd authentication configuration       7 (1 blank)    4
```

Deploy the Httpd AuthConfig

```
$ oc new-app --template=manageiq-httpd-authconfig
```

Scale up the Httpd AuthConfig

```
$ oc scale dc httpd-authconfig --replicas=1
```

Check the readiness of the httpd AuthConfig

```
$ oc get pods
NAME                       READY     STATUS    RESTARTS   AGE
httpd-authconfig-1-txc34   1/1       Running   0          1h
```

#### Getting the POD Name

For working with the configure-auth script in the httpd-authconfig pod, it is necessary to get the pod name reference below as <authconfig_pod>.


```
$ authconfig_pod=`oc get pods | grep "httpd-authconfig" | cut -f1 -d" "`
```


### Generating a configmap for external authentication against IPA

```
$ oc rsh <authconfig_pod> /opt/httpd-authconfig/bin/configure-auth ipa ...
```

Example configuration:

```
$ oc rsh <authconfig_pod> /opt/httpd-authconfig/bin/configure-auth ipa \
    --force                             \
    --host=miq-appliance.example.com    \   
    --ipaserver=ipaserver.example.com   \   
    --ipadomain=example.com             \   
    --iparealm=EXAMPLE.COM              \   
    --ipaprincipal=admin                \   
    --ipapassword=smartvm1              \ 
    -o /tmp/external-ipa.yaml
```

`--host` above must be the DNS of the ManageIQ application, i.e. ${APPLICATION_DOMAIN}


Copying the new auth configmap back locally:

```
$ oc cp <authconfig_pod>:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied on the ManageIQ auth httpd and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```


### Usage for the configure-auth tool:

```
$ oc rsh <authconfig_pod> /opt/httpd-authconfig/bin/configure-auth
```

Additional information on the configure-auth CLI is available at with the
httpd-authconfig gem [README.md](https://github.com/abellotti/httpd-authconfig/blob/master/README.md)

### Httpd AuthConfig POD access

```
$ oc rsh <authconfig_pod> /bin/bash -i
```

To generate a new auth configuration map it is recommended to redeploy the manageiq-httpd-authconfig pod first to get a clean environment before running the /opt/httpd-authconfig/bin/configure-auth tool.

When done generating an auth-configmap, the manageiq-httpd-authconfig pod can simply be scaled down:

```
$ oc scale dc httpd-authconfig --replicas=0
```

