ARG COMMIT="N/A"

FROM fj0rd/io:go AS build-back
WORKDIR /app
RUN set -eux \
  ; git clone --depth=1 https://github.com/vx3r/wg-gen-web.git /app \
  ; go build -o wg-gen-web-linux -ldflags="-X 'github.com/vx3r/wg-gen-web/version.Version=${COMMIT}'" github.com/vx3r/wg-gen-web/cmd/wg-gen-web \
  \
  ; npm install \
  ; npm run buildO \
  \
  ; mkdir /target \
  ; cp /app/wg-gen-web-linux /target \
  ; cp /app/dist /target/ui/dist \
  ; cp /app/.env /target

FROM fj0rd/0x:wg
WORKDIR /app
COPY --fom=build /target /app

EXPOSE 8080

CMD ["/app/wg-gen-web-linux"]
