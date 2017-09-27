# container-httpd-auth-config
Container for configuring external authentication for ManageIQ.
It is based on the front-end container-httpd container and generates the httpd auth-config map
needed to enable external authentication in ManageIQ.

### Running this docker image and get the running docker's container id
```
$ docker run --privileged abellotti/container-httpd-auth-config:latest &
$ AUTHCONFIG_CONTAINER_ID="`docker ps -l -q`"
```

### Configure external authentication against IPA
```
$ docker exec $AUTHCONFIG_CONTAINER_ID /opt/httpd-auth-config/bin/configure-auth ipa ...
```

### Usage for the configure-auth tool:
```
$ docker exec $AUTHCONFIG_CONTAINER_ID /opt/httpd-auth-config/bin/configure-auth --help
```

Additional information on the configure-auth CLI is available at with the
httpd-auth-config gem [README.md](https://github.com/abellotti/httpd-auth-config/blob/master/README.md)

### Optionally get to a bash shell in the container
```
$ docker exec -it $AUTHCONFIG_CONTAINER_ID /bin/bash -i
```

### Stop the httpd authentication configuration container
```
$ docker stop $AUTHCONFIG_CONTAINER_ID
```
