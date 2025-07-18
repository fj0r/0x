FROM fj0rd/scratch:dropbear AS dropbear
FROM fj0rd/io:base
COPY --from=dropbear / /

EXPOSE 80 9911

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; skipper_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/zalando/skipper/releases/latest | jq -r '.tag_name') \
  ; skipper_url="https://github.com/zalando/skipper/releases/download/${skipper_ver}/skipper-${skipper_ver}-linux-amd64.tar.gz" \
  ; curl --retry 3 -fsSL ${skipper_url} | tar zxf - -C /usr/local/bin --strip-components 1


COPY entrypoint/skipper.sh /entrypoint/
CMD ["srv"]
WORKDIR /srv
