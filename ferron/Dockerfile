FROM ghcr.io/fj0r/io:__dropbear__ AS dropbear
FROM ghcr.io/fj0r/io:base
COPY --from=dropbear / /

EXPOSE 8080

ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; ferron_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/ferronweb/ferron/releases | jq -r '.[0].name') \
  ; ferron_url="https://github.com/ferronweb/ferron/releases/download/${ferron_ver}/ferron-${ferron_ver}-x86_64-unknown-linux-musl.zip" \
  ; mkdir -p /opt/ferron \
  ; cd /opt/ferron \
  ; curl --retry 3 -fsSL ${ferron_url} -o ferron.zip \
  ; unzip ferron.zip \
  ; rm -f ferron.zip


COPY entrypoint/ferron.sh /entrypoint/
COPY ferron.kdl /opt/ferron/ferron.kdl
CMD ["srv"]
WORKDIR /srv
