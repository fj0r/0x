genconf:
```
, new example.network.yaml
```
run:
```
podman run --rm --name nebula
    -v $"($env.PWD)/entrypoint.sh:/entrypoint.sh" \
    -v $"($env.PWD)/data/example/node_x.yaml://nebula/config.yaml" \
    --cap-add=NET_ADMIN \
    --cap-add=NET_RAW \
    --device /dev/net/tun \
    fj0rd/0x:nebula
```
