FROM fj0rd/scratch:dropbear-alpine as dropbear

FROM alpine

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PATH=/opt/openresty/bin:$PATH

COPY --from=dropbear / /
RUN set -eux \
  ; apk update \
  ; apk add --no-cache --virtual .build-deps \
        build-base \
        coreutils \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
        openssl-dev \
        pcre-dev \
        perl \
  ; apk add --no-cache \
        libgcc \
        pcre \
        zlib \
        bash \
        curl \
        jq \
        zstd \
        patch \
        shadow \
        sudo \
        openssl \
  \
  ; build_dir=/tmp/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; OPENRESTY_VER=$(curl -sSL https://api.github.com/repos/openresty/openresty/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 2-) \
  ; curl -sSL https://openresty.org/download/openresty-${OPENRESTY_VER}.tar.gz | tar -zxf - \
  ; cd openresty-${OPENRESTY_VER} \
  ; ./configure --prefix=/opt/openresty \
        --with-luajit \
        --with-threads \
        --with-file-aio \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_auth_request_module \
        --with-http_addition_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_iconv_module \
        --with-http_slice_module \
        --with-http_sub_module \
        --with-http_stub_status_module \
        --with-http_realip_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_realip_module \
        --with-stream_ssl_preread_module \
  ; make \
  ; make install \
  \
  ; ln -sf /dev/stdout /opt/openresty/nginx/logs/access.log \
  ; ln -sf /dev/stderr /opt/openresty/nginx/logs/error.log \
  \
  ; cd ../../ && rm -rf $build_dir \
  ; opm install ledgetech/lua-resty-http \
  ; apk del .build-deps \
  #; mkdir -p /var/run/openresty \
  ; adduser -SDH www-data -G www-data -h /srv \
  ; ln -fs /opt/openresty/nginx/conf /etc/openresty

COPY config /etc/openresty
COPY setup.sh /srv
WORKDIR /srv

VOLUME [ "/srv" ]
EXPOSE 80 443
ENV PREBOOT=
ENV POSTBOOT=
ENV HTPASSWD=
ENV UPLOAD_ROOT=

COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint/init.sh"]

STOPSIGNAL SIGQUIT

