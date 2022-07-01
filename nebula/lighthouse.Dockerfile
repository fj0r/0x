FROM fj0rd/io as build

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; yq_url=$(curl -sSL https://api.github.com/repos/mikefarah/yq/releases -H 'Accept: application/vnd.github.v3+json' \
          | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tar') \
  ; curl -sSL ${yq_url} | tar zxf - && mv yq_linux_amd64 /root/assets/yq && chmod +x /root/assets/yq \
  \
  ; mkdir /root/assets && cd /root/assets \
  \
  ; url=$(curl -sSL https://api.github.com/repos/slackhq/nebula/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '.[0].assets[].browser_download_url' | grep linux-amd64) \
  ; curl -sSL ${url} | tar zxf - \
  ; strip -s nebula*


FROM fj0rd/io:base
WORKDIR /world

COPY --from=build /root/assets /usr/local/bin
COPY lighthouse.entrypoint.sh /entrypoint.sh
COPY config.yaml /config.yaml.tmpl
COPY join /usr/local/bin
EXPOSE 51821/udp
ENV NETWORK_ID NEBULA_CONFIG
ENV VHOST VCIDR
ENV HOST_IP HOST_PORT

ENTRYPOINT [ "/entrypoint.sh"]

