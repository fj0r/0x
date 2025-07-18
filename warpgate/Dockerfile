FROM ghcr.io/fj0r/0x:wg

RUN set -eux \
  ; warpgate_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/warp-tech/warpgate/releases/latest | jq -r '.tag_name') \
  ; warpgate_url="https://github.com/warp-tech/warpgate/releases/download/${warpgate_ver}/warpgate-${warpgate_ver}-x86_64-linux" \
  ; curl --retry 3 -fsSL ${warpgate_url} -o /usr/local/bin/warpgate \
  ; chmod +x /usr/local/bin/warpgate

COPY entrypoint/warpgate.sh /entrypoint/

WORKDIR /data

CMD [ "srv" ]