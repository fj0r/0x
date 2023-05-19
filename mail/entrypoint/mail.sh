#!/bin/sh
set -eux

MYHOST=${HOST:-localhost}
MASTER=${MASTER:-master}
EXTERNAL_IP=${EXTERNAL_IP:-127.0.0.1}
MYDOMAIN=$(echo $MYHOST|cut -d'.' -f 2-)
echo "${EXTERNAL_IP} ${MYHOST}" >> /etc/hosts
#echo "${MYDOMAIN}" >> /etc/mailname
echo "${MYHOST}" >> /etc/mailname

sed -i 's/MAIL\.DOMAIN\.TLD/'"${MYHOST}"'/' /etc/postfix/main.cf

sed -i 's/USER@DOMAIN\.TLD/'"${MASTER}@${MYHOST}"'/' /etc/postfix/aliases
postalias /etc/postfix/aliases

### DKIM
sed -i 's/MAIL\.DOMAIN\.TLD/'"${MYHOST}"'/' /etc/opendkim.conf
if [ ! -d /etc/opendkim/keys/$MYHOST ]; then
    echo "--- generate opendkim keys"
    curr=$PWD
    mkdir -p /etc/opendkim/keys/$MYHOST
    cd /etc/opendkim/keys/$MYHOST
    opendkim-genkey -d $MYHOST -s default
    chown -R opendkim:opendkim /etc/opendkim/keys/$MYHOST
    echo "default._domainkey.$MYHOST $MYHOST:default:/etc/opendkim/keys/$MYHOST/default.private" >> /etc/opendkim/KeyTable
    echo "*@$MYHOST default._domainkey.$MYHOST" >> /etc/opendkim/SigningTable
    cd $curr
fi
cat /etc/opendkim/keys/$MYHOST/default.txt

if [ ! -f /etc/vmail/vmail.sqlite ]; then
    sqlite3 -batch /etc/vmail/vmail.sqlite << EOF
    CREATE TABLE alias (
        address varchar(255) NOT NULL,
        goto text NOT NULL,
        domain varchar(255) NOT NULL,
        created datetime NOT NULL default '0000-00-00 00:00:00',
        modified datetime NOT NULL default '0000-00-00 00:00:00',
        active tinyint(1) NOT NULL default '1');

    CREATE TABLE domain (
        domain varchar(255) NOT NULL,
        description varchar(255) NOT NULL,
        aliases int(10) NOT NULL default '0',
        mailboxes int(10) NOT NULL default '0',
        maxquota bigint(20) NOT NULL default '0',
        quota bigint(20) NOT NULL default '0',
        transport varchar(255) NOT NULL,
        backupmx tinyint(1) NOT NULL default '0',
        created datetime NOT NULL default '0000-00-00 00:00:00',
        modified datetime NOT NULL default '0000-00-00 00:00:00',
        active tinyint(1) NOT NULL default '1' );

    CREATE TABLE mailbox (
        username varchar(255) NOT NULL,
        password varchar(255) NOT NULL,
        name varchar(255) NOT NULL,
        maildir varchar(255) NOT NULL,
        quota bigint(20) NOT NULL default '0',
        domain varchar(255) NOT NULL,
        created datetime NOT NULL default '0000-00-00 00:00:00',
        modified datetime NOT NULL default '0000-00-00 00:00:00',
        local_part varchar(255) NOT NULL,
        active tinyint(1) NOT NULL default '1');

	INSERT INTO domain ( domain, description, transport )
		VALUES ( '$MYHOST', '$MYHOST domain', 'virtual' );

	INSERT INTO mailbox ( username, password, name, maildir, domain, local_part )
		VALUES ( '$MASTER@$MYHOST', '$(echo ${PASSWORD:-test} | openssl passwd -1 -stdin)', '$MASTER', '$MYHOST/$MASTER@$MYHOST/', '$MYHOST', '$MASTER' );

	INSERT INTO alias ( address, goto, domain )
		VALUES ( 'master@$MYHOST', '$MASTER@$MYHOST', '$MYHOST' );
EOF
    chmod 600 /etc/vmail/vmail.sqlite
fi

service postfix start
service dovecot start
service opendkim start

watchexec -p -w /etc/postfix/ -- service postfix restart &
watchexec -p -w /etc/dovecot/ -- service dovecot restart &
watchexec -p -w /etc/opendkim.conf -- service opendkim restart &

wait
