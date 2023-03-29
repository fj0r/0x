FROM fj0rd/scratch:dropbear as dropbear
FROM python:3.10-slim
COPY --from=dropbear / /

ENV XDG_CONFIG_HOME=/etc \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai \
    PYTHONUNBUFFERED=x
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      git s3fs gnupg build-essential \
      sudo procps htop cron tzdata openssl \
      curl ca-certificates rsync tcpdump socat \
      jq patch tree logrotate \
      fuse xz-utils zstd zip unzip \
      lsof inetutils-ping iproute2 iptables net-tools \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; pip3 install --no-cache-dir \
        # aiofile fastapi uvicorn \
        debugpy pydantic pytest \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
        neovim \
  \
  ; nvim_url=https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; mkdir -p ${XDG_CONFIG_HOME} \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  \
  ; fd_ver=$(curl -sSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; rg_ver=$(curl -sSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; dasel_url="https://github.com/TomWright/dasel/releases/latest/download/dasel_linux_amd64.gz" \
  ; curl ${dasel_url} | gzip -d > /usr/local/bin/dasel && chmod +x /usr/local/bin/dasel \
  \
  ; apt-get remove -y build-essential \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;
