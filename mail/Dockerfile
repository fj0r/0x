<<<<<<< HEAD
FROM debian:testing-slim

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

ARG github_header="Accept: application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos
ARG nvim_repo=neovim/neovim
ARG rg_repo=BurntSushi/ripgrep
=======
FROM fj0rd/io
>>>>>>> d0a63b96278d7fd87b5e0c8cfae55c05c2e8a775

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
<<<<<<< HEAD
        ca-certificates sudo tzdata locales procps \
        xz-utils jq curl git swaks sqlite3 \
        postfix \
        dovecot-core dovecot-imapd dovecot-lmtpd \
        dovecot-sqlite postfix-sqlite \
        opendkim opendkim-tools \
        python3 python3-pip \
  \
  ; curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  ; apt-get install -y --no-install-recommends nodejs \
  \
  ; nvim_version=$(curl -sSL -H "'$github_header'" $github_api/${nvim_repo}/releases | jq -r '.[0].tag_name') \
  ; nvim_url=https://github.com/${nvim_repo}/releases/download/${nvim_version}/nvim-linux64.tar.gz \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; pip3 --no-cache-dir install neovim neovim-remote \
  \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
    -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
    -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  \
  ; mkdir -p ~/.config \
  ; nvim_home=~/.config/nvim \
  ; git clone --depth=1 https://github.com/murphil/nvim-coc.git $nvim_home \
  ; NVIM_SETUP_PLUGINS=1 \
    nvim -u $nvim_home/init.vim --headless +'PlugInstall' +qa \
  ; rm -rf $nvim_home/plugged/*/.git \
  ; for x in $(cat $nvim_home/coc-core-extensions) \
  ; do nvim -u $nvim_home/init.vim --headless +"CocInstall -sync coc-$x" +qa; done \
  ; npm cache clean -f \
  \
  ; rg_version=$(curl -sSL -H "'$github_header'" $github_api/${rg_repo}/releases | jq -r '.[0].tag_name') \
  ; rg_url=https://github.com/${rg_repo}/releases/download/${rg_version}/ripgrep-${rg_version}-x86_64-unknown-linux-musl.tar.gz \
  ; curl -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 ripgrep-${rg_version}-x86_64-unknown-linux-musl/rg \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#ARG s6overlay_repo=just-containers/s6-overlay
ARG watchexec_repo=watchexec/watchexec

RUN set -eux \
  ; watchexec_version=$(curl -sSL -H "'$github_header'" $github_api/${watchexec_repo}/releases | jq -r '.[0].tag_name') \
  ; watchexec_url=https://github.com/${watchexec_repo}/releases/download/${watchexec_version}/watchexec-${watchexec_version}-x86_64-unknown-linux-musl.tar.xz \
  ; curl -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin watchexec-${watchexec_version}-x86_64-unknown-linux-musl/watchexec \
  ; curl -sSL ${watchexec_url} \
      | tar Jxf - --strip-components=1 -C /usr/local/bin watchexec-${watchexec_version}-x86_64-unknown-linux-musl/watchexec
  #\
  #; s6overlay_version=$(curl -sSL -H "'$github_header'" $github_api/${s6overlay_repo}/releases | jq -r '.[0].tag_name') \
  #; s6overlay_url=https://github.com/${s6overlay_repo}/releases/download/${s6overlay_version}/s6-overlay-amd64.tar.gz \
  #; curl --fail --silent -L ${s6overlay_url} > /tmp/s6overlay.tar.gz \
  #; tar xzf /tmp/s6overlay.tar.gz -C / --exclude="./bin" \
  #; tar xzf /tmp/s6overlay.tar.gz -C /usr ./bin \
  #; rm -f /tmp/s6overlay.tar.gz

=======
        swaks sqlite3 \
        postfix postfix-sqlite \
        dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sqlite \
        opendkim opendkim-tools \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

>>>>>>> d0a63b96278d7fd87b5e0c8cfae55c05c2e8a775

COPY etc/postfix /etc/postfix
COPY etc/dovecot /etc/dovecot
COPY etc/opendkim.conf /etc/opendkim.conf

RUN set -eux \
  ; groupadd --system vmail -g 5000 \
  ; useradd --system vmail -u 5000 -g 5000 \
  ; mkdir -p /var/spool/mail/virtual \
  ; chown -R vmail:vmail /var/spool/mail/virtual \
  ; chmod 770 /var/spool/mail/virtual \
  ; chown -R vmail:dovecot /etc/dovecot \
  ; chmod -R o-rwx /etc/dovecot

#COPY services.d /etc/services.d
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]

ENV HOST=
ENV EXTERNAL_IP=
ENV MASTER=
EXPOSE 25 465 587 110 995 143 993
