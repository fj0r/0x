# vim:set ft=dockerfile:
FROM postgres:14

ENV BUILD_DEPS \
    git \
    cmake \
    m4 \
    python \
    pkg-config \
    lsb-release \
    libcurl4-openssl-dev \
    uuid-dev \
    build-essential \
    libpq-dev \
    python3-dev \
    libkrb5-dev \
    postgresql-server-dev-${PG_MAJOR}

ENV BUILD_CITUS_DEPS \
    libicu-dev \
    liblz4-dev \
    libpam0g-dev \
    libreadline-dev \
    libselinux1-dev \
    libxslt-dev \
    libzstd-dev

#ENV LANG zh_CN.utf8
ENV TIMEZONE=Asia/Shanghai
RUN set -eux \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      postgresql-plpython3-${PG_MAJOR} \
      postgresql-${PG_MAJOR}-wal2json \
      postgresql-${PG_MAJOR}-mysql-fdw \
      postgresql-${PG_MAJOR}-rum \
      postgresql-${PG_MAJOR}-similarity \
      postgresql-${PG_MAJOR}-rational \
      postgresql-${PG_MAJOR}-cron \
      postgresql-${PG_MAJOR}-extra-window-functions \
      postgresql-${PG_MAJOR}-first-last-agg \
      postgresql-${PG_MAJOR}-ip4r \
      postgresql-${PG_MAJOR}-hll \
      postgresql-${PG_MAJOR}-jsquery \
      postgresql-${PG_MAJOR}-pgaudit \
      pgxnclient \
      python3-pip python3-setuptools \
      libcurl4 curl jq ca-certificates \
      uuid mariadb-client \
      ${BUILD_DEPS:-} \
      ${BUILD_CITUS_DEPS:-} \
  ; pip3 --no-cache-dir install \
      pgcli pygments \
      numpy httpx pyyaml deepmerge cachetools \
      pydantic more-itertools fn.py PyParsing \
  ; pgxn install madlib \
  #; pgxn load madlib \
  \
  #; curl -sSL https://install.citusdata.com/community/deb.sh | bash \
  #; apt-get install -y --no-install-recommends postgresql-13-citus-10.0 \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; git clone https://github.com/jaiminpan/pg_jieba \
  ; cd pg_jieba \
  ; git submodule update --init --recursive  \
  ; mkdir build \
  ; cd build \
  ; cmake .. \
      -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/${PG_MAJOR}/server \
  ; make \
  ; make install \
  \
  ; cd $build_dir \
  ; http_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/pramsey/pgsql-http/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  ; curl -sSL https://github.com/pramsey/pgsql-http/archive/refs/tags/v${http_version}.tar.gz | tar zxf - \
  ; cd pgsql-http-${http_version} \
  ; make && make install \
  \
  ; cd $build_dir \
  ; citus_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/citusdata/citus/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  ; curl -sSL https://github.com/citusdata/citus/archive/refs/tags/v${citus_version}.tar.gz | tar zxf - \
  ; cd citus-${citus_version} \
  ; ./configure \
  ; make && make install \
  \
  #; cd $build_dir \
  #; anonymizer_version=$(curl -sSL "https://gitlab.com/api/v4/projects/7709206/releases" | jq -r '.[0].name') \
  #; curl -sSL https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/${anonymizer_version}/postgresql_anonymizer-${anonymizer_version}.tar.gz \
  #  | tar zxf - \
  #; cd postgresql_anonymizer-${anonymizer_version} \
  #; make extension \
  #; make install \
  #\
  \
  #; cd $build_dir \
  #; zson_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/postgrespro/zson/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl -sSL https://github.com/postgrespro/zson/archive/refs/tags/v${zson_version}.tar.gz | tar zxf - \
  #; cd zson-${zson_version} \
  #; make && make install \
  #\
  #### via apt
  # ; cd $build_dir \
  # ; rum_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/postgrespro/rum/releases | jq -r '.[0].tag_name') \
  # ; curl -sSL https://github.com/postgrespro/rum/archive/${rum_version}.tar.gz | tar zxf - \
  # ; cd rum-${rum_version} \
  # ; make USE_PGXS=1 \
  # ; make USE_PGXS=1 install \
  \
  #; cd $build_dir \
  #; git clone https://github.com/adjust/clickhouse_fdw.git \
  #; cd clickhouse_fdw \
  #; mkdir build && cd build \
  #; cmake .. \
  #; make && make install \
  #\
  ; cd $build_dir \
  ; git clone https://github.com/timescale/timescaledb.git \
  ; cd timescaledb \
  ; git checkout master \
  ; ./bootstrap \
  ; cd build && make \
  ; make install \
  #\
  #; curl -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash \
  #; apt-get install -y --no-install-recommends timescaledb-2-postgresql-${PG_MAJOR} \
  \
  ; rm -rf $build_dir \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} ${BUILD_CITUS_DEPS:-}\
  ; apt-get clean -y && rm -rf /var/lib/apt/lists/*


COPY .psqlrc /root
COPY pgcli_config /root/.config/pgcli/config
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN ln -sf usr/local/bin/docker-entrypoint.sh / # backwards compat

ENV PGCONF_PG_JIEBA__HMM_MODEL=
ENV PGCONF_PG_JIEBA__BASE_DICT=
ENV PGCONF_PG_JIEBA__USER_DICT=
ENV PGCONF_SHARED_BUFFERS=2GB
ENV PGCONF_WORK_MEM=32MB
ENV PGCONF_EFFECTIVE_CACHE_SIZE=8GB
ENV PGCONF_EFFECTIVE_IO_CONCURRENCY=200
ENV PGCONF_RANDOM_PAGE_COST=1.1
ENV PGCONF_WAL_LEVEL=logical
ENV PGCONF_MAX_REPLICATION_SLOTS=10
ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'citus,pg_stat_statements,timescaledb,pg_jieba.so'"

