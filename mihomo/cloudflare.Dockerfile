FROM ghcr.io/fj0r/0x:mihomo

RUN set -eux \
  ; mkdir -p /opt/CloudflareST \
  ; curl -sSL https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz \
    | tar zxf - -C /opt/CloudflareST \
  ; chmod +x /opt/CloudflareST/CloudflareST

COPY cloudflare.sh /
COPY cloudflare.cron.tmpl /
COPY entrypoint/cloudflare.sh /entrypoint/
ENV CONFIG_CLOUDFLARE="/data/proxies/cloudflare.yaml|.proxies[0].server"
