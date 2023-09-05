FROM fj0rd/io:common

RUN set -eux \
  ; premium_url=$(curl --retry 3 -sSL https://api.github.com/repos/Dreamacro/clash/releases/tags/premium -H 'Accept: application/vnd.github.v3+json' \
    | jq -r '.assets[].browser_download_url' | grep linux-amd64 | grep -v v3) \
  ; curl --retry 3 -sSL ${premium_url} | gzip -d > /usr/local/bin/clash.premium \
  ; chmod +x /usr/local/bin/clash.premium \
  \
  ; meta_ver=$(curl --retry 3 -sSL https://api.github.com/repos/MetaCubeX/Clash.Meta/releases -H 'Accept: application/vnd.github.v3+json' \
    | jq -r '[.[]|select(.prerelease != true)][0].tag_name') \
  ; meta_url="https://github.com/MetaCubeX/Clash.Meta/releases/download/${meta_ver}/clash.meta-linux-amd64-${meta_ver}.gz" \
  ; curl --retry 3 -sSL ${meta_url} | gzip -d > /usr/local/bin/clash.meta \
  ; chmod +x /usr/local/bin/clash.meta \
  \
  ; CountryMmdbUrl=$(curl -sSL https://api.github.com/repos/alecthw/mmdb_china_ip_list/releases -H 'Accept: application/vnd.github.v3+json' \
    | jq -r '.[0].assets[].browser_download_url' | grep mmdb | grep -v lite) \
  ; curl -sSL ${CountryMmdbUrl} -o /opt/Country.mmdb \
  \
  ;

# CLASH_FLAVOR: premium | meta
ENV CLASH_FLAVOR=meta
COPY entrypoint/clash.sh /entrypoint/
EXPOSE 7890 7891 9090
VOLUME /config
WORKDIR /config
