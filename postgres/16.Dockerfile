ARG PG_VERSION_MAJOR=16
######################
# pg_cat
######################
FROM fj0rd/0x:pgrx as builder-pgcat

RUN set -eux \
  ; git clone --depth=1 https://github.com/postgresml/pgcat.git /tmp/pgcat \
  ; cd /tmp/pgcat \
  ; cargo build --release

######################
# paradedb
######################
FROM fj0rd/0x:pgrx as builder-paradedb
WORKDIR /tmp/paradedb

RUN set -eux \
  ; ver=$(curl --retry 3 -sSL https://api.github.com/repos/paradedb/paradedb/tags | jq -r '.[0].name') \
  ; curl --retry 3 -sSL https://github.com/paradedb/paradedb/archive/refs/tags/${ver}.tar.gz \
    | tar zxf - -C . --strip-components=1

RUN set -eux \
  ; cd /tmp/paradedb/pg_sparse \
  ; echo "trusted = true" >> svector.control \
  ; make clean -j \
  ; make USE_PGXS=1 OPTFLAGS="" -j \
  \
  ; mkdir -p /out/pg_sparse/lib/postgresql/${PG_MAJOR}/lib \
  ; cp *.so /out/pg_sparse/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/pg_sparse/share/postgresql/${PG_MAJOR}/extension \
  ; cp *.control /out/pg_sparse/share/postgresql/${PG_MAJOR}/extension \
  ; cp sql/*.sql /out/pg_sparse/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out/pg_sparse \
  ; tar zcvf /tmp/paradedb/pg_sparse.tar.gz *

RUN set -eux \
  ; cd /tmp/paradedb/pg_search \
  ; cargo pgrx package --features icu --pg-config "/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
  \
  ; mkdir -p /out/pg_search/lib/postgresql/${PG_MAJOR}/lib \
  ; cp ../target/release/pg_search-pg${PG_MAJOR}/usr/lib/postgresql/${PG_MAJOR}/lib/* /out/pg_search/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/pg_search/share/postgresql/${PG_MAJOR}/extension \
  ; cp ../target/release/pg_search-pg${PG_MAJOR}/usr/share/postgresql/${PG_MAJOR}/extension/* /out/pg_search/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out/pg_search \
  ; tar zcvf /tmp/paradedb/pg_search.tar.gz *

# Note: We require Rust nightly to build pg_analytics with SIMD
RUN set -eux \
  ; cd /tmp/paradedb/pg_analytics \
  ; rustup update nightly \
  ; rustup override set nightly \
  ; cargo install --locked cargo-pgrx --version "${PGRX_VERSION}" --force \
  ; cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
  \
  ; mkdir -p /out/pg_analytics/lib/postgresql/${PG_MAJOR}/lib \
  ; cp ../target/release/pg_analytics-pg${PG_MAJOR}/usr/lib/postgresql/${PG_MAJOR}/lib/* /out/pg_analytics/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/pg_analytics/share/postgresql/${PG_MAJOR}/extension \
  ; cp ../target/release/pg_analytics-pg${PG_MAJOR}/usr/share/postgresql/${PG_MAJOR}/extension/* /out/pg_analytics/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out/pg_analytics \
  ; tar zcvf /tmp/paradedb/pg_analytics.tar.gz *

######################
# pg_graphql
######################
RUN set -eux \
  ; git clone --depth=1 https://github.com/supabase/pg_graphql.git /tmp/pg_graphql \
  ; cd /tmp/pg_graphql \
  ; pgrx_ver=$(cat Cargo.toml | rg 'pgrx\s*=\s*"=*([0-9\.]+)"' -or '$1') \
  ; rustup override set nightly \
  ; cargo install --locked cargo-pgrx --version "${pgrx_ver}" --force \
  ; cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
  \
  ; mkdir -p /out/pg_graphql/lib/postgresql/${PG_MAJOR}/lib \
  ; cp target/release/pg_graphql-pg${PG_MAJOR}/usr/lib/postgresql/${PG_MAJOR}/lib/* /out/pg_graphql/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/pg_graphql/share/postgresql/${PG_MAJOR}/extension \
  ; cp target/release/pg_graphql-pg${PG_MAJOR}/usr/share/postgresql/${PG_MAJOR}/extension/* /out/pg_graphql/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out/pg_graphql \
  ; tar zcvf /tmp/pg_graphql.tar.gz *

######################
# pgvector
######################

FROM fj0rd/0x:pgrx as builder-pg_vector

WORKDIR /tmp/pg_vector
RUN set -eux \
  ; ver=$(curl --retry 3 -sSL https://api.github.com/repos/pgvector/pgvector/tags | jq -r '.[0].name') \
  ; curl --retry 3 -sSL https://github.com/pgvector/pgvector/archive/refs/tags/${ver}.tar.gz \
    | tar zxf - -C . --strip-components=1 \
  ; export PG_CFLAGS="-Wall -Wextra -Werror -Wno-unused-parameter -Wno-sign-compare" \
  ; echo "trusted = true" >> vector.control \
  ; make clean -j \
  ; make USE_PGXS=1 OPTFLAGS="" -j \
  \
  ; mkdir -p /out/lib/postgresql/${PG_MAJOR}/lib \
  ; cp *.so /out/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/share/postgresql/${PG_MAJOR}/extension \
  ; cp *.control /out/share/postgresql/${PG_MAJOR}/extension \
  ; cp sql/*.sql /out/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out \
  ; tar zcvf /tmp/pg_vector.tar.gz *

######################
# pg_cron
######################

FROM fj0rd/0x:pgrx as builder-pg_cron

WORKDIR /tmp/pg_cron
RUN set -eux \
  ; ver=$(curl --retry 3 -sSL https://api.github.com/repos/citusdata/pg_cron/tags | jq -r '.[0].name') \
  ; curl --retry 3 -sSL https://github.com/citusdata/pg_cron/archive/refs/tags/${ver}.tar.gz \
    | tar zxf - -C . --strip-components=1 \
  ; echo "trusted = true" >> pg_cron.control \
  ; make clean -j \
  ; make USE_PGXS=1 -j \
  \
  ; mkdir -p /out/lib/postgresql/${PG_MAJOR}/lib \
  ; cp *.so /out/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/share/postgresql/${PG_MAJOR}/extension \
  ; cp *.control /out/share/postgresql/${PG_MAJOR}/extension \
  ; cp sql/*.sql /out/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out \
  ; tar zcvf /tmp/pg_cron.tar.gz *

FROM alpine as filer

RUN mkdir -p /out

COPY --from=builder-pg_vector /tmp/pg_vector.tar.gz /tmp
COPY --from=builder-pg_cron /tmp/pg_cron.tar.gz /tmp

# Copy the ParadeDB extensions from their builder stages
COPY --from=builder-paradedb /tmp/paradedb/pg_sparse.tar.gz /tmp
COPY --from=builder-paradedb /tmp/paradedb/pg_search.tar.gz /tmp
COPY --from=builder-paradedb /tmp/paradedb/pg_analytics.tar.gz /tmp
COPY --from=builder-paradedb /tmp/pg_graphql.tar.gz /tmp

RUN set -eux \
  ; for x in vector cron sparse search analytics graphql \
  ; do tar zxvf /tmp/pg_${x}.tar.gz -C /out \
  ; done


FROM postgres:${PG_VERSION_MAJOR}

COPY --from=builder-pgcat /tmp/pgcat/target/release/pgcat /usr/bin/pgcat
COPY --from=builder-pgcat /tmp/pgcat/pgcat.toml /etc/pgcat/pgcat.toml

COPY --from=filer /out/lib/postgresql/${PG_MAJOR}/lib/* /usr/lib/postgresql/${PG_MAJOR}/lib
COPY --from=filer /out/share/postgresql/${PG_MAJOR}/extension/* /usr/share/postgresql/${PG_MAJOR}/extension


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
      procps htop net-tools \
      python3 python3-pip python3-setuptools \
      libcurl4 curl jq ca-certificates uuid \
      ${BUILD_DEPS:-} \
  \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
      numpy httpx pyyaml deepmerge cachetools \
      pydantic more-itertools fn.py PyParsing \
  \
  ; curl --retry 3 -s https://packagecloud.io/install/repositories/timescale/timescaledb/script.deb.sh | bash \
  ; timescale_pkg=$(apt search timescaledb-[0-9]+-postgresql-${PG_MAJOR} 2>&1 | grep '/' | tail -n 1 | awk -F'/' '{print $1}') \
  \
  ; curl --retry 3 -sSL https://install.citusdata.com/community/deb.sh | bash \
  ; citus_pkg=$(apt search postgresql-${PG_MAJOR}-citus 2>&1 | grep '/' | grep -v dbgsym | tail -n 1 | awk -F'/' '{print $1}') \
  \
  ; apt-get install -y --no-install-recommends ${timescale_pkg} ${citus_pkg} \
  \
  ; build_dir=/root/build \
  ; mkdir -p $build_dir \
  \
  #; cd $build_dir \
  #; mkdir pgvector && cd pgvector \
  #; pgvector_ver=$(curl --retry 3 -sSL https://api.github.com/repos/pgvector/pgvector/tags | jq -r '.[0].name') \
  #; curl --retry 3 -sSL https://github.com/pgvector/pgvector/archive/refs/tags/${pgvector_ver}.tar.gz \
  #  | tar zxf - -C . --strip-components=1 \
  #; make && make install \
  \
  ; cd $build_dir \
  ; git clone --depth=1 https://github.com/adjust/clickhouse_fdw.git \
  ; cd clickhouse_fdw \
  ; mkdir build && cd build \
  ; cmake .. \
  ; make && make install \
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
  #; cd build && make \
  #; make install \
  #\
  #; cd $build_dir \
  #; git clone --depth=1 https://github.com/sraoss/pg_ivm.git \
  #; cd pg_ivm \
  #; make install \
  #\
  #; cd $build_dir \
  #; citus_version=$(curl --retry 3 -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/citusdata/citus/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl --retry 3 -sSL https://github.com/citusdata/citus/archive/refs/tags/v${citus_version}.tar.gz | tar zxf - \
  #; cd citus-${citus_version} \
  #; ./configure \
  #; make && make install \
  \
  #; cd $build_dir \
  #; anonymizer_version=$(curl --retry 3 -sSL "https://gitlab.com/api/v4/projects/7709206/releases" | jq -r '.[0].name') \
  #; curl --retry 3 -sSL https://gitlab.com/dalibo/postgresql_anonymizer/-/archive/${anonymizer_version}/postgresql_anonymizer-${anonymizer_version}.tar.gz \
  #  | tar zxf - \
  #; cd postgresql_anonymizer-${anonymizer_version} \
  #; make extension \
  #; make install \
  \
  #; cd $build_dir \
  #; zson_version=$(curl --retry 3 -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/postgrespro/zson/releases | jq -r '.[0].tag_name' | cut -c 2-) \
  #; curl --retry 3 -sSL https://github.com/postgrespro/zson/archive/refs/tags/v${zson_version}.tar.gz | tar zxf - \
  #; cd zson-${zson_version} \
  #; make && make install \
  \
  ; rm -rf $build_dir \
  \
  ; ferret_ver=$(curl --retry 3 -sSL https://api.github.com/repos/FerretDB/FerretDB/releases/latest | jq -r '.tag_name') \
  ; ferret_url="https://github.com/FerretDB/FerretDB/releases/download/${ferret_ver}/ferretdb" \
  ; curl --retry 3 -sSL ${ferret_url} -o /usr/local/bin/ferretdb \
  ; chmod +x /usr/local/bin/ferretdb \
  \
  ; mkdir -p /opt/pg_flame \
  ; curl --retry 3 -sSL https://github.com/fj0r/pg_flame/releases/latest/download/pg_flame.tar.zst \
    | zstd -d | tar -xf - -C /opt/pg_flame \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  #    ${BUILD_CITUS_DEPS:-} \
  ; apt-get clean -y && rm -rf /var/lib/apt/lists/*


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
ENV PGCONF_SHARED_PRELOAD_LIBRARIES="'citus,pg_stat_statements,pg_cron,pg_search,pg_analytics,timescaledb'"
ENV PGCONF_LOG_MIN_DURATION_STATEMENT=1000
ENV PARADEDB_TELEMETRY=false
