```
export REPLACE_MASTER_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 30 ; echo '')
export NETMAKER_MASTER_KEY=${NETMAKER_MASTER_KEY:-$REPLACE_MASTER_KEY}

#-p 8081:8081 \
docker run --name netmaker \
    -d --restart=always \
    --cap-add=NET_ADMIN \
    --cap-add=SYS_MODULE \
    -p 8082:80 \
    -p 50051:50051 \
    -p 53:53/udp \
    -p 51821:51821/udp \
    -v $PWD/netclient:/etc/netclient/config \
    -v $PWD/dnsconfig:/root/config/dnsconfig \
    -v $PWD/netmaker:/root/data \
    -e MASTER_KEY="${NETMAKER_MASTER_KEY}" \
    -e SERVER_HOST=1.2.3.4 \
    fj0rd/0x:netmaker
```