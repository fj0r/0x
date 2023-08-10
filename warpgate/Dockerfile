FROM fj0rd/scratch:boringtun as assets

FROM fj0rd/0x:wg

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

 RUN warpgate_ver=$(curl -sSL https://api.github.com/repos/warp-tech/warpgate/releases/latest | jq -r '.tag_name') \
    ; echo "download warpgate ${warpgate_ver} in $(pwd)" \
    ; warpgate_url="https://github.com/warp-tech/warpgate/releases/download/${warpgate_ver}/warpgate-${warpgate_ver}-x86_64-linux" \
    ; curl -sSL ${warpgate_url} -o /usr/local/bin/warpgate && chmod +x /usr/local/bin/warpgate 

COPY entrypoint/wireguard.sh /entrypoint/

CMD [ "srv" ]