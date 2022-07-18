run:
```
podman run --rm --name nebula
    -v $"($env.PWD)/entrypoint.sh:/entrypoint.sh" \
    -e NETWORK=a \
    -e VHOST=10.11.0.1 \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    --device /dev/net/tun \
    fj0rd/0x:nebula
```
