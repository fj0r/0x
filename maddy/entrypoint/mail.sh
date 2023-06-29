#!/usr/bin/env bash
set -e

#make-ssl-cert generate-default-snakeoil

mkdir -p /var/lib/maddy/tls

if [ "$tls" == "lego" ]; then
    lego --email="postmaster@${MADDY_HOSTNAME}" --domains="${MADDY_HOSTNAME}" --http --path /var/lib/maddy/tls run 2>&1 &
    echo -n "$! " >> /var/run/services
else
    opwd=$PWD
    cd /var/lib/maddy/tls
    if [ ! -f ${MADDY_HOSTNAME}.key ]; then
        openssl req -x509 -newkey rsa:4096 \
            -keyout ${MADDY_HOSTNAME}.key -out ${MADDY_HOSTNAME}.crt \
            -sha256 -days 3650 -nodes \
            -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=${MADDY_HOSTNAME}"
    fi
    cd $opwd
fi


# cp /tmpl/maddy.conf /var/lib/maddy/maddy.conf
tera -t /tmpl/maddy.conf -e /tmpl/default.yaml -o /var/lib/maddy/maddy.conf

echo ${MADDY_HOSTNAME} > /etc/hostname

/usr/local/bin/maddy --config /var/lib/maddy/maddy.conf run 2>&1 &
echo -n "$! " >> /var/run/services

sleep 2
export DKIM_KEY=$(cat /var/lib/maddy/dkim_keys/${MADDY_DOMAIN}_default.dns)
tera -t /tmpl/README.md -e /tmpl/default.yaml
