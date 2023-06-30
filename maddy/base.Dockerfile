FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        locales swaks telnet sqlite3 ssl-cert \
        python3 python3-pip \
  \
  ; sed -i /etc/locale.gen \
    -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
    -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; mkdir /tmp/maddy \
  ; maddy_ver=$(curl -sSL https://api.github.com/repos/foxcpp/maddy/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; maddy_url="https://github.com/foxcpp/maddy/releases/download/v${maddy_ver}/maddy-${maddy_ver}-x86_64-linux-musl.tar.zst" \
  ; curl -sSL ${maddy_url} | zstd -d | tar xf - -C /tmp/maddy --strip-components=2 \
  ; mv /tmp/maddy/maddy /usr/local/bin/ \
  ; rm -rf /tmp/maddy/ \
  ; useradd -mrU -s /sbin/nologin -d /data -c "maddy mail server" maddy \
  \
  ; lego_ver=$(curl -sSL https://api.github.com/repos/go-acme/lego/releases/latest | jq -r '.tag_name') \
  ; lego_url="https://github.com/go-acme/lego/releases/download/${lego_ver}/lego_${lego_ver}_linux_amd64.tar.gz" \
  ; curl -sSL ${lego_url} | tar zxf - -C /usr/local/bin lego \
  ;

WORKDIR /data
CMD ["srv"]

