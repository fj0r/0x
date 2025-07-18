FROM ghcr.io/fj0r/0x:mihomo

RUN set -eux \
  ; mkdir -p /opt/CloudflareST \
  ; curl --retry 3 -fsSL https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/cfst_linux_amd64.tar.gz \
    | tar zxf - -C /opt/CloudflareST \
  ; chmod +x /opt/CloudflareST/cfst

COPY cloudflare.sh /
COPY entrypoint/cloudflare.sh /entrypoint/
ENV CONFIG_CLOUDFLARE="/data/proxies/cloudflare.yaml|.proxies[0].server"
