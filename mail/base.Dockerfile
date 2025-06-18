FROM fj0rd/io:base

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        locales swaks telnet sqlite3 postgresql-client \
        postfix dovecot-core dovecot-imapd dovecot-lmtpd \
        dovecot-sqlite postfix-sqlite \
        dovecot-pgsql postfix-pgsql \
        opendkim opendkim-tools \
        python3 python3-pip \
  \
  ; sed -i /etc/locale.gen \
    -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
    -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; groupadd -g 5000 vmail \
  ; mkdir /var/mail/vmail \
  ; useradd -M -d /var/mail/vmail --shell=/usr/bin/nologin -u 5000 -g vmail vmail \
  ; chown vmail:vmail /var/mail/vmail \
  ; chmod 700 /var/mail/vmail \
  ; chown -R vmail:dovecot /etc/dovecot \
  ; chmod -R o-rwx /etc/dovecot

CMD ["srv"]

ENV HOST=
ENV EXTERNAL_IP=
ENV MASTER=
EXPOSE 25 465 587 110 995 143 993
