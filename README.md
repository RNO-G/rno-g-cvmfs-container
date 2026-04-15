An example of a Podman/Docker container that mounts RNO-G CVMFS

If $RNO_G_WORKSPACE is defined, that directory (which can't contain spaces) is
bind-mounted to /rno-g.  You may want to invoke docker/podman yourself as
needed if you need different bind mounts. Hopefully you know what you're doing!

# Usage with podman

```
make podman  # generate the image
make podman-run  # an example of how to run it, mounting $RNO_G_WORKSPACE to /rno-g  and $RNO_G_DATA to /data if it exists.
```


# Usage with docker

```
make docker  # generate the image
make docker-run  # an example of how to run it, mounting $RNO_G_WORKSPACE to /rno-g  and $RNO_G_DATA to /data if it exists.
```

Note that docker often must run as root, or with sudo, in which case sudo -E may be useful.




