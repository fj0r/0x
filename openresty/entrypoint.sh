#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
fi

if [ -n "$PREBOOT" ]; then
  bash $PREBOOT
fi


stop() {
    # Get PID
    pid=$(cat /var/run/services)
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

trap stop SIGINT SIGTERM #ERR EXIT


BASEDIR=$(dirname "$0")

source $BASEDIR/env.sh
source $BASEDIR/git.sh
source $BASEDIR/ssh.sh
source $BASEDIR/s3.sh
source $BASEDIR/s3fs.sh
source $BASEDIR/cron.sh

################################################################################
echo "[$(date -Is)] starting openresty"
################################################################################
if [ -n "$WEB_ROOT" ]; then
    sed -i 's!\(set $root\).*$!\1 '"\'$WEB_ROOT\'"';!' /etc/openresty/nginx.conf
fi

if grep -q '$ngx_resolver' /etc/openresty/nginx.conf; then
    sed -i 's/$ngx_resolver/'"${NGX_RESOLVER:-1.1.1.1}"'/' /etc/openresty/nginx.conf
fi

if [ -n "${HTPASSWD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=${WEB_ROOT:-/srv}/${UPLOAD_ROOT}
    mkdir -p $UPLOADDIR
    chown www-data:www-data $UPLOADDIR
fi

/opt/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
if [ -n "$POSTBOOT" ]; then
  bash $POSTBOOT
fi

wait -n $(cat /var/run/services) && exit $?
