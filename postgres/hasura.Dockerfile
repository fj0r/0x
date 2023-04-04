ARG HASURA_IMG=hasura/graphql-engine:v2.22.0
ARG BASE_IMG=0x:pg15
FROM ${HASURA_IMG} as hasura
FROM ${BASE_IMG}

RUN set -ex; \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -; \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list; \
    apt-get update; \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18; \
    if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      # Support the old version of the driver too, where possible.
      # v17 is only supported on amd64.
      ACCEPT_EULA=Y apt-get -y install msodbcsql17; \
    fi

COPY --from=hasura /usr/bin/graphql-engine /usr/bin/

# ENTRYPOINT
# HASURA_GRAPHQL_ENABLE_CONSOLE=true graphql-engine --database-url=postgres://${POSTGRES_USER:-postgres}@localhost:5432/${POSTGRES_DB:-postgres} serve
