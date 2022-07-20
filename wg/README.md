```
podman run --rm \
    --cap-add=NET_ADMIN --cap-add=SYS_MODULE --device /dev/net/tun \
    -v $"($env.HOME)/temp/test.conf:/etc/wireguard/wg0.conf" \
    0x:wg
```
PostUp:
```
iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
PostDown:
```
iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
