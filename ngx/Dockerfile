FROM fj0rd/scratch:dropbear-alpine as dropbear

FROM alpine:3
COPY --from=dropbear / /

ARG BUILD_DEPS="\
    jq \
    curl \
    build-base \
    linux-headers \
    "

ENV PATH=/opt/nginx/sbin:$PATH
ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk --update add --no-cache \
    tzdata libcrypto3 bash git \
    openssl-dev pcre-dev zlib-dev \
    ${BUILD_DEPS} \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; mkdir /etc/dropbear \
  \
  ; xh_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ducaale/xh/releases | jq -r '.[0].tag_name') \
  ; curl -sSL https://github.com/ducaale/xh/releases/download/${xh_ver}/xh-${xh_ver}-x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /usr/local/bin --strip-components=1 xh-${xh_ver}-x86_64-unknown-linux-musl/xh \
  \
  ; mkdir /tmp/build && cd /tmp/build \
  \
  ; mkdir nchan \
  ; NCHAN_VER=$(curl -sSL https://api.github.com/repos/slact/nchan/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 2-) \
  ; curl -sSL https://github.com/slact/nchan/archive/v${NCHAN_VER}.tar.gz | tar -zxf - -C nchan --strip-components=1 \
  \
  ; mkdir njs \
  ; curl -sSL http://hg.nginx.org/njs/archive/tip.tar.gz | tar -zxf - --strip-components=1 -C njs \
  \
  ; NGINX_VER=$(curl -sSL https://api.github.com/repos/nginx/nginx/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 9-) \
  ; curl -sSL https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -zxf - \
  \
  ; cd nginx-${NGINX_VER} \
  ; ./configure --prefix=/opt/nginx \
        --with-threads \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_auth_request_module \
        --with-http_addition_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_slice_module \
        --with-http_sub_module \
        --with-http_stub_status_module \
        --with-http_realip_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_realip_module \
        --with-stream_ssl_preread_module \
        --add-module=../njs/nginx \
        --add-dynamic-module=../nchan \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
  ; make \
  ; make install \
  \
  ; ln -sf /opt/nginx/conf /etc/nginx \
  ; ln -sf /dev/stdout /var/log/nginx/access.log \
  ; ln -sf /dev/stderr /var/log/nginx/error.log \
  \
  ; apk del ${BUILD_DEPS} \
  ; rm -rf /tmp/build \
  ; rm -rf /var/cache/apk/*

VOLUME ["/var/log/nginx"]
COPY config /etc/nginx
COPY start.sh /

WORKDIR /srv

EXPOSE 80 443

ENTRYPOINT /start.sh
ENV INSPECT_REQUEST=0
