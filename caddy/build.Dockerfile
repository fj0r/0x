FROM fj0rd/io:go

RUN set -eux \
  ; go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
