ARG BASEIMAGE=fj0rd/io:base
#FROM fj0rd/scratch:goofys as goofys
FROM ${BASEIMAGE}
#COPY --from=goofys / /

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV DEV_DEPS \
        libpcre3-dev libssl-dev \
        zlib1g-dev

ENV BUILD_DEPS lsb-release software-properties-common build-essential gnupg binutils

ENV PATH=/opt/openresty/bin:$PATH
ENV XDG_CONFIG_HOME=/etc

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    $DEV_DEPS $BUILD_DEPS openssl \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; mkdir nchan \
  ; NCHAN_VER=$(curl -sSL https://api.github.com/repos/slact/nchan/tags -H 'Accept: application/vnd.github.v3+json' | jq -r '.[0].name' | cut -c 2-) \
  ; curl -sSL https://github.com/slact/nchan/archive/v${NCHAN_VER}.tar.gz | tar -zxf - -C nchan --strip-components=1 \
  \
  ; cd $build_dir \
  ; OPENRESTY_VER=$(curl -sSL https://api.github.com/repos/openresty/openresty/tags | jq -r '.[0].name' | cut -c 2-) \
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
        #--with-http_postgres_module \
        --add-dynamic-module=../nchan \
        --http-log-path=/var/log/openresty/access.log \
        --error-log-path=/var/log/openresty/error.log \
  ; make \
  ; make install \
  \
  ; cd ../../ && rm -rf $build_dir \
  ; opm install ledgetech/lua-resty-http \
  #; opm install SkyLothar/lua-resty-jwt \
  ; opm install zmartzone/lua-resty-openidc \
  #; opm install duhoobo/lua-resty-smtp \
  ; ln -fs /opt/openresty/nginx/conf /etc/openresty \
  ; echo 'shopt -s cdable_vars' >> /root/.bashrc \
  \
  ; apt-get remove -y ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY config /etc/openresty
WORKDIR /srv
COPY entrypoint/openresty.sh /entrypoint/
CMD ["srv"]

VOLUME [ "/srv" ]
EXPOSE 80 443
ENV WEB_ROOT=
ENV HTPASSWD=
ENV UPLOAD_ROOT=


ENV WEB_ROOT=
ENV INSPECT_REQUEST=0
