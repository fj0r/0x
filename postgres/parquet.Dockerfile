FROM fj0rd/scratch:arrow as arrow
FROM postgres:15
COPY --from=arrow /usr/local /usr/lib/x86_64-linux-gnu

ENV BUILD_DEPS \
    git \
    cmake \
    binutils \
    m4 \
    pkg-config \
    lsb-release \
    libcurl4-openssl-dev \
    libssl-dev \
    libicu-dev \
    uuid-dev \
    build-essential \
    clang \
    libpq-dev \
    python3-dev \
    libkrb5-dev \
    postgresql-server-dev-${PG_MAJOR}

#ENV BUILD_CITUS_DEPS \
#    libicu-dev \
#    liblz4-dev \
#    libpam0g-dev \
#    libreadline-dev \
#    libselinux1-dev \
#    libxslt-dev \
#    libzstd-dev

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
      postgresql-${PG_MAJOR}-mysql-fdw \
      postgresql-${PG_MAJOR}-wal2json \
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
      python3 python3-pip python3-setuptools \
      libcurl4 curl jq ca-certificates uuid \
      ${BUILD_DEPS:-} \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  ; cd $build_dir \
  ; mkdir parquet \
  ; paq_version=$(curl https://api.github.com/repos/pgspider/parquet_s3_fdw/releases/latest | jq -r '.tag_name') \
  ; curl -sSL https://github.com/pgspider/parquet_s3_fdw/archive/refs/tags/${paq_version}.tar.gz | tar zxf - --strip-components=1 -C parquet \
  ; cd parquet \
  ; sed -e 's!\(-std=c++\)11!\117!' -i Makefile \
  ; sh ./install_arrow.sh \
  ; make install USE_PGXS=1 \
  ; apt autoremove libarrow-dev libparquet-dev \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  #    ${BUILD_CITUS_DEPS:-} \
  ; apt-get clean -y && rm -rf /var/lib/apt/lists/*


COPY .psqlrc /root
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN ln -sf usr/local/bin/docker-entrypoint.sh / # backwards compat

ENV PGCONF_PG_JIEBA__HMM_MODEL=
ENV PGCONF_PG_JIEBA__BASE_DICT=
ENV PGCONF_PG_JIEBA__USER_DICT=
ENV PGCONF_SHARED_BUFFERS=2GB
ENV PGCONF_WORK_MEM=4MB
ENV PGCONF_EFFECTIVE_CACHE_SIZE=8GB
ENV PGCONF_EFFECTIVE_IO_CONCURRENCY=200
ENV PGCONF_RANDOM_PAGE_COST=1.1
ENV PGCONF_WAL_LEVEL=logical
ENV PGCONF_MAX_REPLICATION_SLOTS=10
#ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'citus,pg_stat_statements,timescaledb,pg_jieba.so'"
ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'citus,pg_stat_statements,timescaledb,pg_bigm'"
ENV PGCONF_LOG_MIN_DURATION_STATEMENT=1000
