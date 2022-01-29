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




FROM fj0rd/io:go AS dendrite

WORKDIR /build

RUN set -eux \
  ; dendrite_url=$(curl -sSL https://api.github.com/repos/matrix-org/dendrite/releases -H "Accept: application/vnd.github.v3+json" \
                 | jq -r '[.[]|select(.prerelease == false)][0].tarball_url') \
  ; curl -sSL ${dendrite_url} | tar zxf - --strip-components=1 \
  ; mkdir -p bin \
  ; go build -trimpath -o bin/ ./cmd/dendrite-monolith-server \
  ; go build -trimpath -o bin/ ./cmd/goose \
  ; go build -trimpath -o bin/ ./cmd/create-account \
  ; go build -trimpath -o bin/ ./cmd/generate-keys \
  ; yq_url=$(curl -sSL https://api.github.com/repos/mikefarah/yq/releases -H 'Accept: application/vnd.github.v3+json' \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tar') \
  ; curl -sSL ${yq_url} | tar zxf - && mv yq_linux_amd64 bin/yq




FROM nginx

COPY --from=dendrite /build/bin/* /usr/bin/

VOLUME /etc/dendrite
WORKDIR /etc/dendrite

RUN set -eux \
  ; element_url=$(curl -sSL https://api.github.com/repos/vector-im/element-web/releases -H "Accept: application/vnd.github.v3+json" \
                | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep -v '.asc$' | grep 'tar.gz$') \
  ; curl -sSL ${element_url} | tar zxvf - -C /srv --strip-components=1


COPY config.json /config.json
COPY dendrite.yaml /etc/dendrite.yaml
COPY entrypoint.sh /entrypoint.sh
COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT [ "/entrypoint.sh" ]
