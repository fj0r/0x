FROM fj0rd/io as build

RUN set -eux \
  ; cd /root \
  ; nm_url=$(curl -sSL https://api.github.com/repos/gravitl/netmaker/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][].assets[].browser_download_url' | grep 'netclient$' | head -n 1) \
  ; curl -sSL ${nm_url} -o netclient \
  ; chmod +x netclient \
  ; strip -s netclient


FROM fj0rd/0x:wg

COPY --from=build /root/netclient /usr/local/bin
COPY client.entrypoint.sh /entrypoint.sh

ENV WG_QUICK_USERSPACE_IMPLEMENTATION=/usr/local/bin
ENTRYPOINT ["/entrypoint.sh"]
