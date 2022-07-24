FROM alpine:3

ARG BUILD_DEPS="\
    jq \
    curl \
    "

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk --update add --no-cache \
    bash \
    tzdata \
    openssl-dev \
    ${BUILD_DEPS} \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; reproxy_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/umputun/reproxy/releases | jq -r '.[0].tag_name') \
  ; curl -sSL https://github.com/umputun/reproxy/releases/download/${reproxy_ver}/reproxy_${reproxy_ver}_linux_x86_64.tar.gz \
    | tar zxf - -C /usr/local/bin reproxy

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh
