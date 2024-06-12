######################
# paradedb
######################
FROM ghcr.io/fj0r/0x:pg_rx as builder-paradedb

WORKDIR /tmp/paradedb

RUN set -eux \
  ; ver=$(curl --retry 3 -sSL https://api.github.com/repos/paradedb/paradedb/tags | jq -r '.[0].name') \
  ; curl --retry 3 -sSL https://github.com/paradedb/paradedb/archive/refs/tags/${ver}.tar.gz \
  | tar zxf - -C . --strip-components=1

RUN set -eux \
  ; cd /tmp/paradedb/pg_lakehouse \
  ; cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
  \
  ; mkdir -p /out/pg_lakehouse/lib/postgresql/${PG_MAJOR}/lib \
  ; cp ../target/release/pg_lakehouse-pg${PG_MAJOR}/usr/lib/postgresql/${PG_MAJOR}/lib/* /out/pg_lakehouse/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/pg_lakehouse/share/postgresql/${PG_MAJOR}/extension \
  ; cp ../target/release/pg_lakehouse-pg${PG_MAJOR}/usr/share/postgresql/${PG_MAJOR}/extension/* /out/pg_lakehouse/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out/pg_lakehouse \
  ; tar zcvf /tmp/paradedb/pg_lakehouse.tar.gz *

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


######################
# pg_jsonschema
######################

RUN set -eux \
  ; mkdir -p /tmp/pg_jsonschema \
  ; cd /tmp/pg_jsonschema \
  \
  ; ver=$(curl --retry 3 -sSL https://api.github.com/repos/supabase/pg_jsonschema/releases | jq -r '.[0].name') \
  ; curl --retry 3 -sSL https://github.com/supabase/pg_jsonschema/archive/refs/tags/${ver}.tar.gz \
  | tar zxf - -C . --strip-components=1 \
  ; cargo pgrx package --pg-config "/usr/lib/postgresql/${PG_MAJOR}/bin/pg_config" \
  \
  ; mkdir -p /out/pg_jsonschema/lib/postgresql/${PG_MAJOR}/lib \
  ; cp target/release/pg_jsonschema-pg${PG_MAJOR}/usr/lib/postgresql/${PG_MAJOR}/lib/* /out/pg_jsonschema/lib/postgresql/${PG_MAJOR}/lib \
  ; mkdir -p /out/pg_jsonschema/share/postgresql/${PG_MAJOR}/extension \
  ; cp target/release/pg_jsonschema-pg${PG_MAJOR}/usr/share/postgresql/${PG_MAJOR}/extension/* /out/pg_jsonschema/share/postgresql/${PG_MAJOR}/extension \
  ; cd /out/pg_jsonschema \
  ; tar zcvf /tmp/pg_jsonschema.tar.gz *

######################
# pg_graphql
######################
RUN set -eux \
  ; git clone --depth=1 https://github.com/supabase/pg_graphql.git /tmp/pg_graphql \
  ; cd /tmp/pg_graphql \
  ; rustup update nightly \
  ; rustup override set nightly \
  ; pgrx_ver=$(cat Cargo.toml | rg 'pgrx\s*=\s*"=*([0-9\.]+)"' -or '$1') \
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

FROM ghcr.io/fj0r/0x:pg_rx as builder-pg_vector

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

FROM ghcr.io/fj0r/0x:pg_rx as builder-pg_cron

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
COPY --from=builder-paradedb /tmp/paradedb/pg_lakehouse.tar.gz /tmp
COPY --from=builder-paradedb /tmp/paradedb/pg_search.tar.gz /tmp
COPY --from=builder-paradedb /tmp/pg_jsonschema.tar.gz /tmp
COPY --from=builder-paradedb /tmp/pg_graphql.tar.gz /tmp

RUN set -eux \
  ; for x in vector cron lakehouse search jsonschema graphql \
  ; do tar zxvf /tmp/pg_${x}.tar.gz -C /out \
  ; done
