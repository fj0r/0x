FROM fj0rd/scratch:dropbear-alpine as dropbear

FROM alpine:3
COPY --from=dropbear / /

EXPOSE 80

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk --update add --no-cache \
    bash jq curl tzdata \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; mkdir /etc/dropbear \
  ; caddy_url=$(curl -sSL https://api.github.com/repos/caddyserver/caddy/releases -H 'Accept: application/vnd.github.v3+json' \
              | jq -r '.[0].assets[].browser_download_url' | grep linux_amd64.tar.gz) \
  ; curl -sSL ${caddy_url} | tar zxf - -C /usr/local/bin caddy

COPY entrypoint.sh /

WORKDIR /srv
ENTRYPOINT /entrypoint.sh
