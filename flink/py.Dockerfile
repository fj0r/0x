FROM fj0rd/scratch:dropbear as dropbear
FROM python:3.10-slim-bullseye
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
        'polars[all]' Numpy Pandas numba Scikit-learn \
        debugpy pydantic pytest \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
        neovim \
  \
  ; nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" \
  ; curl --retry 3 -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; mkdir -p ${XDG_CONFIG_HOME} \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  \
  ; fd_ver=$(curl --retry 3 -sSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; rg_ver=$(curl --retry 3 -sSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; just_ver=$(curl --retry 3 -sSL https://api.github.com/repos/casey/just/releases/latest | jq -r '.tag_name') \
  ; just_url="https://github.com/casey/just/releases/latest/download/just-${just_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${just_url} | tar zxf - -C /usr/local/bin just \
  \
  ; watchexec_ver=$(curl --retry 3 -sSL https://api.github.com/repos/watchexec/watchexec/releases/latest  | jq -r '.tag_name' | cut -c 2-) \
  ; watchexec_url="https://github.com/watchexec/watchexec/releases/latest/download/watchexec-${watchexec_ver}-x86_64-unknown-linux-gnu.tar.xz" \
  ; curl --retry 3 -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/watchexec' \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${btm_url} | tar zxf - -C /usr/local/bin btm \
  \
  ; dust_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${dust_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/dust' \
  \
  ; xh_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ducaale/xh/releases/latest | jq -r '.tag_name') \
  ; xh_url="https://github.com/ducaale/xh/releases/latest/download/xh-${xh_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${xh_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/xh' \
  ; ln -sr /usr/local/bin/xh /usr/local/bin/xhs \
  \
  ; yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz" \
  ; curl --retry 3 -sSL ${yq_url} | tar zxf - ./yq_linux_amd64 && mv yq_linux_amd64 /usr/local/bin/yq \
  \
  ; apt-get remove -y build-essential \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;
