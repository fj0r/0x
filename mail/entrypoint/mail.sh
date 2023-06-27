#!/usr/bin/env bash
set -e

ds=$(cat /tmpl/default.yaml | yq '.datasource.type')

# postfix
tera -t /tmpl/_hosts -e /tmpl/default.yaml  >> /etc/hosts
tera -t /tmpl/_mailname -e /tmpl/default.yaml  >> /etc/mailname

tera -t /tmpl/postfix/main.cf -e /tmpl/default.yaml -o /etc/postfix/main.cf
tera -t /tmpl/postfix/master.cf -e /tmpl/default.yaml -o /etc/postfix/master.cf

for f in relay_domains_maps relay_recipient_maps virtual_alias_maps virtual_domains_maps virtual_mailbox_maps; do
    tera -t /tmpl/postfix/${ds}/${f}.cf -e /tmpl/default.yaml -o /etc/postfix/${ds}_${f}.cf
done

# dovecot
tera -t /tmpl/dovecot/dovecot.conf -e /tmpl/default.yaml -o /etc/dovecot/dovecot.conf
tera -t /tmpl/dovecot/$ds/dovecot-sql.conf.ext -e /tmpl/default.yaml -o /etc/dovecot/dovecot.conf.ext

for f in /tmpl/dovecot/conf.d/*; do
    tera -t $f -e /tmpl/default.yaml -o /etc/dovecot/conf.d/$(basename $f)
done

# opendkim
if [ -n "${OPENDKIM}" ]; then
    tera -t /tmpl/opendkim.conf -e /tmpl/default.yaml -o /etc/opendkim.conf

    MYHOST=$(tera -t /tmpl/_HOST -e /tmpl/default.yaml)
    if [ ! -d /etc/opendkim/keys/$MYHOST ]; then
        echo "--- generate opendkim keys"
        curr=$PWD
        mkdir -p /etc/opendkim/keys/$MYHOST
        cd /etc/opendkim/keys/$MYHOST
        opendkim-genkey -d $MYHOST -s default --bits=1024
        chown -R opendkim:opendkim /etc/opendkim/keys/$MYHOST
        echo "default._domainkey.$MYHOST $MYHOST:default:/etc/opendkim/keys/$MYHOST/default.private" >> /etc/opendkim/KeyTable
        echo "*@$MYHOST default._domainkey.$MYHOST" >> /etc/opendkim/SigningTable
        cd $curr
    fi
    export DKIM_KEY=$(cat /etc/opendkim/keys/$MYHOST/default.txt)
    service opendkim start
fi

# sql
if [ $ds == "sqlite" ]; then
    sqlite_file=$(cat /tmpl/default.yaml | yq '.datasource.path')
    if [ ! -f "$sqlite_file" ]; then
        mkdir -p $(dirname "$sqlite_file")
        export PASSWD_DIGEST=$(tera -t /tmpl/_PASSWORD -e /tmpl/default.yaml | openssl passwd -1 -stdin)
        tera -t /tmpl/sql/sqlite.sql -e /tmpl/default.yaml -o /tmp/sqlite.sql
        cat /tmp/sqlite.sql | sqlite3 -batch $sqlite_file
        chmod 600 $sqlite_file
    fi
elif [ $ds == "pgsql" ]; then
    echo pgsql
fi

service postfix start
service dovecot start

tera -t /tmpl/README.md -e /tmpl/default.yaml
