FROM fj0rd/0x:clash

RUN set -eux \
  ; mkdir -p /opt/CloudflareST \
  ; curl -sSL https://github.com/XIU2/CloudflareSpeedTest/releases/latest/download/CloudflareST_linux_amd64.tar.gz \
    | tar zxf - -C /opt/CloudflareST \
  ; chmod +x /opt/CloudflareST/CloudflareST

COPY entrypoint/cloudflare.sh /entrypoint/
COPY cloudflare.cron /
ENV CRONFILE=/cloudflare.cron
ENV CONFIG_CLOUDFLARE="/config/proxies/cloudflare.yaml|.proxies[0].server"
