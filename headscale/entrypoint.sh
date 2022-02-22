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

env | grep -E '_|HOME|ROOT|PATH|DIR|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER|LS_COLORS)=' \
   >> /etc/environment

trap stop SIGINT SIGTERM

################################################################################
echo "[$(date -Is)] starting headscale"
################################################################################
touch /var/lib/headscale/db.sqlite

yq -i e "(.ip_prefixes += \"${IP_PREFIX:-10.10.0.0/16}\")
        |(.dns_config.nameservers += \"${NAMESERVER:-8.8.8.8}\")
        |(.dns_config.domains += \"${DOMAIN}\")
        |(.server_url = \"${SERVER_URL:-http://127.0.0.1:8080}\")" \
/etc/headscale/config.yaml

headscale serve
echo -n "$! " >> /var/run/services

headscale create $NAMESPACE
token=$(headscale --namespace $NAMESPACE preauthkeys create --reusable --expiration 24h)
echo "==> tailscale up --login-server ${SERVER_URL:-<SERVER_URL>} --authkey $token"

################################################################################
wait -n $(cat /var/run/services) && exit $?
