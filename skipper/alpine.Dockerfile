FROM alpine AS builder
RUN set -eux \
  ; apk --update add --no-cache \
    jq curl binutils \
  ; skipper_ver=$(curl --retry 3 -sSL https://api.github.com/repos/zalando/skipper/releases/latest | jq -r '.tag_name') \
  ; skipper_url="https://github.com/zalando/skipper/releases/download/${skipper_ver}/skipper-${skipper_ver}-linux-amd64.tar.gz" \
  ; curl --retry 3 -sSL ${skipper_url} | tar zxf - -C /usr/local/bin --strip-components 1
  #; strip /usr/local/bin/skipper \

FROM fj0rd/scratch:dropbear-alpine AS dropbear
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
  ;


COPY entrypoint /entrypoint

WORKDIR /srv
ENTRYPOINT /entrypoint/init.sh
