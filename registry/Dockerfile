FROM ghcr.io/fj0r/io:base as reg

RUN set -eux \
  ; reg_url=$(curl --retry 3 -sSL https://api.github.com/repos/distribution/distribution/releases/latest \
              | jq -r '.assets[].browser_download_url' \
              | grep -v sha256 \
              | grep linux_amd64) \
  ; curl --retry 3 -sSL ${reg_url} | tar zxvf - -C /usr/local/bin registry


FROM ghcr.io/fj0r/0x:or
COPY --from=reg /usr/local/bin/registry /usr/local/bin
COPY config.yml /etc/docker/registry/config.yml
COPY openresty /etc/openresty
COPY app /app
COPY lua /etc/openresty/lua

ENV REGISTRY_STORAGE_DELETE_ENABLED=true
ENV PROXY_REMOTE_URL=https://docker.io

VOLUME ["/var/lib/registry"]
EXPOSE 80 5000

COPY entrypoint/registry.sh /entrypoint/

RUN set -eux \
  ; dust_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; mkdir dust-temp \
  ; cd dust-temp \
  ; curl --retry 3 -sSL ${dust_url} | tar zxf - --strip-components=1 \
  ; mv dust /usr/local/bin/ \
  ; cd .. \
  ; rm -rf dust-temp
