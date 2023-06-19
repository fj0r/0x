FROM fj0rd/0x:pyflink

ENV NODE_ROOT=/opt/node
ENV LS_ROOT=/opt/language-server
ENV PATH=${NODE_ROOT}/bin:$PATH
RUN set -eux \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl -sSL https://nodejs.org/node-releases-data.json | jq -r '[.[] | select (has("ltsStart")) | .ltsStart |= (.| strptime("%Y-%m-%d") | mktime) | select (.ltsStart < now)][0].version') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; chown -R root:root ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  ;
