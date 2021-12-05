FROM fj0rd/io

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        swaks sqlite3 \
        postfix postfix-sqlite \
        dovecot-core dovecot-imapd dovecot-lmtpd dovecot-sqlite \
        opendkim opendkim-tools \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


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
