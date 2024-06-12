FROM ghcr.io/fj0r/io as build

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
  ; apt-get install -y --no-install-recommends \
        ca-certificates \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; mkdir /root/assets \
  ; cd /root/assets \
  #\
  #; coredns_url=$(curl --retry 3 -sSL https://api.github.com/repos/coredns/coredns/releases/latest \
  #      | jq -r '.assets[].browser_download_url' | grep 'linux_amd64.tgz$') \
  #; curl --retry 3 -sSL ${coredns_url} | tar zxf - \
  #; chmod +x coredns \
  #; strip -s coredns \
  \
  ; url=$(curl --retry 3 -sSL https://api.github.com/repos/slackhq/nebula/releases/latest \
        | jq -r '.assets[].browser_download_url' | grep linux-amd64) \
  ; curl --retry 3 -sSL ${url} | tar zxf - \
  #; strip -s nebula* \
  ;


FROM ghcr.io/fj0r/io:base
WORKDIR /nebula

COPY --from=build /root/assets /usr/local/bin
COPY config.yaml /nebula/config.yaml.tmpl
EXPOSE 51821/udp
ENV NEBULA_CONFIG=

COPY entrypoint/nebula.sh /entrypoint/
CMD ["srv"]
