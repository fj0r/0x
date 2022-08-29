FROM caddy:builder-alpine as builder

RUN set -eux \
  ; apk --update add --no-cache curl jq \
  ; version=$(curl -s "https://api.github.com/repos/caddyserver/caddy/releases/latest" | jq -r .tag_name) \
  ; xcaddy build ${version} --output /caddy \
    --with github.com/abiosoft/caddy-yaml

FROM fj0rd/scratch:dropbear-alpine as dropbear

FROM alpine:3
COPY --from=dropbear / /
COPY --from=builder /caddy /usr/local/bin

EXPOSE 80

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk --update add --no-cache \
    bash yq curl tzdata \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; mkdir /etc/dropbear

COPY entrypoint.sh /

WORKDIR /srv
ENTRYPOINT /entrypoint.sh
