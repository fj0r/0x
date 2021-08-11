FROM fj0rd/io:base

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; clash_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/Dreamacro/clash/releases | jq -r '[.[]|select(.tag_name == "premium")][0].name' | cut -c 9-) \
  ; clash_version=2021.07.03 \
  ; clash_url=https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-${clash_version}.gz \
  ; curl -sSL ${clash_url} | gzip -d > /usr/local/bin/clash \
  ; chmod +x /usr/local/bin/clash

ENTRYPOINT [ "clash", "-d"]
CMD [ "/config" ]

