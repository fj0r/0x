ARG PG_VERSION_MAJOR=16
ARG BASEIMAGE=ghcr.io/fj0r/0x:pg_ext

FROM ${BASEIMAGE} AS pg_ext
FROM readysettech/readyset:latest AS readyset

FROM postgres:${PG_VERSION_MAJOR}

COPY --from=readyset /usr/local/bin/readyset /usr/local/bin

COPY --from=pg_ext /out/lib/postgresql/${PG_MAJOR}/lib/* /usr/lib/postgresql/${PG_MAJOR}/lib
COPY --from=pg_ext /out/share/postgresql/${PG_MAJOR}/extension/* /usr/share/postgresql/${PG_MAJOR}/extension


ARG PIP_FLAGS="--break-system-packages"

ENV BUILD_DEPS \
    git \
    cmake \
    binutils \
    m4 \
    pkg-config \
    lsb-release \
    libcurl4-openssl-dev \
    libicu-dev \
    uuid-dev \
    build-essential \
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
      postgresql-${PG_MAJOR}-repack \
      postgresql-${PG_MAJOR}-wal2json \
      postgresql-${PG_MAJOR}-rum \
      #postgresql-${PG_MAJOR}-similarity \
      postgresql-${PG_MAJOR}-rational \
      postgresql-${PG_MAJOR}-cron \
      postgresql-${PG_MAJOR}-extra-window-functions \
      postgresql-${PG_MAJOR}-first-last-agg \
      postgresql-${PG_MAJOR}-ip4r \
      postgresql-${PG_MAJOR}-hll \
      postgresql-${PG_MAJOR}-jsquery \
      postgresql-${PG_MAJOR}-pgaudit \
      pgxnclient \
      procps htop net-tools unzip tree \
      python3 python3-pip python3-setuptools \
      libcurl4 curl jq ca-certificates uuid \
      ${BUILD_DEPS:-} \
  \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
      pydantic PyParsing \
      boltons decorator \
      numpy httpx pyyaml \
      pyiceberg[s3fs,pyarrow,pandas] \
  \
  ; dust_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${dust_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/dust' \
  \
  ; curl --retry 3 -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash \
  ; timescale_pkg=$(apt search timescaledb-[0-9]+-postgresql-${PG_MAJOR} 2>&1 | grep '/' | tail -n 1 | awk -F'/' '{print $1}') \
  \
  ; curl --retry 3 -fsSL https://install.citusdata.com/community/deb.sh | bash \
  ; citus_pkg=$(apt search postgresql-${PG_MAJOR}-citus 2>&1 | grep '/' | grep -v dbgsym | tail -n 1 | awk -F'/' '{print $1}') \
  \
  ; apt-get install -y --no-install-recommends ${timescale_pkg} ${citus_pkg} \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  #; cd $build_dir \
  #; mkdir pgvector \
  #; cd pgvector \
  #; pgvector_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/pgvector/pgvector/tags | jq -r '.[0].name') \
  #; curl --retry 3 -fsSL https://github.com/pgvector/pgvector/archive/refs/tags/${pgvector_ver}.tar.gz \
  #  | tar zxf - -C . --strip-components=1 \
  #; make \
  #; make install \
  \
  #; cd $build_dir \
  #; duckdb_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/duckdb/duckdb/releases/latest | jq -r '.tag_name') \
  #; curl --retry 3 -fsSLO https://github.com/duckdb/duckdb/releases/download/${duckdb_ver}/libduckdb-linux-amd64.zip \
  #; unzip -d . libduckdb-linux-amd64.zip \
  #; cp libduckdb.so $(pg_config --libdir)  \
  #; git clone --depth=1 https://github.com/alitrack/duckdb_fdw \
  #; cd duckdb_fdw \
  #; make USE_PGXS=1 \
  #; make install USE_PGXS=1 \
  \
  #; cd $build_dir \
  #; git clone --depth=1 https://github.com/adjust/clickhouse_fdw.git \
  #; cd clickhouse_fdw \
  #; mkdir build \
  #; cd build \
  #; cmake .. \
  #; make \
  #; make install \
  \
  #; cd $build_dir \
  #; git clone --depth=1 https://github.com/jaiminpan/pg_jieba \
  #; cd pg_jieba \
  #; git submodule update --init --recursive  \
  #; mkdir build \
  #; cd build \
  #; cmake .. -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/${PG_MAJOR}/server \
  #; make \
  #; make install \
  \
  #; cd $build_dir \
  #; git clone --depth=1 https://github.com/timescale/timescaledb.git \
  #; cd timescaledb \
  #; git checkout main \
  #; ./bootstrap \
  #; cd build \
  #; make \
  #; make install \
  #\
  #; cd $build_dir \
  #; git clone --depth=1 https://github.com/sraoss/pg_ivm.git \
  #; cd pg_ivm \
  #; make install \
  #\
  #; cd $build_dir \
  #; citus_version=$(curl --retry 3 -fsSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/citusdata/citus/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl --retry 3 -fsSL https://github.com/citusdata/citus/archive/refs/tags/v${citus_version}.tar.gz | tar zxf - \
  #; cd citus-${citus_version} \
  #; ./configure \
  #; make \
  #; make install \
  \
  #; cd $build_dir \
  #; anonymizer_version=$(curl --retry 3 -fsSL "https://gitlab.com/api/v4/projects/7709206/releases" | jq -r '.[0].name') \
  #; curl --retry 3 -fsSL https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/${anonymizer_version}/postgresql_anonymizer-${anonymizer_version}.tar.gz \
  #  | tar zxf - \
  #; cd postgresql_anonymizer-${anonymizer_version} \
  #; make extension \
  #; make install \
  \
  #; cd $build_dir \
  #; zson_version=$(curl --retry 3 -fsSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/postgrespro/zson/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl --retry 3 -fsSL https://github.com/postgrespro/zson/archive/refs/tags/v${zson_version}.tar.gz | tar zxf - \
  #; cd zson-${zson_version} \
  #; make \
  #; make install \
  \
  ; rm -rf $build_dir \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  #    ${BUILD_CITUS_DEPS:-} \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;


COPY .psqlrc /root
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN ln -sf usr/local/bin/docker-entrypoint.sh / # backwards compat

#ENV PGCONF_PG_JIEBA__HMM_MODEL=
#ENV PGCONF_PG_JIEBA__BASE_DICT=
#ENV PGCONF_PG_JIEBA__USER_DICT=
ENV PGCONF_EFFECTIVE_CACHE_SIZE=8GB
ENV PGCONF_EFFECTIVE_IO_CONCURRENCY=200
ENV PGCONF_RANDOM_PAGE_COST=1.1
ENV PGCONF_WAL_LEVEL=logical
ENV PGCONF_MAX_REPLICATION_SLOTS=10
# ,citus,timescaledb
ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'pg_stat_statements,pg_cron,pg_search'"
ENV PGCONF_LOG_MIN_DURATION_STATEMENT=1000
ENV PARADEDB_TELEMETRY=false
ENV READYSET_MEMORY_LIMIT=

ENV POSTGRES_USER=foo
ENV POSTGRES_DB=foo
ENV POSTGRES_PASSWORD=foo
