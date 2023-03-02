#!/usr/bin/env bash

set -e

stop() {
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Get PID
    pid=$(cat /var/run/services)
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

BASEDIR=$(dirname "$0")
source $BASEDIR/env.sh

trap stop SIGINT SIGTERM


################################################################################
echo "[$(date -Is)] starting v2ray"
################################################################################
/usr/bin/v2ray/v2ray -config=/etc/v2ray/config.json 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
echo "[$(date -Is)] starting nginx"
################################################################################
/opt/nginx/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services

watchexec -p -w /etc/nginx -- reload-nginx 2>&1
echo -n "$! " >> /var/run/services


################################################################################
wait -n $(cat /var/run/services) && exit $?
