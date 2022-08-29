FROM caddy:builder-alpine

RUN set -eux \
  ; version=$(curl -s "https://api.github.com/repos/caddyserver/caddy/releases/latest" | jq -r .tag_name) \
  ; xcaddy build ${version} --output ./caddy_${version} \
        --with github.com/mholt/caddy-webdav \
        --with github.com/caddy-dns/route53 \
        --with github.com/abiosoft/caddy-exec \
        --with github.com/greenpau/caddy-trace \
        --with github.com/abiosoft/caddy-json-parse \
        --with github.com/RussellLuo/caddy-ext \
        --with github.com/kirsch33/realip \
        --with github.com/chukmunnlee/caddy-openapi \
        --with github.com/lindenlab/caddy-s3-proxy.git \
        --with github.com/Baldinof/caddy-supervisor.git \
        --with github.com/greenpau/caddy-auth-jwt \
        --with github.com/greenpau/caddy-auth-portal \
        --with github.com/hairyhenderson/caddy-teapot-module \
        --with github.com/porech/caddy-maxmind-geolocation \
        --with github.com/caddyserver/format-encoder \
        --with github.com/lindenlab/caddy-s3-proxy.git \
        --with github.com/git001/caddyv2-upload \
        --with github.com/imgk/caddy-trojan

