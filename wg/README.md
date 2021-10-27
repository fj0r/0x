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