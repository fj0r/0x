FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        locales swaks telnet sqlite3 ssl-cert \
  \
  ; sed -i /etc/locale.gen \
    -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
    -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; mkdir /tmpl \
  \
  ; lego_ver=$(curl --retry 3 -sSL https://api.github.com/repos/go-acme/lego/releases/latest | jq -r '.tag_name') \
  ; lego_url="https://github.com/go-acme/lego/releases/download/${lego_ver}/lego_${lego_ver}_linux_amd64.tar.gz" \
  ; curl --retry 3 -sSL ${lego_url} | tar zxf - -C /usr/local/bin lego \
  ;

WORKDIR /data
COPY entrypoint/lego.sh /entrypoint/
COPY tmpl /tmpl
CMD ["srv"]

