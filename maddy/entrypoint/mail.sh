#!/usr/bin/env bash
set -e

mkdir -p /data/tls

if [ ! -n "$TLS_PROVIDER" ]; then
    opwd=$PWD
    cd /data/tls
    if [ ! -f ${MADDY_HOSTNAME}.key ]; then
        openssl req -x509 -newkey rsa:4096 \
            -keyout ${MADDY_HOSTNAME}.key -out ${MADDY_HOSTNAME}.crt \
            -sha256 -days 3650 -nodes \
            -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=${MADDY_HOSTNAME}"
    fi
    cd $opwd
fi


# cp /tmpl/maddy.conf /data/maddy.conf
tera -t /tmpl/maddy.conf -e /tmpl/default.yaml -o /data/maddy.conf

echo ${MADDY_HOSTNAME} > /etc/hostname

/usr/local/bin/maddy --config /data/maddy.conf run 2>&1 &
echo -n "$! " >> /var/run/services

sleep 2
export DKIM_KEY=$(cat /data/dkim_keys/${MADDY_DOMAIN}_default.dns)
tera -t /tmpl/README.md -e /tmpl/default.yaml
