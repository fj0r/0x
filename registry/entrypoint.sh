#!/usr/bin/env bash

set -e

if [ -n "$PREBOOT" ]; then
  bash $PREBOOT
fi

#
# case "$1" in
#     *.yaml|*.yml) set -- registry serve "$@" ;;
#     serve|garbage-collect|help|-*) set -- registry "$@" ;;
# esac
#
# exec "$@"

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

crontab /app/daily-job
crond

echo "[$(date -Is)] starting docker registry"

/usr/local/bin/registry serve /etc/docker/registry/config.yml 2>&1 &
echo -n "$! " >> /var/run/services

echo "[$(date -Is)] starting openresty"

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

if [ -n "$POSTBOOT" ]; then
  bash $POSTBOOT
fi

wait -n $(cat /var/run/services) && exit $?
