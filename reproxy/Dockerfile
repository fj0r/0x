FROM ghcr.io/fj0r/io:__dropbear__ as dropbear
FROM ghcr.io/umputun/reproxy as reproxy
FROM ghcr.io/fj0r/io:base
COPY --from=dropbear / /
COPY --from=reproxy /srv/reproxy /usr/local/bin/reproxy

EXPOSE 80

ENV TIMEZONE=Asia/Shanghai

# RUN set -eux \
#   ; reproxy_ver=$(curl --retry 3 -sSL https://api.github.com/repos/umputun/reproxy/releases/latest | jq -r '.tag_name') \
#   ; reproxy_url="https://github.com/umputun/reproxy/releases/download/${reproxy_ver}/reproxy_${reproxy_ver}_linux_amd64.tar.gz" \
#   ; curl --retry 3 -sSL ${reproxy_url} | tar zxf - -C /usr/local/bin reproxy


COPY entrypoint/reproxy.sh /entrypoint/
CMD ["srv"]
WORKDIR /srv
