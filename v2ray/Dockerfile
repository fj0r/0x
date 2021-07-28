FROM debian:bullseye-slim

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

ARG v2ray_repo=v2fly/v2ray-core
ARG v2ray_files="\
v2ray \
v2ctl \
geoip.dat \
geosite.dat \
"

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates tzdata curl unzip jq \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; mkdir -p /usr/bin/v2ray \
  ; mkdir /var/log/v2ray/ \
  \
  ; v2ray_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${v2ray_repo}/releases | jq -r '.[0].tag_name') \
  ; v2ray_url=https://github.com/${v2ray_repo}/releases/download/${v2ray_version}/v2ray-linux-64.zip \
  ; mkdir -p /tmp/v2ray \
  ; cd /tmp/v2ray \
  ; curl -sSLo v2ray.zip ${v2ray_url} \
  ; unzip v2ray.zip \
  ; mv ${v2ray_files} /usr/bin/v2ray \
  ; cd .. \
  ; rm -rf /tmp/v2ray

ENV PATH /usr/bin/v2ray:$PATH

COPY server.json /etc/v2ray/config.json

###### s6
ARG s6overlay_repo=just-containers/s6-overlay
ARG watchexec_repo=watchexec/watchexec

ARG github_header="Accept: application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos
ARG nginx_repo=nginx/nginx
ARG nchan_repo=slact/nchan

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
    sudo tzdata ca-certificates \
    iproute2 procps curl jq xz-utils \
    $DEV_DEPS \
    $BUILD_DEPS \
  \
  ; NGINX_VER=$(curl -sSL -H "'$github_header'" $github_api/${nginx_repo}/tags | jq -r '.[0].name' | cut -c 9-) \
  ; curl -sSL https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar -zxf - \
  \
  ; mkdir njs \
  ; curl -sSL http://hg.nginx.org/njs/archive/tip.tar.gz | tar -zxf - --strip-component=1 -C njs \
  \
  ; NCHAN_VER=$(curl -sSL -H "'$github_header'" $github_api/${nchan_repo}/tags | jq -r '.[0].name' | cut -c 2-) \
  ; curl -sSL https://github.com/${nchan_repo}/archive/v${NCHAN_VER}.tar.gz | tar -zxf - \
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
        --add-dynamic-module=../nchan-${NCHAN_VER} \
  ; make \
  ; make install \
  ; cd .. && rm -rf nginx-${NGINX_VER} nchan-${NCHAN_VER} njs \
  ; ln -fs /opt/nginx/conf /etc/nginx \
  ; mkdir -p /etc/nginx/conf.d \
  ; echo 'shopt -s cdable_vars' >> /root/.bashrc \
  ; echo 'export or=/etc/nginx' >> /root/.bashrc \
  ; echo 'export logs=/opt/nginx/logs' >> /root/.bashrc \
  \
  ; s6overlay_ver=$(curl -sSL -H "'$github_header'" $github_api/${s6overlay_repo}/releases | jq -r '.[0].tag_name') \
  ; s6overlay_url=https://github.com/${s6overlay_repo}/releases/download/${s6overlay_ver}/s6-overlay-amd64.tar.gz \
  ; curl --fail --silent -L ${s6overlay_url} | tar xzvf - -C / \
  \
  ; watchexec_ver=$(curl -sSL -H "'$github_header'" $github_api/${watchexec_repo}/releases | jq -r '.[0].tag_name' | cut -c 6-) \
  ; watchexec_url=https://github.com/${watchexec_repo}/releases/download/cli-v${watchexec_ver}/watchexec-${watchexec_ver}-x86_64-unknown-linux-musl.tar.xz \
  ; curl -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin watchexec-${watchexec_ver}-x86_64-unknown-linux-musl/watchexec \
  \
  ; apt-get -y remove ${BUILD_DEPS} \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


COPY services.d /etc/services.d
COPY 01-gen-token /etc/cont-init.d
COPY reload-nginx /usr/local/bin
COPY config.ngx /etc/nginx

ENV PATH /usr/bin/v2ray:$PATH
COPY client.json /etc/v2ray/client.json

ENTRYPOINT [ "/init" ]
