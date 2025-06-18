FROM ghcr.io/fj0r/scratch:boringtun as assets

FROM ghcr.io/fj0r/io:base

COPY --from=assets / /

ENV WG_LOG_LEVEL=info \
    WG_THREADS=4 \
    WG_SUDO=1 \
    WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun-cli


RUN set eux \
  ; apt-get update \
  ; echo "resolvconf resolvconf/linkify-resolvconf boolean false" \
      | debconf-set-selections \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      wireguard-tools iptables resolvconf \
      curl socat \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

COPY entrypoint/wireguard.sh /entrypoint/
CMD [ "srv" ]
WORKDIR /app
