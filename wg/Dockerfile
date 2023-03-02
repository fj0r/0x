FROM fj0rd/scratch:boringtun as assets

FROM fj0rd/io:base

WORKDIR /app
COPY --from=assets / /

ENV WG_LOG_LEVEL=info \
    WG_THREADS=4 \
    WG_SUDO=1 \
    WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun-cli


RUN apt-get update \
 && echo "resolvconf resolvconf/linkify-resolvconf boolean false" \
      | debconf-set-selections \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      wireguard-tools iptables resolvconf \
      curl socat \
 && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint/init.sh
