FROM fj0rd/io as build

RUN set -eux \
  ; mkdir /root/assets && cd /root/assets \
  ; nm_url=$(curl -sSL https://api.github.com/repos/gravitl/netmaker/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '.[].assets[].browser_download_url' | grep 'netmaker$' | head -n 1) \
        #| jq -r '[.[]|select(.prerelease == false)][].assets[].browser_download_url' | grep 'netmaker$' | head -n 1) \
  ; curl -sSL ${nm_url} -o netmaker \
  ; chmod +x netmaker \
  ; strip -s netmaker \
  \
  ; coredns_url=$(curl -sSL https://api.github.com/repos/coredns/coredns/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tgz$') \
  ; curl -sSL ${coredns_url} | tar zxf - \
  ; chmod +x coredns \
  ; strip -s coredns


FROM node:16-buster-slim as web

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

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    sqlite3 nginx ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; mkdir -p /app/config/dnsconfig \
  ; mkdir -p /app/data

COPY --from=build /root/assets /app
COPY --from=web /app/netmaker-ui/build /usr/share/nginx/html
COPY --from=web /app/netmaker-ui/generate_config_js.sh /
COPY entrypoint.sh /
COPY nginx/nginx.conf /etc/nginx/nginx.conf

ENV GRPC_SSL=off \
    API_PORT=8081 \
    WEB_PORT=8080 \
    GRPC_PORT=443 \
    WG_SUDO=1 \
    WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun \
    DNS_MODE=on \
    DATABASE=sqlite \
    COREDNS_ADDR=localhost \
    NETMAKER_ADDR=localhost \
    NODE_ID=server \
    BACKEND_URL=' ' \
    SERVER_API_CONN_STRING= \
    SERVER_GRPC_CONN_STRING= \
    CLIENT_MODE=on \
    SERVER_GRPC_WIREGUARD=off \
    MASTER_KEY=

EXPOSE 8080
#EXPOSE 8081
EXPOSE 50051
EXPOSE 53/udp
EXPOSE 51821/udp

ENTRYPOINT ["/entrypoint.sh"]
