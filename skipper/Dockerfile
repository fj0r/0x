FROM alpine as builder
FROM fj0rd/scratch:dropbear-alpine as dropbear
RUN set -eux \
  ; apk --update add --no-cache \
    jq curl binutils \
  ; skipper_url=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/zalando/skipper/releases \
        | jq -r '.[0].assets[].browser_download_url' | grep linux-amd64) \
  ; curl -sSL ${skipper_url} | tar zxf - -C /usr/local/bin --strip-components 1
  #; strip /usr/local/bin/skipper \

FROM alpine:3
COPY --from=dropbear / /
COPY --from=builder /usr/local/bin/skipper /usr/local/bin

EXPOSE 80 9911

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk --update add --no-cache \
    jq \
    curl \
    bash \
    tzdata \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; mkdir /etc/dropbear

COPY entrypoint.sh /

WORKDIR /srv
ENTRYPOINT /entrypoint.sh
