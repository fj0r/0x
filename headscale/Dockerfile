FROM fj0rd/0x:wg
WORKDIR /app

RUN set -eux \
  ; hs_url=$(curl -sSL https://api.github.com/repos/juanfont/headscale/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][].assets[].browser_download_url' | grep 'linux_amd64$' | head -n 1) \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    sqlite3 ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; curl -sSLo /usr/local/bin/headscale ${hs_url} \
  ; chmod +x /usr/local/bin/headscale \
  ; mkdir -p /etc/headscale \
  ; mkdir -p /var/lib/headscale


COPY entrypoint.sh /
COPY config.yaml /etc/headscale/config.yaml

EXPOSE 8080
EXPOSE 8081

ENV IP_PREFIX
ENV NAMESERVER
ENV DOMAIN
ENV SERVER_URL
ENV NAMESPACE

ENTRYPOINT ["/entrypoint.sh"]
