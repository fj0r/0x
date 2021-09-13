FROM fj0rd/io:base

WORKDIR /headscale

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; url=$(xh https://api.github.com/repos/juanfont/headscale/releases Accept:application/vnd.github.v3+json \
              | jq -r '.[0].assets[].browser_download_url' | grep linux-amd64) \
  ; xh -F ${url} /usr/local/bin/headscale \
  ; chmod +x /usr/local/bin/headscale \
  ; xh -F https://raw.githubusercontent.com/juanfont/headscale/main/config.json.sqlite.example > config.json
 

ENTRYPOINT [ "headscale"]
CMD [ "serve" ]

