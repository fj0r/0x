FROM ollama/ollama:rocm

RUN set -eux \
  ; ollama --version \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        curl jq git \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  \
  ; nu_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/download/${nu_ver}/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${nu_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/nu' '*/nu_plugin_query' \
  \
  ; fd_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; rg_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; dua_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/Byron/dua-cli/releases/latest | jq -r '.tag_name') \
  ; dua_url="https://github.com/Byron/dua-cli/releases/download/${dua_ver}/dua-${dua_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${dua_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/dua' \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; git clone --depth=3 https://github.com/fj0r/nushell.git /root/.config/nushell \
  ; opwd=$PWD; cd /root/.config/nushell; git log -1 --date=iso; cd $opwd \
  ; nu -c "plugin add /usr/local/bin/nu_plugin_query" \
  \
  ;
