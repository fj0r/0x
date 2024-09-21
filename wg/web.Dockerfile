FROM ghcr.io/fj0r/io:go AS build
WORKDIR /app
RUN set -eux \
  ; git clone --depth=1 https://github.com/vx3r/wg-gen-web.git /app \
  ; go build -o wg-gen-web-linux github.com/vx3r/wg-gen-web/cmd/wg-gen-web \
  \
  ; cd ui \
  ; npm install \
  ; npm run build \
  \
  ; mkdir -p /target/ui \
  ; cp /app/wg-gen-web-linux /target \
  ; cp -r /app/ui/dist /target/ui \
  ; cp /app/.env /target

FROM ghcr.io/fj0r/io:__dropbear__ as dropbear
FROM ghcr.io/fj0r/0x:wg
WORKDIR /app

COPY --from=dropbear / /
COPY --from=build /target /app
RUN set -eux \
  ; coredns_url=$(curl -sSL https://api.github.com/repos/coredns/coredns/releases -H 'Accept: application/vnd.github.v3+json' \
        | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tgz$') \
  ; curl -sSL ${coredns_url} | tar zxf - -C /usr/local/bin \
  ; chmod +x /usr/local/bin/coredns

COPY entrypoint/coredns.sh /entrypoint/
COPY entrypoint/wg-gen-web.sh /entrypoint/
COPY syncwg.sh /app/syncwg.sh

EXPOSE 8080
EXPOSE 53/udp

