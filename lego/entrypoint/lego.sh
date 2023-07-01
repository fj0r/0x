#!/usr/bin/env bash
set -e

domain_args=""
IFS=',' read -ra DM <<< "${DOMAINS}"
for d in ${DM[@]}; do
    domain_args+=" --domains=${d}"
done

export MAIN_DOMAIN=${DM[0]}
echo '{}' | tera -t /tmpl/copy.sh -e -s -o /copy.sh
chmod +x /copy.sh


if [ ! -f /data/certificates/${MAIN_DOMAIN}.crt ]; then
    lego -a --email="${EMAIL}" $domain_args --http --path /data run --run-hook="/copy.sh" 2>&1
fi

# lego -a --email="${EMAIL}" $domain_args --http --path /data renew --renew-hook="/copy.sh" 2>&1

export DOMAIN_ARGS=$domain_args
echo '{}' | tera -t /tmpl/cronfile -e -s | crontab -
cron
