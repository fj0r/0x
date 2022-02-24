```
docker run --name netclient \
    -d --restart=always \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    -e NM_TOKEN=${NM_TOKEN}  \
    -e NM_NAME=${NM_NAME} \
    -e _1234=5.6.7.8:90 \
    fj0rd/0x:nm
```
PostUp:
```
iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
PostDown:
```
iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
