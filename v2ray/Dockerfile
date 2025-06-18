FROM fj0rd/io:base

ARG v2ray_files="\
v2ray \
geoip.dat \
geosite.dat \
"

RUN set -eux \
  \
  ; mkdir -p /usr/bin/v2ray \
  ; mkdir /var/log/v2ray/ \
  \
  ; v2ray_url=$(curl --retry 3 -sSL https://api.github.com/repos/v2fly/v2ray-core/releases -H 'Accept: application/vnd.github.v3+json' \
              | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' \
              | grep -v dgst | grep linux-64) \
  ; mkdir -p /tmp/v2ray \
  ; cd /tmp/v2ray \
  ; curl --retry 3 -sSLo v2ray.zip ${v2ray_url} \
  ; unzip v2ray.zip \
  ; mv ${v2ray_files} /usr/bin/v2ray \
  ; cd .. \
  ; rm -rf /tmp/v2ray

ENV PATH /usr/bin/v2ray:$PATH

COPY server.json /etc/v2ray/config.json

ARG github_header='Accept: application/vnd.github.v3+json'
ARG github_api=https://api.github.com/repos
ARG nginx_repo=nginx/nginx

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV DEV_DEPS \
        apache2-utils \
        libpcre3-dev libssl-dev \
        zlib1g-dev

ENV BUILD_DEPS software-properties-common build-essential

ENV PATH=/opt/nginx/sbin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
    $DEV_DEPS \
    $BUILD_DEPS \
  \
  ; NGINX_VER=$(curl --retry 3 -sSL $github_api/${nginx_repo}/tags -H $github_header | jq -r '.[0].name' | cut -c 9-) \
  ; curl --retry 3 -sSL https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -zxf - \
  \
  ; mkdir njs \
  ; curl --retry 3 -sSL http://hg.nginx.org/njs/archive/tip.tar.gz | tar -zxf - --strip-component=1 -C njs \
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
  ; make \
  ; make install \
  ; cd .. \
  ; rm -rf nginx-${NGINX_VER} njs \
  ; ln -fs /opt/nginx/conf /etc/nginx \
  ; mkdir -p /etc/nginx/conf.d \
  ; echo 'shopt -s cdable_vars' >> /root/.bashrc \
  ; echo 'export or=/etc/nginx' >> /root/.bashrc \
  ; echo 'export logs=/opt/nginx/logs' >> /root/.bashrc \
  \
  ; watchexec_url=$(curl --retry 3 -sSL https://api.github.com/repos/watchexec/watchexec/releases -H 'Accept: application/vnd.github.v3+json' \
                  | jq -r '[.[]|select(.prerelease==false and (.tag_name|startswith("cli")))][0].assets[].browser_download_url' | grep 'x86_64-unknown-linux-musl.tar') \
  ; curl --retry 3 -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/watchexec' \
  \
  ; apt-get remove -y ${BUILD_DEPS} \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;


COPY services.d /etc/services.d
COPY 01-gen-token /etc/cont-init.d
COPY reload-nginx /usr/local/bin
COPY config.ngx /etc/nginx

ENV PATH /usr/bin/v2ray:$PATH
COPY client.json /etc/v2ray/client.json

ENTRYPOINT [ "/init" ]
