FROM fj0rd/scratch:tailscale as assets

FROM fj0rd/io:base

COPY --from=assets /linux_amd64 /usr/local/bin
COPY --from=assets /derper /usr/local/bin
COPY client.entrypoint.sh /entrypoint.sh

RUN set -eux \
  ; mkdir -p /var/lib/derper \
  \
  ; coredns_url=$(curl -sSL https://api.github.com/repos/coredns/coredns/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tgz$') \
  ; curl -sSL ${coredns_url} | tar zxf - -C /usr/local/bin \
  ; chmod +x /usr/local/bin/coredns

EXPOSE 10001
EXPOSE 3478
EXPOSE 22
EXPOSE 53/udp
ENV DERP_HOST=
ENV NAME=
ENV HOST=
ENV TOKEN=
ENV COREDNS=
ENTRYPOINT ["/entrypoint.sh"]
