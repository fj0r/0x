ARG BASE_IMG=0x:pg15
FROM ${BASE_IMG}

ENV PATH=/opt/ferretdb:${PATH}
RUN set -ex \
  ; ferret_ver=$(curl -sSL https://api.github.com/repos/FerretDB/FerretDB/releases/latest | jq -r '.tag_name') \
  ; ferret_url="https://github.com/FerretDB/FerretDB/releases/download/${ferret_ver}/ferretdb" \
  ; curl -sSL ${ferret_url} -o /usr/local/bin/ferretdb \
  ; chmod +x /usr/local/bin/ferretdb \
  ; mkdir -p /var/lib/ferretdb \
  ; chown postgres:postgres /var/lib/ferretdb \
  ;

# ferretdb --state-dir="/var/lib/ferretdb" --postgresql-url=postgres://${POSTGRES_USER:-postgres}@localhost:5432/${POSTGRES_DB:-postgres}