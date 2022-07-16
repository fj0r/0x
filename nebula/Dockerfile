FROM fj0rd/io as build

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; mkdir /root/assets \
  ; yq_url=$(curl -sSL https://api.github.com/repos/mikefarah/yq/releases -H 'Accept: application/vnd.github.v3+json' \
          | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tar') \
  ; curl -sSL ${yq_url} | tar zxf - && mv yq_linux_amd64 /root/assets/yq && chmod +x /root/assets/yq \
  \
  ; cd /root/assets \
  \
  ; url=$(curl -sSL https://api.github.com/repos/slackhq/nebula/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '.[0].assets[].browser_download_url' | grep linux-amd64) \
  ; curl -sSL ${url} | tar zxf - \
  ; strip -s nebula*


FROM fj0rd/io:base
WORKDIR /nebula

COPY --from=build /root/assets /usr/local/bin
COPY entrypoint.sh /entrypoint.sh
COPY config.yaml /nebula/config.yaml.tmpl
COPY join /usr/local/bin
EXPOSE 51821/udp
ENV NETWORK NEBULA_CONFIG
ENV VHOST VCIDR
ENV HOST HOST_PORT

ENTRYPOINT [ "/entrypoint.sh"]

