FROM fj0rd/io:base

WORKDIR /app

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; url=$(xh https://api.github.com/repos/juanfont/headscale/releases Accept:application/vnd.github.v3+json \
        | jq -r '.[0].assets[].browser_download_url' | grep linux_amd64) \
  ; xh -F ${url} > headscale \
  ; chmod +x headscale \
  ; xh -F https://raw.githubusercontent.com/juanfont/headscale/main/config.yaml.sqlite.example > config.yaml \
  ; xh -F https://raw.githubusercontent.com/juanfont/headscale/main/derp.yaml > derp.yaml


ENTRYPOINT [ "/app/headscale"]
CMD [ "serve" ]

