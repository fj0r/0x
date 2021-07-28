# client

```bash
docker run \
    -p 1080:1080 \
    -p 1081:1081 \
    -d --restart=always \
    -v $HOME/.config/v2ray.json:/etc/v2ray/config.json \
    --name=v2ray \
    nnurphy/v2ray
```

# server

## with nginx
```bash
srv-443:
    docker run --restart=always -d \
        --name=v2ray-srv \
        -p 443:443 \
        -e V2HOST=iffy.me \
        -e V2PORT=443 \
        -v $PWD/pub:/pub \
        -v $HOME/.acme.sh/iffy.me/fullchain.cer:/crt \
        -v $HOME/.acme.sh/iffy.me/iffy.me.key:/key \
        nnurphy/v2ray:ngx
```

## standalone
```bash
docker run --restart=always -d \
    --name v2ray-server \
    -v $PWD/server.json:/etc/v2ray/config.json \
    -l 'traefik.enable=true' \
    -l 'traefik.http.routers.v2ray.rule=Host(`wx.iffy.me`)' \
    -l 'traefik.http.routers.v2ray.entrypoints=websecure' \
    -l 'traefik.http.routers.v2ray.tls.certResolver=default' \
    nnurphy/v2ray
```