FROM fj0rd/scratch:boringtun as assets

FROM fj0rd/0x:wg

COPY --from=assets / /

RUN warpgate_ver=$(curl -sSL https://api.github.com/repos/warp-tech/warpgate/releases/latest | jq -r '.tag_name') \
  ; warpgate_url="https://github.com/warp-tech/warpgate/releases/download/${warpgate_ver}/warpgate-${warpgate_ver}-x86_64-linux" \
  ; curl -sSL ${warpgate_url} -o /usr/local/bin/warpgate \
  ; chmod +x /usr/local/bin/warpgate

COPY entrypoint/warpgate.sh /entrypoint/

CMD [ "srv" ]