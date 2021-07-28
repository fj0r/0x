gen-key domain="localhost":
    mkdir -p certs
    openssl req \
        -newkey rsa:4096 -nodes -sha256 -keyout certs/{{domain}}.key \
        -x509 -days 365 -out certs/{{domain}}.crt \
        -subj /CN={{domain}}

test:
    docker run --rm \
        --name=v2ray-server \
        -p 8090:443 \
        -e V2HOST=localhost \
        -v $(pwd)/certs/localhost.key:/key \
        -v $(pwd)/certs/localhost.crt:/crt \
        -v $PWD:/pub \
        nnurphy/v2ray:ngx

run:
    docker run --restart=always -d \
        --name=v2ray-server \
        -p 8443:443 \
        -e V2HOST=iffy.me \
        -v $HOME/.acme.sh/iffy.me/fullchain.cer:/crt \
        -v $HOME/.acme.sh/iffy.me/iffy.me.key:/key \
        nnurphy/v2ray:ngx

server:
    docker run --restart=always -d \
        --name=v2ray-srv \
        -p 8090:80 \
        -e V2HOST=iffy.me \
        -e V2PORT=443 \
        -e V2WSURL=xxxxxxxxxxxxxxxxxxx \
        -e V2UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx \
        -v $PWD/pub:/pub \
        nnurphy/v2ray:ngx

build:
    docker build . -t nnurphy/v2ray

buildn:
    docker build . -t nnurphy/v2ray:ngx -f Dockerfile-ngx \
        --build-arg s6url=http://172.178.1.204:2015/s6-overlay-amd64.tar.gz
