ARG BASEIMAGE=fj0rd/0x:pg
FROM ${BASEIMAGE}

ENV LS_ROOT=/opt/language-server
ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH

RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends git ripgrep gnupg2 build-essential \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl --retry 3 -sSL https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts != false)][0].version') \
  ; curl --retry 3 -sSL https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        pyright \
        yaml-language-server \
  ; chown root:root -R ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  \
  ; nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" \
  ; curl --retry 3 -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip -s /usr/local/bin/nvim \
  ; git clone --depth=3 https://github.com/fj0r/nvim-lua.git /etc/nvim \
  ; opwd=$PWD; cd /etc/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf /etc/nvim/lazy/packages/*/.git \
  \
  ; apt remove -y git ripgrep gnupg2 build-essential \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;
