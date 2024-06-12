ARG BASEIMAGE=ghcr.io/fj0r/0x:pg
FROM ${BASEIMAGE}

# https://github.com/postgis/docker-postgis/blob/master/13-3.1/Dockerfile
ENV POSTGIS_MAJOR 3

RUN apt-get update \
      && apt-cache showpkg postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts \
           postgresql-$PG_MAJOR-pgrouting \
           postgresql-$PG_MAJOR-pgrouting-scripts \
           osm2pgsql \
           osm2pgrouting \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
COPY ./update-postgis.sh /usr/local/bin
