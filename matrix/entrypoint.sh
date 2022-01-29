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
    HOST=$(echo "$SERVER_NAME" | sed 's!https*://\(.*\)!\1!' | awk -F':' '{print $1}')
    cat /config.json | \
        sed -e 's!https://matrix\.org!'$SERVER_NAME'!' \
            -e 's!matrix\.org!'$HOST'!' \
        > /srv/config.json

    sed -i 's!SERVER_NAME_PLACEHOLDER!'$HOST':'${SERVER_PORT:-443}'!' /etc/nginx/nginx.conf

    if [ ! -f '/var/lib/conduit/conduit.toml' ]; then
        cat /conduit.toml | \
            sed 's!your\.server\.name!'$HOST'!' \
            > /var/lib/conduit/conduit.toml
    fi
fi

touch /var/lib/conduit/conduit.db
chown www-data:www-data -R /var/lib/conduit
sudo --preserve-env=CONDUIT_CONFIG -u www-data /usr/local/bin/conduit 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
echo "[$(date -Is)] starting nginx"
################################################################################
/usr/sbin/nginx 2>&1 &
echo -n "$! " >> /var/run/services


################################################################################
wait -n $(cat /var/run/services) && exit $?