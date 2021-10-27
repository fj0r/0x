NETMAKER_ADDR=121.5.208.159
REPLACE_MASTER_KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 30 ; echo '')
NETMAKER_MASTER_KEY=${NETMAKER_MASTER_KEY:-$REPLACE_MASTER_KEY}
echo ${NETMAKER_MASTER_KEY}

podman rm -f netmaker
    #-e SERVER_API_CONN_STRING="api.NETMAKER_BASE_DOMAIN:443" \
    #-e SERVER_GRPC_CONN_STRING="grpc.NETMAKER_BASE_DOMAIN:443" \
    #-e SERVER_HTTP_HOST="api.NETMAKER_BASE_DOMAIN" \
    #-e SERVER_GRPC_HOST="grpc.NETMAKER_BASE_DOMAIN" \
    #-e CORS_ALLOWED_ORIGIN='*' \
podman run --name netmaker \
    -d --restart=always \
    --network=host \
    --cap-add=NET_ADMIN \
    -v $PWD/netclient:/etc/netclient/config \
    -v $PWD/dnsconfig:/root/config/dnsconfig \
    -v /usr/bin/wg:/usr/bin/wg \
    -v $PWD/netmaker/:/root/data \
    -e MASTER_KEY="${NETMAKER_MASTER_KEY}" \
    -e SERVER_HOST="${NETMAKER_ADDR}" \
    -e COREDNS_ADDR="${NETMAKER_ADDR}" \
    -e GRPC_SSL="off" \
    -e DNS_MODE="on" \
    -e API_PORT="8081" \
    -e GRPC_PORT="50051" \
    -e CLIENT_MODE="on" \
    -e SERVER_GRPC_WIREGUARD="off" \
    -e DATABASE="sqlite" \
    gravitl/netmaker:v0.8.4

podman rm -f netmaker-ui
podman run --name netmaker-ui \
    -d --restart=always \
    --network=host \
    -v $PWD/nginx.conf:/etc/nginx/conf.d/default.conf \
    -e MASTER_KEY="${NETMAKER_MASTER_KEY}" \
    -e BACKEND_URL="http://${NETMAKER_ADDR}:8082" \
    gravitl/netmaker-ui:v0.8

podman rm -f netmaker-dns
podman run --name netmaker-dns \
    -d --restart=always \
    --network=host \
    -v $PWD/dnsconfig:/root/dnsconfig \
    coredns/coredns \
    -conf /root/dnsconfig/Corefile
