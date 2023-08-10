FROM fj0rd/io:base

EXPOSE 7890 7891
VOLUME /config
RUN set -eux \
  ; clash_ver=$(curl --retry 3 -sSL https://api.github.com/repos/MetaCubeX/Clash.Meta/releases -H 'Accept: application/vnd.github.v3+json' \
              | jq -r '[.[]|select(.prerelease != true)][0].tag_name') \
  ; clash_url="https://github.com/MetaCubeX/Clash.Meta/releases/download/${clash_ver}/clash.meta-linux-amd64-${clash_ver}.gz" \ 
  ; curl --retry 3 -sSL ${clash_url} | gzip -d > /usr/local/bin/clash \
  ; chmod +x /usr/local/bin/clash

ENTRYPOINT [ "clash", "-d"]
CMD [ "/config" ]

