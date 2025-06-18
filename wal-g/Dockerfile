FROM fj0rd/io:common

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        postgresql-client \
        default-mysql-client \
        redis-tools \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  \
  ; ver=$(curl -sSL https://api.github.com/repos/wal-g/wal-g/releases/latest | jq -r '.tag_name') \
  ; os=ubuntu-20.04 \
  ; for db in pg mysql redis mongo; do\
        curl -sSL https://github.com/wal-g/wal-g/releases/download/${ver}/wal-g-${db}-${os}-amd64.tar.gz \
        | tar zxf - wal-g-${db}-${os}-amd64 ;\
        mv wal-g-${db}-${os}-amd64 /usr/local/bin/wal-g-${db} ;\
    done \
  ; 
