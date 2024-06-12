FROM ghcr.io/fj0r/io:common

RUN set -eux \
  ; mihomo_ver=$(curl --retry 3 -sSL https://api.github.com/repos/MetaCubeX/mihomo/releases -H 'Accept: application/vnd.github.v3+json' \
    | jq -r '[.[]|select(.prerelease != true)][0].tag_name') \
  ; mihomo_url="https://github.com/MetaCubeX/mihomo/releases/download/${mihomo_ver}/mihomo-linux-amd64-${mihomo_ver}.gz" \
  ; curl --retry 3 -sSL ${mihomo_url} | gzip -d > /usr/local/bin/mihomo \
  ; chmod +x /usr/local/bin/mihomo \
  \
  ; curl -sSL "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb" -o /opt/Country.mmdb \
  ; curl -sSL "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat" -o /opt/geoip.dat \
  ; curl -sSL "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.db" -o /opt/geoip.db \
  ; curl -sSL "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/cn_domain.yaml" -o /opt/cn_domain.yaml \
  \
  ;

COPY entrypoint/mihomo.sh /entrypoint/
EXPOSE 7890 7891 9090
CMD ["srv"]
VOLUME /data
WORKDIR /data
