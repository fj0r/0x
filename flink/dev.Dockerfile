FROM fj0rd/0x:pyflink

ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH
RUN set -eux \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p /opt/language-server \
  ; npm install -g npm@8 \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
        neovim \
  ; npm cache clean -f \
  \
  ; pip3 --no-cache-dir install neovim \
  ;
