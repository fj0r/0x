FROM fj0rd/io as build

RUN set -eux \
  ; mkdir /root/assets && cd /root/assets \
  ; nm_url=$(curl -sSL https://api.github.com/repos/gravitl/netmaker/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'netmaker$') \
  ; curl -sSL ${nm_url} -o netmaker \
  ; chmod +x netmaker \
  ; strip -s netmaker \
  \
  ; coredns_url=$(curl -sSL https://api.github.com/repos/coredns/coredns/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tgz$') \
  ; curl -sSL ${coredns_url} | tar zxf - \
  ; chmod +x coredns \
  ; strip -s coredns


FROM node:12-buster-slim as web

WORKDIR /app
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      git ca-certificates \
  \
  ; git clone https://github.com/gravitl/netmaker-ui.git \
  ; cd netmaker-ui \
  ; npm install --silent \
  ; npm install react-scripts@3.4.1 -g --silent \
  ; npm run build

FROM fj0rd/0x:wg
WORKDIR /app

ENV BUILD_DEPS lsb-release software-properties-common build-essential git gnupg
ENV DEV_DEPS apache2-utils libpcre3-dev libssl-dev zlib1g-dev

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    sqlite3 $DEV_DEPS $BUILD_DEPS \
  \
  ; build_dir=/app/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; NGINX_VER=$(curl -sSL https://api.github.com/repos/nginx/nginx/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 9-) \
  ; curl -sSL https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -zxf - \
  \
  ; cd nginx-${NGINX_VER} \
  ; ./configure --prefix=/opt/nginx \
        --with-threads \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_auth_request_module \
        --with-http_addition_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_slice_module \
        --with-http_sub_module \
        --with-http_stub_status_module \
        --with-http_realip_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_realip_module \
        --with-stream_ssl_preread_module \
  ; make \
  ; make install \
  \
  ; rm -rf $build_dir \
  ; ln -fs /opt/nginx/conf /etc/nginx \
  ; apt-get -y remove ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; curl -sSL https://github.com/gravitl/netmaker/archive/refs/heads/master.tar.gz \
      | tar zxf - -C /app netmaker-master/config --strip-components=1 \
  \
  ; mkdir -p /app/config/dnsconfig \
  ; mkdir -p /app/data

COPY --from=build /root/assets /app
COPY --from=web /app/netmaker-ui/build /usr/share/nginx/html
COPY --from=web /app/netmaker-ui/generate_config_js.sh /
COPY entrypoint.sh /
COPY nginx/nginx.conf /etc/nginx/nginx.conf.tmpl

ENV GRPC_SSL=off \
    CLIENT_MODE=on \
    SERVER_GRPC_WIREGUARD=off \
    DATABASE=sqlite \
    DNS_MODE=on \
    WEB_PORT=18080 \
    API_PORT=18081 \
    GRPC_PORT=50051 \
    BACKEND_URL=' ' \
    COREDNS_ADDR=localhost \
    SERVER_HOST=localhost

EXPOSE 18080
EXPOSE 18081
EXPOSE 50051
EXPOSE 53/udp
EXPOSE 51821/udp

ENTRYPOINT ["/init"]
