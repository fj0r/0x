FROM fj0rd/io:base

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; clash_url=$(curl -sSL https://api.github.com/repos/Dreamacro/clash/releases -H 'Accept: application/vnd.github.v3+json' \
              | jq -r '[.[]|select(.tag_name == "premium")][0].assets[].browser_download_url' | grep linux-amd64) \
  ; curl -sSL ${clash_url} | gzip -d > /usr/local/bin/clash \
  ; chmod +x /usr/local/bin/clash

ENTRYPOINT [ "clash", "-d"]
CMD [ "/config" ]

