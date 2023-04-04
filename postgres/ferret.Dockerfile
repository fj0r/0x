ARG BASE_IMG=0x:pg15
FROM ${BASE_IMG}

RUN set -ex \
  ; ferret_ver=$(curl -sSL https://api.github.com/repos/FerretDB/FerretDB/releases/latest | jq -r '.tag_name') \
  ; ferret_url="https://github.com/FerretDB/FerretDB/releases/download/${ferret_ver}/ferretdb"
