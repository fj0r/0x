FROM fj0rd/scratch:dropbear-alpine as dropbear
FROM fj0rd/scratch:utilities as utilities

FROM alpine:3
COPY --from=dropbear / /
COPY --from=utilities /usr/local/bin/xh /usr/local/bin

ARG BUILD_DEPS="\
    binutils \
    "

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk --update add --no-cache \
    jq \
    curl \
    bash \
    tzdata \
    libssl3 \
    #openssl-dev \
  ; apk add --no-cache --virtual .build-deps ${BUILD_DEPS} \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; skipper_url=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/zalando/skipper/releases \
        | jq -r '.[0].assets[].browser_download_url' | grep linux-amd64) \
  ; curl -sSL ${skipper_url} | tar zxf - -C /usr/local/bin --strip-components 1 \
  ; strip /usr/local/bin/skipper \
  ; apk del .build-deps \
  ; mkdir /etc/dropbear

COPY entrypoint.sh /

WORKDIR /srv
ENTRYPOINT /entrypoint.sh
