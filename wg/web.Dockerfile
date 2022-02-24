FROM fj0rd/io:go AS build
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

FROM fj0rd/0x:wg
WORKDIR /app
COPY --from=build /target /app
COPY web.entrypoint.sh /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
