FROM fj0rd/scratch:dropbear as dropbear
FROM fj0rd/io:base
COPY --from=dropbear / /

EXPOSE 80

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; reproxy_ver=$(curl --retry 3 -sSL https://api.github.com/repos/umputun/reproxy/releases/latest | jq -r '.tag_name') \
  ; reproxy_url="https://github.com/umputun/reproxy/releases/download/${reproxy_ver}/reproxy_${reproxy_ver}_linux_x86_64.tar.gz" \
  ; curl --retry 3 -sSL ${reproxy_url} | tar zxf - -C /usr/local/bin reproxy


COPY entrypoint/reproxy.sh /entrypoint/
CMD ["srv"]
WORKDIR /srv
