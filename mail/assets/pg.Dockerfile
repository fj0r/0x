FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        locales swaks \
        postfix \
        dovecot-core dovecot-imapd dovecot-lmtpd \
        dovecot-pgsql postfix-pgsql \
        opendkim opendkim-tools \
        python3 python3-pip \
  \
  ; sed -i /etc/locale.gen \
    -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
    -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  \
  ; watchexec_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/watchexec/watchexec/releases/latest  | jq -r '.tag_name' | cut -c 2-) \
  ; watchexec_url="https://github.com/watchexec/watchexec/releases/latest/download/watchexec-${watchexec_ver}-x86_64-unknown-linux-gnu.tar.xz" \
  ; curl --retry 3 -fsSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/watchexec' \
  \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

COPY etc/postgres/postfix /etc/postfix
COPY etc/postgres/dovecot /etc/dovecot
COPY etc/postgres/opendkim.conf /etc/opendkim.conf

RUN set -eux \
  ; groupadd -g 5000 vmail \
  ; mkdir /var/mail/vmail \
  ; useradd -u 5000 -g vmail -s /usr/bin/nologin -d /home/vmail -m vmail \
  ; chown vmail:vmail /var/mail/vmail \
  ; chmod 700 /var/mail/vmail \
  \
  ; chown vmail:dovecot -R /etc/dovecot \
  ; chmod o-rwx -R /etc/dovecot


COPY entrypoint/mail.sh /entrypoint/
CMD ["srv"]

ENV HOST=
ENV EXTERNAL_IP=
ENV MASTER=
EXPOSE 25 465 587 110 995 143 993
