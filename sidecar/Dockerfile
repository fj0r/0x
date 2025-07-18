ARG BASEIMAGE=fj0rd/io:common
FROM ${BASEIMAGE}

# vector
RUN set -eux \
  ; vector_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/vectordotdev/vector/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; vector_url="https://github.com/vectordotdev/vector/releases/latest/download/vector-${vector_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${vector_url} | tar -zxf - -C /usr/local/bin --strip-components=3 ./vector-x86_64-unknown-linux-musl/bin/vector \
  ; chmod +x /usr/local/bin/vector \
  ;

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends git build-essential \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; nvim_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name') \
  ; nvim_url="https://github.com/neovim/neovim/releases/download/${nvim_ver}/nvim-linux-x86_64.tar.gz" \
  ; curl --retry 3 -fsSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; git clone --depth=3 https://github.com/fj0r/nvim-lua.git /etc/nvim \
  ; opwd=$PWD; cd /etc/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf /etc/nvim/lazy/packages/*/.git \
  ; apt-get remove -y git build-essential \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

COPY entrypoint/vector.sh /entrypoint/
CMD ["srv"]
WORKDIR /app
