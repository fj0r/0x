FROM fj0rd/io:common

RUN set -eux \
  ; mihomo_ver=$(curl --retry 3 -sSL https://api.github.com/repos/MetaCubeX/mihomo/releases -H 'Accept: application/vnd.github.v3+json' \
    | jq -r '[.[]|select(.prerelease != true)][0].tag_name') \
  ; mihomo_url="https://github.com/MetaCubeX/mihomo/releases/download/${mihomo_ver}/mihomo-linux-amd64-${mihomo_ver}.gz" \
  ; curl --retry 3 -sSL ${mihomo_url} | gzip -d > /usr/local/bin/mihomo \
  ; chmod +x /usr/local/bin/mihomo \
  \
  ; CountryMmdbUrl=$(curl -sSL https://api.github.com/repos/alecthw/mmdb_china_ip_list/releases -H 'Accept: application/vnd.github.v3+json' \
    | jq -r '.[0].assets[].browser_download_url' | grep mmdb | grep -v lite) \
  ; curl -sSL ${CountryMmdbUrl} -o /opt/Country.mmdb \
  \
  ;

COPY entrypoint/mihomo.sh /entrypoint/
EXPOSE 7890 7891 9090
CMD ["srv"]
VOLUME /data
WORKDIR /data
