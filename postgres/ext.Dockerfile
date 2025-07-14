ARG BASEIMAGE=ghcr.io/fj0r/0x:pg_rx
FROM ${BASEIMAGE} AS builder-paradedb
ARG PG_VERSION_MAJOR=17

######################
# paradedb
######################
# RUN set -eux \
#   ; git clone --depth=1 https://github.com/paradedb/paradedb.git /tmp/paradedb \
#   ; cd /tmp/paradedb/pg_search \
#   ; cargo pgrx package --features icu --pg-config "/usr/lib/postgresql/${PG_VERSION_MAJOR}/bin/pg_config" \
#   \
#   ; mkdir -p /out/pg_search/lib/postgresql/${PG_VERSION_MAJOR}/lib \
#   ; cp ../target/release/pg_search-pg${PG_VERSION_MAJOR}/usr/lib/postgresql/${PG_VERSION_MAJOR}/lib/* /out/pg_search/lib/postgresql/${PG_VERSION_MAJOR}/lib \
#   ; mkdir -p /out/pg_search/share/postgresql/${PG_VERSION_MAJOR}/extension \
#   ; cp ../target/release/pg_search-pg${PG_VERSION_MAJOR}/usr/share/postgresql/${PG_VERSION_MAJOR}/extension/* /out/pg_search/share/postgresql/${PG_VERSION_MAJOR}/extension \
#   ; cd /out/pg_search \
#   ; tar zcvf /tmp/paradedb/pg_search.tar.gz * \
#   ;

######################
# pg_duckdb
######################

FROM ${BASEIMAGE} AS builder-pg_duckdb
ARG PG_VERSION_MAJOR=17

WORKDIR /tmp/pg_duckdb
RUN set -eux \
  ; apt update \
  ; apt install -y --no-install-recommends \
    libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev \
    libssl-dev libxml2-utils xsltproc \
    pkg-config libc++-dev libc++abi-dev libglib2.0-dev \
    libtinfo5 libstdc++-12-dev liblz4-dev \
  \
  ; git clone --depth=1 https://github.com/duckdb/pg_duckdb.git . \
  ; git submodule update --init --recursive \
  ; make -j$(nproc) \
  ; DESTDIR=/out make install \
  \
  ; cd /out/usr \
  ; tar zcvf /tmp/pg_duckdb.tar.gz * \
  ;

######################
# pg_jsonschema
######################

FROM ${BASEIMAGE} AS builder-jsonschema
ARG PG_VERSION_MAJOR=17
RUN set -eux \
  ; git clone --depth=1 https://github.com/supabase/pg_jsonschema.git /tmp/pg_jsonschema \
  ; cd /tmp/pg_jsonschema \
  ; pgrx_ver=$(cat Cargo.toml | rg 'pgrx\s*=\s*"=*([0-9\.]+)"' -or '$1') \
  ; cargo install --locked cargo-pgrx --version "${pgrx_ver}" --force \
  ; cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_VERSION_MAJOR}/bin/pg_config" \
  \
  ; mkdir -p /out/pg_jsonschema/lib/postgresql/${PG_VERSION_MAJOR}/lib \
  ; cp target/release/pg_jsonschema-pg${PG_VERSION_MAJOR}/usr/lib/postgresql/${PG_VERSION_MAJOR}/lib/* /out/pg_jsonschema/lib/postgresql/${PG_VERSION_MAJOR}/lib \
  ; mkdir -p /out/pg_jsonschema/share/postgresql/${PG_VERSION_MAJOR}/extension \
  ; cp target/release/pg_jsonschema-pg${PG_VERSION_MAJOR}/usr/share/postgresql/${PG_VERSION_MAJOR}/extension/* /out/pg_jsonschema/share/postgresql/${PG_VERSION_MAJOR}/extension \
  ; cd /out/pg_jsonschema \
  ; tar zcvf /tmp/pg_jsonschema.tar.gz * \
  ;

######################
# pg_graphql
######################
# RUN set -eux \
#   ; git clone --depth=1 https://github.com/supabase/pg_graphql.git /tmp/pg_graphql \
#   ; cd /tmp/pg_graphql \
#   ; rustup update nightly \
#   ; rustup override set nightly \
#   ; pgrx_ver=$(cat Cargo.toml | rg 'pgrx\s*=\s*"=*([0-9\.]+)"' -or '$1') \
#   ; cargo install --locked cargo-pgrx --version "${pgrx_ver}" --force \
#   ; cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_VERSION_MAJOR}/bin/pg_config" \
#   \
#   ; mkdir -p /out/pg_graphql/lib/postgresql/${PG_VERSION_MAJOR}/lib \
#   ; cp target/release/pg_graphql-pg${PG_VERSION_MAJOR}/usr/lib/postgresql/${PG_VERSION_MAJOR}/lib/* /out/pg_graphql/lib/postgresql/${PG_VERSION_MAJOR}/lib \
#   ; mkdir -p /out/pg_graphql/share/postgresql/${PG_VERSION_MAJOR}/extension \
#   ; cp target/release/pg_graphql-pg${PG_VERSION_MAJOR}/usr/share/postgresql/${PG_VERSION_MAJOR}/extension/* /out/pg_graphql/share/postgresql/${PG_VERSION_MAJOR}/extension \
#   ; cd /out/pg_graphql \
#   ; tar zcvf /tmp/pg_graphql.tar.gz * \
#   ;

######################
# pg_vector
######################

FROM ${BASEIMAGE} AS builder-pg_vector
ARG PG_VERSION_MAJOR=17

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
  ; mkdir -p /out/lib/postgresql/${PG_VERSION_MAJOR}/lib \
  ; cp *.so /out/lib/postgresql/${PG_VERSION_MAJOR}/lib \
  ; mkdir -p /out/share/postgresql/${PG_VERSION_MAJOR}/extension \
  ; cp *.control /out/share/postgresql/${PG_VERSION_MAJOR}/extension \
  ; cp sql/*.sql /out/share/postgresql/${PG_VERSION_MAJOR}/extension \
  ; cd /out \
  ; tar zcvf /tmp/pg_vector.tar.gz * \
  ;


#WORKDIR /tmp/pgvectorscale
#RUN set -eux \
#  ; git clone --depth=1 https://github.com/timescale/pgvectorscale.git /tmp/pgvectorscale \
#  ; cd /tmp/pgvectorscale/pgvectorscale \
#  ; pgrx_ver=$(cat Cargo.toml | rg 'pgrx\s*=\s*"=*([0-9\.]+)"' -or '$1') \
#  ; cargo install --locked cargo-pgrx --version "${pgrx_ver}" --force \
#  ; RUSTFLAGS="-C target-feature=+avx2,+fma" \
#    cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_VERSION_MAJOR}/bin/pg_config" \
#  ; mkdir -p /out/lib/postgresql/${PG_VERSION_MAJOR}/lib/ \
#  ; cp target/release/vectorscale-pg${PG_VERSION_MAJOR}/usr/lib/postgresql/${PG_VERSION_MAJOR}/lib/* /out/lib/postgresql/${PG_VERSION_MAJOR}/lib/ \
#  ; mkdir -p /out/share/postgresql/${PG_VERSION_MAJOR}/extension/ \
#  ; cp target/release/vectorscale-pg${PG_VERSION_MAJOR}/usr/share/postgresql/${PG_VERSION_MAJOR}/extension/* /out/share/postgresql/${PG_VERSION_MAJOR}/extension/ \
#  ; cd /out \
#  ; tar zcvf /tmp/pg_vectorscale.tar.gz * \
#  ;


FROM alpine AS filer

RUN mkdir -p /out \
  ;

COPY --from=builder-pg_duckdb /tmp/pg_duckdb.tar.gz /tmp
COPY --from=builder-pg_vector /tmp/pg_vector.tar.gz /tmp
#COPY --from=builder-pg_vector /tmp/pg_vectorscale.tar.gz /tmp

# Copy the ParadeDB extensions from their builder stages
# COPY --from=builder-paradedb /tmp/paradedb/pg_search.tar.gz /tmp
# COPY --from=builder-analytics /tmp/pg_analytics.tar.gz /tmp
COPY --from=builder-jsonschema /tmp/pg_jsonschema.tar.gz /tmp
#COPY --from=builder-paradedb /tmp/pg_graphql.tar.gz /tmp

RUN set -eux \
  ; for x in duckdb vector jsonschema \
  ; do tar zxvf /tmp/pg_${x}.tar.gz -C /out \
  ; done \
  ;
