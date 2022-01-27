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

env | grep -E '_|HOME|ROOT|PATH|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM


################################################################################
echo "[$(date -Is)] starting conduit"
################################################################################
if [ ! -z $SERVER_NAME ]; then
    host=$(echo "$SERVER_NAME" | sed 's!https*://\(.*\)!\1!' | awk -F':' '{print $1}')
    sed -i 's!https://matrix\.org!'$SERVER_NAME'!' /srv/config.json
    sed -i 's!matrix\.org!'$host'!' /srv/config.json
    sed -i 's!your\.server\.name!'$host'!' /var/lib/conduit/conduit.toml
fi

sudo --preserve-env=CONDUIT_CONFIG -u www-data /usr/local/bin/conduit 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
echo "[$(date -Is)] starting nginx"
################################################################################
/usr/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
wait -n $(cat /var/run/services) && exit $?
