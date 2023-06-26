FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        locales sqlite3 \
        postfix swaks \
        dovecot-core dovecot-imapd dovecot-lmtpd \
        dovecot-sqlite postfix-sqlite \
        opendkim opendkim-tools \
        python3 python3-pip \
  \
  ; sed -i /etc/locale.gen \
    -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
    -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  \
  ; watchexec_ver=$(curl -sSL https://api.github.com/repos/watchexec/watchexec/releases/latest  | jq -r '.tag_name' | cut -c 2-) \
  ; watchexec_url="https://github.com/watchexec/watchexec/releases/latest/download/watchexec-${watchexec_ver}-x86_64-unknown-linux-gnu.tar.xz" \
  ; curl -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/watchexec' \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

COPY etc/sqlite/postfix /etc/postfix
COPY etc/sqlite/dovecot /etc/dovecot
COPY etc/sqlite/opendkim.conf /etc/opendkim.conf

RUN set -eux \
  ; groupadd -g 5000 vmail \
  ; mkdir /var/mail/vmail \
  ; useradd -M -d /var/mail/vmail --shell=/usr/bin/nologin -u 5000 -g vmail vmail \
  ; chown vmail:vmail /var/mail/vmail \
  ; chmod 700 /var/mail/vmail \
  ; chown -R vmail:dovecot /etc/dovecot \
  ; chmod -R o-rwx /etc/dovecot

COPY entrypoint/sqlite.mail.sh /entrypoint/
CMD ["srv"]

ENV HOST=
ENV EXTERNAL_IP=
ENV MASTER=
EXPOSE 25 465 587 110 995 143 993
