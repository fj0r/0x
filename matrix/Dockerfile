FROM debian:bullseye-slim as nginx
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; cp /etc/apt/sources.list /etc/apt/sources.list.origin \
  #; sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1mirrors.ustc.edu.cn\3main contrib non-free/g' /etc/apt/sources.list \
  \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      nginx ca-certificates \
      curl tzdata sudo jq rsync tcpdump socat htop \
      lsof inetutils-ping iproute2 nftables net-tools \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*




FROM fj0rd/io:rs as build

ENV RUST_BACKTRACE=1
WORKDIR /world
RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends \
        libclang-dev \
  ; git clone --depth=1 https://gitlab.com/famedly/conduit.git \
  ; cd conduit && cargo build --release \
  ; strip -s target/release/conduit




FROM nginx

#COPY --from=build /world/target/release/conduit /usr/local/bin/
RUN set -eux \
  ; curl -sSL 'https://gitlab.com/famedly/conduit/-/jobs/artifacts/master/raw/conduit-x86_64-unknown-linux-musl?job=build:release:cargo:x86_64-unknown-linux-musl' > /usr/local/bin/conduit \
  ; chmod +x /usr/local/bin/conduit

RUN set -eux \
  ; mkdir -p /var/lib/conduit \
  ; chown www-data:www-data -R /var/lib/conduit \
  \
  ; mkdir -p /srv/element \
  ; element_url=$(curl -sSL https://api.github.com/repos/vector-im/element-web/releases -H "Accept: application/vnd.github.v3+json" \
                | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep -v '.asc$' | grep 'tar.gz$') \
  ; curl -sSL ${element_url} | tar zxvf - -C /srv/element --strip-components=1 \
  \
  ; mkdir -p /srv/cinny \
  ; cinny_url=$(curl -sSL https://api.github.com/repos/ajbura/cinny/releases -H "Accept: application/vnd.github.v3+json" \
                | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'tar.gz$') \
  ; curl -sSL ${cinny_url} | tar zxvf - -C /srv/cinny --strip-components=1 \
  ; chown -R 33:33 /srv/*

#USER www-data
WORKDIR /var/lib/conduit
VOLUME /var/lib/conduit

COPY config.json /config.json
COPY conduit.toml /conduit.toml
COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf

ENV RUST_BACKTRACE=1
ENV CONDUIT_CONFIG=/var/lib/conduit/conduit.toml
ENV MATRIX_CLIENT=element
ENTRYPOINT [ "/entrypoint.sh" ]
