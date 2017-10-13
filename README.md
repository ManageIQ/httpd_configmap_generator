# container-httpd-authconfig
Container for configuring external authentication for the httpd auth pod.
It is based on the auth httpd container and generates the httpd auth-config map
needed to enable external authentication.

## Installing

```
$ git clone https://github.com/abellotti/container-httpd-authconfig.git
```

___

## Running with Docker

### Building container image

```
$ cd container-httpd-authconfig
$ docker build . -t manageiq/httpd-authconfig:latest
```

### Running the httpd-authconfig container


```
$ docker run --privileged manageiq/httpd-authconfig:latest &
```

Getting the httpd-authconfig container id:

```
$ AUTHCONFIG_ID="`docker ps -l -q`"
```

### Generating a configmap for external authentication against IPA

While the configure-auth tool can be run in the container by first getting into a bash shell:

```
$ docker exec -it $AUTHCONFIG_ID /bin/bash -i
```

The tool can also be executed directly as follows:

Example for generating a configuration map for IPA:

```
$ docker exec $AUTHCONFIG_ID /opt/httpd-authconfig/bin/configure-auth ipa \
    --host=miq-appliance.example.com    \
    --ipa-server=ipaserver.example.com  \
    --ipa-domain=example.com            \
    --ipa-realm=EXAMPLE.COM             \
    --ipa-principal=admin               \
    --ipa-password=smartvm1             \
    -o /tmp/external-ipa.yaml
```

`--host` above must be the DNS of the application exposing the httpd auth pod, 

i.e. ${APPLICATION_DOMAIN}


Copying the new auth configmap back locally:

```
$ docker cp $AUTHCONFIG_ID:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied to the auth httpd pod and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```

#### Stopping the httpd-authconfig container

When completed with httpd-authconfig, the container can simply be stopped and/or removed:

```
$ docker stop $AUTHCONFIG_ID
```

```
$ docker rmi --force manageiq/httpd-authconfig:latest
```

___


## Running with OpenShift

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
$ oc create -f templates/miq-httpd-authconfig-template.yaml

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

For working with the configure-auth script in the httpd-authconfig pod, it is necessary to
get the pod name reference below:


```
$ AUTHCONFIG_POD=`oc get pods | grep "httpd-authconfig" | cut -f1 -d" "`
```


### Generating a configmap for external authentication against IPA

```
$ oc rsh $AUTHCONFIG_POD /opt/httpd-authconfig/bin/configure-auth ipa ...
```

Example configuration:

```
$ oc rsh $AUTHCONFIG_POD /opt/httpd-authconfig/bin/configure-auth ipa \
    --host=miq-appliance.example.com    \
    --ipa-server=ipaserver.example.com  \
    --ipa-domain=example.com            \
    --ipa-realm=EXAMPLE.COM             \
    --ipa-principal=admin               \
    --ipa-password=smartvm1             \
    -o /tmp/external-ipa.yaml
```

`--host` above must be the DNS of the application exposing the httpd auth pod, 

i.e. ${APPLICATION_DOMAIN}


Copying the new auth configmap back locally:

```
$ oc cp $AUTHCONFIG_POD:/tmp/external-ipa.yaml ./external-ipa.yaml
```

The new configmap can then be applied to the auth httpd pod and then redeployed to take effect:

```
$ oc replace configmaps httpd-auth-configs --filename ./external-ipa.yaml
```


### Usage for the configure-auth tool:

```
$ oc rsh $AUTHCONFIG_POD /opt/httpd-authconfig/bin/configure-auth
```

Additional information on the configure-auth tool is available in the
httpd-authconfig gem [README.md](https://github.com/abellotti/httpd-authconfig/blob/master/README.md)

To generate a new auth configuration map it is recommended to redeploy the manageiq-httpd-authconfig
pod first to get a clean environment before running the /opt/httpd-authconfig/bin/configure-auth tool.

When done generating an auth-configmap, the manageiq-httpd-authconfig pod can simply be scaled down:

```
$ oc scale dc httpd-authconfig --replicas=0
```

