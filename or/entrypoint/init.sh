#!/usr/bin/env bash

set -e

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

source $BASEDIR/ssh.sh
source $BASEDIR/socat.sh

echo "[$(date -Is)] starting openresty"

if [ -n "${HTPASSWD}" ]; then
    IFS=':' read -ra HTP <<< "$HTPASSWD"
    printf "${HTP[0]}:$(openssl passwd -apr1 ${HTP[1]})\n" >> /etc/openresty/htpasswd
fi

if [ -n "${UPLOAD_ROOT}" ]; then
    UPLOADDIR=/srv/${UPLOAD_ROOT}
    mkdir -p $UPLOADDIR
    chown www-data:www-data $UPLOADDIR
fi

/opt/openresty/bin/openresty 2>&1 &
echo -n "$! " >> /var/run/services

if [ -n "$POSTBOOT" ]; then
  bash $POSTBOOT
fi

wait -n $(cat /var/run/services) && exit $?

